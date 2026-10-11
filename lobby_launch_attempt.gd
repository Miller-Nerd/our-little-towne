extends Control

var lobby_name = ""
var port = 7000
var timer = null
var progress_step = 0.0

func _ready():
	# Get lobby settings from previous scene
	if get_tree().has_meta("lobby_host_settings"):
		var settings = get_tree().get_meta("lobby_host_settings")
		lobby_name = settings.lobby_name
		port = settings.port
		print("Host settings loaded - Lobby: ", lobby_name, ", Port: ", port)
	else:
		print("No lobby host settings found")
	
	# Connect cancel button
	$Panel/VBoxContainer/CancelButton.connect("pressed", Callable(self, "_on_cancel_pressed"))
	
	# Start the hosting process
	start_hosting()

func start_hosting():
	# Initialize progress bar
	$Panel/VBoxContainer/ProgressBar.value = 0.0
	$Panel/VBoxContainer/StatusLabel.text = "Initializing server..."
	
	# Create a timer to simulate the hosting process
	timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	
	# Start with a short delay before beginning
	timer.wait_time = 0.5
	timer.autostart = false
	timer.start()

func _on_timer_timeout():
	progress_step += 0.1  # Increase progress by 10% each step
	
	if progress_step >= 1.0:
		# Hosting complete - proceed to lobby
		$Panel/VBoxContainer/ProgressBar.value = 100.0
		$Panel/VBoxContainer/StatusLabel.text = "Lobby ready! Entering..."
		
		# Change to lobby scene after a short delay
		var timer2 = Timer.new()
		add_child(timer2)
		timer2.connect("timeout", Callable(self, "_on_host_complete"))
		timer2.wait_time = 1.0
		timer2.autostart = false
		timer2.start()
	else:
		# Update progress bar and status
		$Panel/VBoxContainer/ProgressBar.value = progress_step * 100.0
		
		# Update status messages based on progress
		match int(progress_step * 10):
			0: $Panel/VBoxContainer/StatusLabel.text = "Initializing server..."
			1: $Panel/VBoxContainer/StatusLabel.text = "Loading game resources..."
			2: $Panel/VBoxContainer/StatusLabel.text = "Setting up network connections..."
			3: $Panel/VBoxContainer/StatusLabel.text = "Configuring lobby settings..."
			4: $Panel/VBoxContainer/StatusLabel.text = "Starting server instance..."
			5: $Panel/VBoxContainer/StatusLabel.text = "Preparing player data..."
			6: $Panel/VBoxContainer/StatusLabel.text = "Finalizing connections..."
			7: $Panel/VBoxContainer/StatusLabel.text = "Verifying server setup..."
			8: $Panel/VBoxContainer/StatusLabel.text = "Almost ready..."
			9: $Panel/VBoxContainer/StatusLabel.text = "Lobby initializing..."
		
		# Schedule next step
		timer.wait_time = 0.5
		timer.start()

func _on_host_complete():
	# Try to get NetworkManager using the standard approach for autoloads
	var network_manager = null
	
	# Use ProjectSettings to verify autoload is configured, then try direct access
	var autoload_path = ProjectSettings.get_setting("autoload/NetworkManager")
	if autoload_path != null and autoload_path != "":
		print("NetworkManager is properly configured as autoload at: ", autoload_path)
	
	# Method 1: Try to get it from the root node directly using the proper path
	# This should work in most cases for autoloads
	var root = get_tree().root
	if root != null:
		if root.has_node("NetworkManager"):
			network_manager = root.get_node("NetworkManager")
	
	# If still not found, try the more direct approach
	if network_manager == null:
		try:
			network_manager = get_node("/NetworkManager")
		except:
			pass
	
	# If we still haven't found it, we need to check if it's even available in this context
	if network_manager == null:
		print("ERROR: Could not access NetworkManager. Make sure it is properly configured as an autoload in project settings.")
		print("This may be due to timing issues with scene initialization or autoload loading.")
		return
	
	var success = network_manager.start_server(port)
	
	# Only proceed if server started successfully
	if not success:
		print("Failed to start server!")
		return
	
	# Pass character data to town gate scene for host player
	var char_data = get_tree().get_meta("character_data", null)
	print("Character data in lobby_launch_attempt: ", char_data)
	if char_data != null:
		get_tree().set_meta("character_data", char_data)
		print("Set character data in meta for town gate")
	
	get_tree().change_scene_to_file("res://town_gate.tscn")

func _on_cancel_pressed():
	# Return to main menu
	get_tree().change_scene_to_file("res://main_menu.tscn")
