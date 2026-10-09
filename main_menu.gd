extends Control

func _ready():
	# Connect button signals
	$PlayButton.connect("pressed", Callable(self, "_on_play_button_pressed"))
	$SettingsButton.connect("pressed", Callable(self, "_on_settings_button_pressed"))
	$Settings/BackButton.connect("pressed", Callable(self, "_on_back_button_pressed"))

func _on_play_button_pressed():
	print("Play button pressed")
	# Load the main game scene here
	get_tree().change_scene_to_file("res://main_game.tscn")

func _on_settings_button_pressed():
	print("Settings button pressed")
	# Load settings scene
	get_tree().change_scene_to_file("res://settings.tscn")

func _on_back_button_pressed():
	print("Back button pressed")
	# Return to main menu
	get_tree().change_scene_to_file("res://main_menu.tscn")