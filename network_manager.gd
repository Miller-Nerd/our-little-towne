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
	# Set up multiplayer peer signals
	if Engine.is_editor_hint():
		return
	
	peer = ENetMultiplayerPeer.new()
	multiplayer.multiplayer_peer = peer
	
	peer.connect("server_disconnected", Callable(self, "_on_server_disconnected"))
	peer.connect("client_connected", Callable(self, "_on_client_connected"))
	peer.connect("client_disconnected", Callable(self, "_on_client_disconnected"))

func start_server(port=7000):
	print("Starting server on port " + str(port))
	is_server = true
	
	var err = peer.create_server(port, max_players)
	if err != OK:
		print("Failed to create server: " + str(err))
		return false
	
	my_player_id = 1
	multiplayer.set_unique_id(1)
	
	# Add self as first player in lobby
	add_player_to_lobby(my_player_id, {"name": "Host", "ready": false})
	
	print("Server started successfully")
	return true

func connect_to_server(ip_address, port=7000):
	print("Connecting to server at: " + ip_address + ":" + str(port))
	is_server = false
	
	var err = peer.create_client(ip_address, port)
	if err != OK:
		print("Failed to create client: " + str(err))
		return false
	
	# Wait for connection and get player ID from server
	await get_tree().create_timer(0.5).timeout
	
	player_id = multiplayer.get_unique_id()
	print("Connected with player ID: " + str(player_id))
	
	# Send join request to server
	rpc_id(1, "_handle_player_join", player_id, {"name": "Player" + str(player_id), "ready": false})
	
	return true

func _on_client_connected(id):
	print("Client connected: " + str(id))
	if id != 1 and not has_player_in_lobby(id):
		add_player_to_lobby(id, {"name": "Player" + str(id), "ready": false})

func _on_client_disconnected(id):
	print("Client disconnected: " + str(id))
	remove_player_from_lobby(id)
	emit_signal("player_left", id)

func _on_server_disconnected():
	print("Disconnected from server")
	is_server = false

@rpc("any_peer", "reliable")
func add_player_to_lobby(player_id, player_data):
	if not has_player_in_lobby(player_id):
		connected_players.append({"id": player_id, "data": player_data})
		print("Player added to lobby: " + str(player_id))
		emit_signal("player_joined", player_id, player_data)

func remove_player_from_lobby(player_id):
	for i in range(connected_players.size()):
		if connected_players[i].id == player_id:
			connected_players.remove_at(i)
			print("Player removed from lobby: " + str(player_id))
			return true
	return false

func has_player_in_lobby(player_id):
	for p in connected_players:
		if p.id == player_id:
			return true
	return false

@rpc("any_peer", "reliable")
func set_player_ready(player_id, is_ready):
	for i in range(connected_players.size()):
		if connected_players[i].id == player_id:
			connected_players[i].data.ready = is_ready
			print("Player " + str(player_id) + " ready status: " + str(is_ready))
			emit_signal("player_ready_changed", player_id, is_ready)
			return

func get_player_count():
	return connected_players.size()

func are_all_players_ready():
	for p in connected_players:
		if not p.data.ready:
			return false
	return true

@rpc("any_peer", "reliable")
func request_game_start():
	print("Game start requested by player " + str(player_id))
	emit_signal("game_start_requested")

func cleanup():
	if peer != null:
		peer.close()
		peer = null
