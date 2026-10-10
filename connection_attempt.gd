extends Control

var network_manager = null
var NetworkManager = preload("res://network_manager.gd")
var target_ip = "127.0.0.1"
var target_port = 7000

func _ready():
	print("Connection attempt scene loaded")
	
	# Get server info from previous scene
	var server_info = get_tree().get_meta("server_info", null)
	if server_info != null:
		target_ip = server_info.ip
		target_port = server_info.port
	
	# Initialize network manager
	network_manager = NetworkManager.new()
	get_tree().root.add_child(network_manager)
	
	# Connect cancel button
	var cancel_button = $CancelButton
	if cancel_button:
		cancel_button.connect("pressed", Callable(self, "_on_cancel_pressed"))
	
	# Start actual connection process
	start_connection()

func start_connection():
	print("Starting connection to " + target_ip + ":" + str(target_port))
	
	# Update UI to show connecting status
	var status_label = $StatusLabel
	if status_label:
		status_label.text = "Connecting to server..."
	
	# Attempt actual network connection
	var success = network_manager.connect_to_server(target_ip, target_port)
	
	if success:
		print("Connection successful!")
		# Wait for player ID assignment and lobby join
		await get_tree().create_timer(1.0).timeout
		
		# Get character data that was passed from character selection
		var character_data = get_tree().get_meta("character_data", null)
		if character_data != null:
			print("Got character data back: ", character_data)
			get_tree().set_meta("player_character_data", character_data)
		
		# Navigate to lobby
		get_tree().change_scene_to_file("res://lobby.tscn")
	else:
		print("Connection failed!")
		show_connection_failed_popup()

func show_connection_failed_popup():
	var popup = PanelContainer.new()
	popup.name = "ErrorPopup"
	popup.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	popup.custom_minimum_size = Vector2(300, 150)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	popup.add_child(vbox)
	
	var label = Label.new()
	label.text = "Connection Failed"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)
	
	var reason_label = Label.new()
	reason_label.text = "Could not connect to server at " + target_ip + ":" + str(target_port)
	reason_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reason_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(reason_label)
	
	var ok_button = Button.new()
	ok_button.text = "Ok"
	ok_button.connect("pressed", Callable(self, "_on_error_ok_pressed"))
	vbox.add_child(ok_button)
	
	add_child(popup)

func _on_error_ok_pressed():
	# Return to server select scene
	get_tree().change_scene_to_file("res://server_select.tscn")

func _on_cancel_pressed():
	print("Connection cancelled by user")
	network_manager.cleanup()
	get_tree().change_scene_to_file("res://main_menu.tscn")
