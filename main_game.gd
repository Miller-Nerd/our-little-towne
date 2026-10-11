extends Node2D

func _ready():
	# Configure the MultiplayerSpawner to spawn player scenes
	var spawner = get_node_or_null("MultiplayerSpawner")
	if spawner != null:
		print("Configuring MultiplayerSpawner...")
		spawner.add_spawnable_scene("res://player.tscn")
		print("Player scene added as spawnable to MultiplayerSpawner")
	else:
		print("Could not find MultiplayerSpawner node - this may be expected in some contexts")

func _on_player_joined(player_id, player_data):
	# Players are spawned automatically by Godot's multiplayer system
	# This function can be used for additional setup if needed
	print("Player joined: " + str(player_id))