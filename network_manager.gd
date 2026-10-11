extends Node

# Multiplayer networking manager using ENetMultiplayerPeer
var is_server = false
var my_player_id = -1
var connected_players = []
var peer = null
var lobby_name = ""
var max_players = 8

signal player_joined(player_id, player_data)
signal player_left(player_id)
signal player_ready_changed(player_id, is_ready)
signal game_start_requested()

func _ready():
	print("Network manager initialized")
	if Engine.is_editor_hint():
		return
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func start_server(port=7000):
	print("Starting server on port " + str(port))
	is_server = true
	
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(port, max_players)
	if err != OK:
		print("Failed to create server: " + str(err))
		return false
	
	multiplayer.multiplayer_peer = peer
	my_player_id = 1
	
	print("Server started successfully")
	return true

func connect_to_server(ip_address, port=7000, player_data=null):
	print("Connecting to server at: " + ip_address + ":" + str(port))
	is_server = false
	
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip_address, port)
	if err != OK:
		print("Failed to create client: " + str(err))
		return false
	
	multiplayer.multiplayer_peer = peer
	
	# Wait for connection to be established
	var timeout = 3.0
	while timeout > 0 and (peer.get_connection_status() != ENetMultiplayerPeer.CONNECTION_CONNECTED):
		await get_tree().create_timer(0.1).timeout
		timeout -= 0.1
	
	if peer.get_connection_status() != ENetMultiplayerPeer.CONNECTION_CONNECTED:
		print("Connection timed out")
		return false
	
	my_player_id = multiplayer.get_unique_id()
	print("Connected with player ID: " + str(my_player_id))
	
	# Wait briefly for Godot's internal peer registration to complete
	await get_tree().create_timer(1.0).timeout
	
	# Send join request to server with actual character data
	if player_data == null:
		player_data = {"name": "Player" + str(my_player_id), "ready": false}
	rpc_id(1, "broadcast_player_join", my_player_id, player_data)
	
	return true

func _on_peer_connected(id):
	print("Client connected: " + str(id))
	# Send current lobby state to the new joiner so they see existing players
	if is_server and id != 1:
		call_deferred("_sync_lobby_with_new_player", id)

func _sync_lobby_with_new_player(peer_id):
	rpc_id(peer_id, "sync_lobby_state", connected_players)

func _on_peer_disconnected(id):
	print("Client disconnected: " + str(id))
	remove_player_from_lobby(id)
	emit_signal("player_left", id)

@rpc("any_peer", "reliable")
func add_player_to_lobby(player_id, player_data):
	print("DEBUG: NetworkManager.add_player_to_lobby called with player_id=" + str(player_id) + ", data=" + str(player_data))
	if not has_player_in_lobby(player_id):
		connected_players.append({"id": player_id, "data": player_data})
		print("Player added to lobby: " + str(player_id))
		emit_signal("player_joined", player_id, player_data)
		# Broadcast the updated lobby state to all players
		broadcast_lobby_state()
	else:
		print("Player " + str(player_id) + " already in lobby")

@rpc("any_peer", "reliable")
func sync_lobby_state(players):
	connected_players = players
	for p in connected_players:
		emit_signal("player_joined", p.id, p.data)

@rpc("any_peer", "reliable")
func broadcast_player_join(player_id, player_data):
	add_player_to_lobby(player_id, player_data)

func remove_player_from_lobby(player_id):
	print("DEBUG: NetworkManager.remove_player_from_lobby called with player_id=" + str(player_id))
	for i in range(connected_players.size()):
		if connected_players[i].id == player_id:
			var removed_player = connected_players[i]
			connected_players.remove_at(i)
			print("Player removed from lobby: " + str(player_id))
			emit_signal("player_left", player_id)
			# Broadcast the updated lobby state to all players
			broadcast_lobby_state()
			return true
	print("Player not found in lobby for removal: " + str(player_id))
	return false

@rpc("any_peer", "reliable")
func broadcast_lobby_state():
	print("DEBUG: Broadcasting lobby state with " + str(connected_players.size()) + " players")
	for p in connected_players:
		print("  Player ID: " + str(p.id) + ", Name: " + str(p.data.name) + ", Ready: " + str(p.data.ready))
	
	# Broadcast to all connected peers (except the sender)
	for peer_id in get_peers():
		if peer_id != get_network_unique_id():
			rpc_id(peer_id, "sync_lobby_state", connected_players)

func has_player_in_lobby(player_id):
	print("DEBUG: Checking if player " + str(player_id) + " is in lobby")
	for p in connected_players:
		if p.id == player_id:
			return true
	print("DEBUG: Player " + str(player_id) + " not found in lobby")
	return false

func get_player_data(player_id):
	print("DEBUG: NetworkManager.get_player_data called for player_id=" + str(player_id))
	for p in connected_players:
		if p.id == player_id:
			print("DEBUG: Found player data for " + str(player_id) + ": " + str(p.data))
			return p.data
	print("DEBUG: Player data not found for " + str(player_id))
	return null

@rpc("any_peer", "reliable")
func set_player_ready(player_id, is_ready):
	for i in range(connected_players.size()):
		if connected_players[i].id == player_id:
			connected_players[i].data.ready = is_ready
			emit_signal("player_ready_changed", player_id, is_ready)
			# Also directly broadcast the update to all peers
			broadcast_player_ready_change(player_id, is_ready)
			return

@rpc("any_peer", "reliable") 
func broadcast_player_ready_change(player_id, is_ready):
	# This function is called by the host to directly notify all peers of ready status changes
	emit_signal("player_ready_changed", player_id, is_ready)

func get_player_count():
	return connected_players.size()

func are_all_players_ready():
	for p in connected_players:
		if not p.data.ready:
			return false
	return true

@rpc("any_peer", "reliable")
func request_game_start():
	print("Game start requested by player " + str(my_player_id))
	emit_signal("game_start_requested")

func cleanup():
	if peer != null:
		peer.close()
		multiplayer.multiplayer_peer = null
