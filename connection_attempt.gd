extends Control

var target_ip = "127.0.0.1"
var target_port = 7000
var network_manager = null

func _ready():
	print("Connection attempt scene loaded")
	
	var server_info = get_tree().get_meta("server_info", null)
	if server_info != null:
		target_ip = server_info.ip
		target_port = server_info.port
	
	var cancel_button = $CancelButton
	if cancel_button:
		cancel_button.connect("pressed", Callable(self, "_on_cancel_pressed"))
	
	# Get the network manager singleton
	network_manager = get_node("/root/NetworkManager")
	
	start_connection()

func start_connection():
	print("Starting connection to " + target_ip + ":" + str(target_port))
	
	# Update UI to show connecting status
	var status_label = $StatusLabel
	if status_label:
		status_label.text = "Connecting to server..."
	
	# Attempt actual network connection with character data
	var character_data = get_tree().get_meta("character_data", null)
	var player_info = {"name": "Player" + str(1), "ready": false}
	if character_data != null:
		player_info.name = character_data.name
	
	var success = await get_node("/root/NetworkManager").connect_to_server(target_ip, target_port, player_info)
	
	if success:
		print("Connection successful!")
		
		# Wait for server to fully establish connection and initialize
		await get_tree().create_timer(2.0).timeout
		
		# Make sure character_data is properly passed to lobby scene
		character_data = get_tree().get_meta("character_data", null)
		if character_data != null:
			print("Got character data back: ", character_data)
			# Ensure the data is available in the lobby scene
			get_tree().set_meta("character_data", character_data)
		
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
