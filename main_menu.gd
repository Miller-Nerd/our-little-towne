extends Control

func _ready():
	print("Minimal main menu loaded")
	# Connect button signals
	var play_button = $PlayButton
	if play_button:
		print("Found PlayButton, connecting...")
		play_button.connect("pressed", Callable(self, "_on_play_button_pressed"))
		print("Play button connected successfully")
	else:
		print("ERROR: Could not find PlayButton node")

func _on_play_button_pressed():
	print("Play button pressed!")
	print("Attempting to change scene to character_select.tscn")
	var result = get_tree().change_scene_to_file("res://character_select.tscn")
	if result != OK:
		print("Failed to change scene: ", result)
	else:
		print("Scene changed successfully")
