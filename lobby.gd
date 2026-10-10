extends Control

# Lobby system for up to 8 players using ENet multiplayer
var max_players = 8
var network_manager = null
var NetworkManager = preload("res://network_manager.gd")
var my_player_id = -1

func _ready():
	# Initialize network manager as singleton
	network_manager = NetworkManager.new()
	get_tree().root.add_child(network_manager)
	
	my_player_id = multiplayer.get_unique_id()
	print("Lobby player ID: " + str(my_player_id))
	
	# Connect to network signals
	network_manager.connect("player_joined", Callable(self, "_on_player_joined"))
	network_manager.connect("player_left", Callable(self, "_on_player_left"))
	network_manager.connect("player_ready_changed", Callable(self, "_on_player_ready_changed"))
	network_manager.connect("game_start_requested", Callable(self, "_on_game_start_requested"))
	
	# Initialize lobby display with empty slots
	update_lobby_display()
	
	# Connect the start game button
	var start_button = get_node("LobbyContainer/StartGameButton")
	if start_button:
		start_button.connect("pressed", Callable(self, "_on_start_game_pressed"))
	
	# Check if we have character data from connection attempt
	var character_data = get_tree().get_meta("player_character_data", null)
	if character_data != null:
		print("Got character data in lobby: ", character_data)
		# Send join request with character data to server
		network_manager.rpc_id(1, "add_player_to_lobby", my_player_id, {"name": character_data.name, "ready": false})

func _on_start_game_pressed():
	print("Starting game")
	if network_manager.is_server:
		network_manager.request_game_start()
	else:
		network_manager.rpc_id(1, "request_game_start")

func _on_player_joined(player_id, player_data):
	print("Player joined lobby: " + str(player_id))
	update_lobby_display()

func _on_player_left(player_id):
	print("Player left lobby: " + str(player_id))
	update_lobby_display()

func _on_player_ready_changed(player_id, is_ready):
	print("Player ready status changed: " + str(player_id) + " -> " + str(is_ready))
	update_lobby_display()

func _on_game_start_requested():
	print("Game starting!")
	# Wait a moment for all clients to receive the signal
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://main_game.tscn")

func update_lobby_display():
	# Update the UI to show current players from network manager
	var connected = network_manager.connected_players
	
	for i in range(1, max_players + 1):
		var player_name_label = get_node("LobbyContainer/PlayerList/PlayerSlot" + str(i) + "/PlayerInfo" + str(i) + "/PlayerName" + str(i))
		var player_status_label = get_node("LobbyContainer/PlayerList/PlayerSlot" + str(i) + "/PlayerInfo" + str(i) + "/PlayerStatus" + str(i))
		
		if i <= connected.size():
			var player = connected[i-1]
			if player_name_label:
				player_name_label.text = player.data.name
			if player_status_label:
				player_status_label.text = "Ready" if player.data.ready else "Not Ready"
		else:
			if player_name_label:
				player_name_label.text = "Empty Slot"
			if player_status_label:
				player_status_label.text = "Waiting"

func set_my_ready(is_ready):
	network_manager.set_player_ready(my_player_id, is_ready)