extends Control

# This script handles the town gate scene logic
# Players arrive here after successfully setting up a server in lobby_launch_attempt

func _ready():
	# Set up UI elements
	update_world_info()
	
	# Connect buttons
	$VBoxContainer/ButtonContainer/EnterTownButton.connect("pressed", Callable(self, "_on_enter_town_pressed"))
	$VBoxContainer/ButtonContainer/LeaveButton.connect("pressed", Callable(self, "_on_leave_pressed"))

func update_world_info():
	# Get world information from previous scenes
	var world_name = "Unknown World"
	var player_count = 0
	
	# Try to get world name from meta if available
	if get_tree().has_meta("selected_world"):
		world_name = get_tree().get_meta("selected_world")
	
	# Try to get player count from meta if available
	if get_tree().has_meta("player_count"):
		player_count = get_tree().get_meta("player_count")
	
	# Update UI labels
	$VBoxContainer/WorldInfoLabel.text = "World: " + world_name
	$VBoxContainer/PlayerCountLabel.text = "Players in town: " + str(player_count)

func _on_enter_town_pressed():
	# Transition to the actual game world
	print("Entering town...")
	
	# Get character data if available
	var char_data = get_tree().get_meta("character_data", null)
	if char_data != null:
		print("Character data found for entering town: ", char_data)
	
	# In a real implementation, this would load the actual game world scene
	# For now, we'll just simulate it with a print statement
	get_tree().change_scene_to_file("res://main_game.tscn")

func _on_leave_pressed():
	# Return to main menu
	print("Leaving town...")
	
	# Clean up network resources before leaving
	var network_manager = get_node("/root/NetworkManager")
	if network_manager != null:
		network_manager.cleanup()
	
	get_tree().change_scene_to_file("res://main_menu.tscn")