extends Control

func _ready():
	$SettingsPanel/BackButton.connect("pressed", Callable(self, "_on_back_button_pressed"))

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")