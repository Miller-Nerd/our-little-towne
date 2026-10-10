extends Control

var NetworkManager = preload("res://network_manager.gd")
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
	# Set up network manager for hosting
	var network_manager = NetworkManager.new()
	get_tree().root.add_child(network_manager)
	
	# Start the server with the specified port
	network_manager.start_server(port)
	
	# Pass network manager to next scene via meta
	get_tree().set_meta("network_manager", network_manager)
	
	# Change to lobby scene
	var result = get_tree().change_scene_to_file("res://lobby.tscn")
	if result != OK:
		print("Failed to change to lobby scene: ", result)
	else:
		print("Navigated to lobby scene")

func _on_cancel_pressed():
	# Return to main menu
	get_tree().change_scene_to_file("res://main_menu.tscn")
