extends Node2D

func _ready():
	# Create player when main game scene loads
	var player_scene = preload("res://player.tscn")
	var player = player_scene.instantiate()
	player.position = Vector2(400, 300)  # Set initial position
	add_child(player)