extends Control

var network_manager = null
var NetworkManager = preload("res://network_manager.gd")

func _ready():
	print("Minimal main menu loaded")
	
	# Initialize network manager as singleton
	network_manager = NetworkManager.new()
	get_tree().root.add_child(network_manager)
	
	# Connect button signals
	var play_button = $PlayButton
	if play_button:
		play_button.connect("pressed", Callable(self, "_on_host_pressed"))
	
	var join_button = $JoinButton
	if join_button:
		join_button.connect("pressed", Callable(self, "_on_join_pressed"))

func _on_host_pressed():
	print("Host game pressed!")
	# Start server and go to character selection
	network_manager.start_server(7000)
	get_tree().change_scene_to_file("res://character_select.tscn")

func _on_join_pressed():
	print("Join game pressed!")
	# Go directly to connection attempt scene
	get_tree().change_scene_to_file("res://connection_attempt.tscn")
