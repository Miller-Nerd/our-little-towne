extends Control

func _ready():
	print("Server select scene loaded")
	
	# Connect buttons
	var connect_button = $ConnectButton
	if connect_button:
		connect_button.connect("pressed", Callable(self, "_on_connect_pressed"))
	
	var back_button = $BackButton
	if back_button:
		back_button.connect("pressed", Callable(self, "_on_back_pressed"))

func _on_connect_pressed():
	print("Connect button pressed")
	
	# Get IP and port from input fields
	var ip_input = $ServerListContainer/IPInputRow/IPInput
	var port_input = $ServerListContainer/PortInputRow/PortInput
	
	var server_ip = "127.0.0.1"
	var server_port = 7000
	
	if ip_input:
		server_ip = ip_input.text.strip_edges()
	
	if port_input:
		var port_text = port_input.text.strip_edges()
		if port_text != "":
			server_port = int(port_text)
	
	print("Connecting to server: " + server_ip + ":" + str(server_port))
	
	# Pass server info to connection attempt scene
	get_tree().set_meta("server_info", {
		"ip": server_ip,
		"port": server_port
	})
	
	# Navigate to connection attempt scene
	get_tree().change_scene_to_file("res://connection_attempt.tscn")

func _on_back_pressed():
	print("Back button pressed - returning to character select")
	get_tree().change_scene_to_file("res://character_select.tscn")
