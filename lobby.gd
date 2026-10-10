extends Control

# Lobby system for up to 8 players
var players = []
var max_players = 8
var network_manager = null
var NetworkManager = preload("res://network_manager.gd")

func _ready():
	# Initialize lobby with empty player slots
	for i in range(1, max_players + 1):
		var player_name_label = get_node("LobbyContainer/PlayerList/PlayerSlot" + str(i) + "/PlayerInfo" + str(i) + "/PlayerName" + str(i))
		var player_status_label = get_node("LobbyContainer/PlayerList/PlayerSlot" + str(i) + "/PlayerInfo" + str(i) + "/PlayerStatus" + str(i))
		
		if player_name_label:
			player_name_label.text = "Player " + str(i)
		if player_status_label:
			player_status_label.text = "Ready"
	
	# Connect the start game button
	var start_button = get_node("LobbyContainer/StartGameButton")
	if start_button:
		start_button.connect("pressed", Callable(self, "_on_start_game_pressed"))
	
	# Initialize network manager
	network_manager = NetworkManager.new()
	
	# Check if we have character data from connection attempt
	var character_data = get_tree().get_meta("player_character_data", null)
	if character_data != null:
		print("Got character data in lobby: ", character_data)
		# Add the player with character data
		add_player_with_character(character_data)

func _on_start_game_pressed():
	print("Starting game with players: ", players)
	# TODO: Implement actual game starting logic
	get_tree().change_scene_to_file("res://main_game.tscn")

func add_player(player_name):
	# Add a player to the lobby
	if players.size() < max_players:
		players.append(player_name)
		update_lobby_display()
		# Notify network manager
		if network_manager:
			network_manager.add_player(player_name)
		return true
	return false

func remove_player(player_name):
	# Remove a player from the lobby
	if player_name in players:
		players.erase(player_name)
		update_lobby_display()
		# Notify network manager
		if network_manager:
			network_manager.remove_player(player_name)
		return true
	return false

func update_lobby_display():
	# Update the UI to show current players
	for i in range(1, max_players + 1):
		var player_name_label = get_node("LobbyContainer/PlayerList/PlayerSlot" + str(i) + "/PlayerInfo" + str(i) + "/PlayerName" + str(i))
		var player_status_label = get_node("LobbyContainer/PlayerList/PlayerSlot" + str(i) + "/PlayerInfo" + str(i) + "/PlayerStatus" + str(i))
		
		if i <= players.size():
			if player_name_label:
				player_name_label.text = players[i-1]
			if player_status_label:
				player_status_label.text = "Ready"
		else:
			if player_name_label:
				player_name_label.text = "Empty Slot"
			if player_status_label:
				player_status_label.text = "Waiting"

func set_player_ready(player_index, is_ready):
	# Set a specific player's ready status
	if player_index >= 0 and player_index < players.size():
		var player_status_label = get_node("LobbyContainer/PlayerList/PlayerSlot" + str(player_index + 1) + "/PlayerInfo" + str(player_index + 1) + "/PlayerStatus" + str(player_index + 1))
		if player_status_label:
			player_status_label.text = "Ready" if is_ready else "Not Ready"
		# Notify network manager
		if network_manager:
			network_manager.set_player_ready(player_index, is_ready)

func add_player_with_character(character_data):
	# Add a player to the lobby with character data
	print("Adding player with character data: ", character_data)
	var player_name = character_data.name
	if players.size() < max_players:
		players.append(player_name)
		update_lobby_display()
		# Store character data for this player
		get_tree().set_meta("player_character_" + str(players.size()), character_data)
		return true
	return false