extends Node2D

const PLAYER_SCENE = preload("res://player.tscn")

@onready var player_spawner: MultiplayerSpawner = $MultiplayerSpawner

func _ready():
	player_spawner.spawn_function = _create_player

	var network_manager = get_node_or_null("/root/NetworkManager")
	if network_manager == null:
		return

	if not network_manager.player_joined.is_connected(_on_player_joined):
		network_manager.player_joined.connect(_on_player_joined)
	if not network_manager.player_left.is_connected(_on_player_left):
		network_manager.player_left.connect(_on_player_left)

	if not multiplayer.is_server():
		return

	# Always show the host, including when running without remote peers.
	_spawn_player(1)
	for player in network_manager.connected_players:
		_spawn_player(int(player.get("id", -1)))

func _on_player_joined(player_id: int, _player_data):
	if multiplayer.is_server():
		_spawn_player(player_id)

func _on_player_left(player_id: int):
	if not multiplayer.is_server():
		return

	var player = get_node_or_null("Player_%d" % player_id)
	if player != null:
		player.queue_free()

func _spawn_player(player_id: int):
	if player_id < 1:
		return

	if get_node_or_null("Player_%d" % player_id) != null:
		return

	player_spawner.spawn({"player_id": player_id})

func _create_player(data: Variant) -> Node:
	var player_id = int(data.get("player_id", 1))
	var player = PLAYER_SCENE.instantiate()
	player.name = "Player_%d" % player_id
	player.set_multiplayer_authority(player_id)
	return player
