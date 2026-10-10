extends Control

func _ready():
	# Connect buttons
	$Panel/VBoxContainer/VBoxContainer2/HBoxContainer3/StartHostButton.connect("pressed", Callable(self, "_on_start_host_pressed"))
	$Panel/VBoxContainer/VBoxContainer2/HBoxContainer3/BackButton.connect("pressed", Callable(self, "_on_back_pressed"))

func _on_start_host_pressed():
	var lobby_name = $Panel/VBoxContainer/VBoxContainer2/HBoxContainer/LobbyNameInput.text
	var port = $Panel/VBoxContainer/VBoxContainer2/HBoxContainer2/PortInput.text
	
	# Validate inputs
	if lobby_name == "":
		print("Error: Lobby name cannot be empty")
		return
		
	if not port.is_valid_int():
		print("Error: Port must be a valid integer")
		return
		
	var port_num = int(port)
	if port_num < 1 or port_num > 65535:
		print("Error: Port must be between 1 and 65535")
		return
	
	# Store lobby settings in scene tree for use in next scene
	get_tree().set_meta("lobby_host_settings", {
		"lobby_name": lobby_name,
		"port": port_num
	})
	
	# Navigate to lobby launch attempt scene
	var result = get_tree().change_scene_to_file("res://lobby_launch_attempt.tscn")
	if result != OK:
		print("Failed to change to lobby launch attempt scene: ", result)
	else:
		print("Navigated to lobby launch attempt scene")

func _on_back_pressed():
	# Return to main menu
	get_tree().change_scene_to_file("res://main_menu.tscn")
