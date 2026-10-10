extends Control

func _ready():
	print("Connection attempt scene loaded")
	
	# Connect cancel button
	var cancel_button = $CancelButton
	if cancel_button:
		print("Found CancelButton, connecting...")
		cancel_button.connect("pressed", Callable(self, "_on_cancel_pressed"))
		print("Cancel button connected successfully")
	
	# Start connection simulation
	start_connection()

func start_connection():
	print("Starting connection process...")
	
	# Simulate connection progress
	var progress = 0.0
	var timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", Callable(self, "_update_progress").bind(progress))
	timer.start(0.5)  # Update every 0.5 seconds
	
	# Store reference to the timer for later use
	get_tree().set_meta("connection_timer", timer)
	
	# Simulate connection completion after a few steps
	var connection_timer = Timer.new()
	add_child(connection_timer)
	connection_timer.connect("timeout", Callable(self, "_on_connection_complete"))
	connection_timer.start(3.0)  # Complete after 3 seconds

func _update_progress(progress):
	print("Connection progress: " + str(progress))
	
	# Update progress bar
	var progress_bar = $ProgressBar
	if progress_bar:
		progress_bar.value = progress
	
	# Update status label
	var status_label = $StatusLabel
	if status_label:
		status_label.text = "Connecting... " + str(int(progress * 100)) + "%"
	
	# Increment progress
	progress += 0.25
	if progress > 1.0:
		progress = 1.0
	
	# Stop timer when complete
	if progress >= 1.0:
		var timer = get_tree().get_meta("connection_timer")
		if timer:
			timer.stop()

func _on_connection_complete():
	print("Connection complete!")
	
	# Get character data that was passed from character selection
	var character_data = get_tree().get_meta("character_data", null)
	if character_data != null:
		print("Got character data back: ", character_data)
		# Store this in the scene meta for lobby to use
		get_tree().set_meta("player_character_data", character_data)
	
	# Change to lobby scene after connection
	var result = get_tree().change_scene_to_file("res://lobby.tscn")
	if result != OK:
		print("Failed to change to lobby scene: ", result)
	else:
		print("Connected and navigated to lobby")

func _on_cancel_pressed():
	print("Connection cancelled by user")
	get_tree().change_scene_to_file("res://main_menu.tscn")