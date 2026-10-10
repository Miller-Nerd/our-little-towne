extends Control

func _ready():
	print("Minimal main menu loaded")
	
	# Connect button signals
	var host_button = $HostButton
	if host_button:
		host_button.connect("pressed", Callable(self, "_on_host_pressed"))
	
	var join_button = $JoinButton
	if join_button:
		join_button.connect("pressed", Callable(self, "_on_join_pressed"))

func _on_host_pressed():
	print("Host game pressed!")
	get_tree().set_meta("host_mode", true)
	get_tree().change_scene_to_file("res://character_select.tscn")

func _on_join_pressed():
	print("Join game pressed!")
	get_tree().set_meta("host_mode", false)
	get_tree().change_scene_to_file("res://character_select.tscn")

func _on_join_pressed():
	print("Join game pressed!")
	# Set flag indicating this is a join flow, then go to character select
	get_tree().set_meta("host_mode", false)
	get_tree().change_scene_to_file("res://character_select.tscn")
