extends Control

# Lobby system for up to 8 players using ENet multiplayer
var max_players = 8
var my_player_id = -1
var is_ready = false
var character_name = ""
var network_manager = null

func _ready():
	# Get the network manager singleton
	network_manager = get_node("/root/NetworkManager")
	
	# Wait for network manager to be fully initialized
	await get_tree().create_timer(0.1).timeout
	
	# Network manager is now an autoload singleton, no need to retrieve from meta
	my_player_id = network_manager.my_player_id
	print("Lobby player ID: " + str(my_player_id))
	
	# Get character name from scene meta or use default - add extra debugging
	var char_data = get_tree().get_meta("character_data", null)
	print("Character data in lobby:", char_data)
	
	# Make sure we have the character data before proceeding
	if char_data == null:
		print("WARNING: No character data found in lobby scene meta, trying to get from network manager")
		# Try to get player data from network manager directly 
		var player_data = network_manager.get_player_data(my_player_id)
		if player_data != null:
			character_name = player_data.name
		else:
			print("WARNING: No character data found anywhere. Using default name.")
			character_name = "Player" + str(my_player_id)
	else:
		character_name = char_data.name
	
	print("Character name set to: " + character_name)
	
	# Join lobby with character name
	if my_player_id == 1:
		# Host adds themselves directly since they're the server
		network_manager.add_player_to_lobby(my_player_id, {"name": character_name, "ready": false})
		print("Host added themselves to lobby")
	else:
		# Clients must use RPC to add themselves to the lobby
		network_manager.rpc_id(1, "add_player_to_lobby", my_player_id, {"name": character_name, "ready": false})
		print("Client sent RPC to add themselves to lobby")
	
	# Connect signals for lobby updates
	network_manager.player_joined.connect(_on_player_joined)
	network_manager.player_left.connect(_on_player_left)
	network_manager.player_ready_changed.connect(_on_player_ready_changed)
	network_manager.game_start_requested.connect(_on_game_start_requested)
	
	# Update UI immediately after joining
	print("About to update lobby display from ready function")
	update_lobby_display()
	print("Updated lobby display from ready function")
	
	# Hide start game button for non-host players (player ID != 1)
	var start_game_button = get_node("LobbyContainer/ButtonRow/StartGameButton")
	if start_game_button:
		print("DEBUG: Setting StartGameButton visibility for player " + str(my_player_id) + ", should be visible only for host (ID=1)")
		start_game_button.visible = (my_player_id == 1)
	
	print("Lobby ready completed, my player ID: " + str(my_player_id))

func _on_start_game_pressed():
	print("Starting game")
	if network_manager.is_server:
		network_manager.request_game_start()
	else:
		network_manager.rpc_id(1, "request_game_start")

func _on_ready_button_pressed():
	print("Ready button pressed, my player ID: " + str(my_player_id))
	var ready_button = get_node("LobbyContainer/ButtonRow/ReadyButton")
	is_ready = !is_ready
	
	if is_ready:
		set_my_ready(true)
		ready_button.text = "I'm Not Ready!"
	else:
		set_my_ready(false)
		ready_button.text = "I'm Ready!"
	
	print("Ready status changed for player " + str(my_player_id) + " to " + str(is_ready))

func _on_player_joined(_player_id, _player_data):
	print("Player joined lobby: " + str(_player_id) + ", data: " + str(_player_data))
	update_lobby_display()

func _on_player_left(player_id):
	print("Player left lobby: " + str(player_id))
	update_lobby_display()

func _on_player_ready_changed(player_id, is_ready):
	print("Player ready status changed: " + str(player_id) + " is now " + str(is_ready))
	update_lobby_display()

func _on_game_start_requested():
	print("Game start requested by host")
	get_tree().change_scene_to_file("res://game.tscn")

func update_lobby_display():
	# Update the UI to show current players from network manager
	var connected = network_manager.connected_players
	
	print("DEBUG: Updating lobby display, connected players count: " + str(connected.size()))
	
	# Loop through all player slots (1-8)
	for i in range(1, max_players + 1):
		var slot_node = null
		var player_name_label = null
		var player_status_label = null
		
		# Try to find the nodes with proper error handling using find_child
		try:
			slot_node = find_child("PlayerSlot" + str(i), true)
			if slot_node:
				player_name_label = find_child("PlayerName" + str(i), true)
				player_status_label = find_child("PlayerStatus" + str(i), true)
			else:
				print("DEBUG: Could not find PlayerSlot" + str(i))
		except:
			print("DEBUG: Error finding nodes for player slot " + str(i))
			continue
		
		# Check if there's a player in this slot position (i-1 because array is 0-indexed)
		if i <= connected.size():
			var player = connected[i-1]
			print("DEBUG: Player " + str(i) + " data: " + str(player))
			slot_node.visible = true
			if player_name_label:
				player_name_label.text = player.data.name if player.data.has("name") else "Unknown"
			if player_status_label:
				player_status_label.text = "Ready" if player.data.ready else "Not Ready"
		else:
			# Hide the slot if no player is in this position
			if slot_node:
				slot_node.visible = false

func set_my_ready(is_ready):
	print("set_my_ready called with is_ready=" + str(is_ready) + ", my_player_id=" + str(my_player_id))
	# Send ready status change to host (player 1) via RPC, but only if we're not the host
	if my_player_id != 1:
		print("Sending RPC to host for player " + str(my_player_id))
		network_manager.rpc_id(1, "set_player_ready", my_player_id, is_ready)
	else:
		# If we are the host, handle directly - no RPC needed
		print("Host handling ready status directly for player " + str(my_player_id))
		network_manager.set_player_ready(my_player_id, is_ready)

func _on_leave_lobby_pressed():
	var confirm_dialog = get_node("LeaveConfirmDialog")
	if confirm_dialog:
		confirm_dialog.popup_centered()

func _on_confirm_leave():
	print("Leaving lobby...")
	
	# Remove self from lobby if server knows about us
	if network_manager.has_player_in_lobby(my_player_id):
		network_manager.remove_player_from_lobby(my_player_id)
	
	# Clean up network connection
	network_manager.cleanup()
	
	# Return to main menu
	get_tree().change_scene_to_file("res://main_menu.tscn")
