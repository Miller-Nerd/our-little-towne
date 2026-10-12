extends CharacterBody2D

@export var speed = 400

func _ready():
	_ensure_key_action("move_left", KEY_A)
	_ensure_key_action("move_right", KEY_D)
	_ensure_key_action("move_up", KEY_W)
	_ensure_key_action("move_down", KEY_S)

func _ensure_key_action(action_name: String, keycode: Key):
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	for event in InputMap.action_get_events(action_name):
		if event is InputEventKey and event.keycode == keycode:
			return

	var key_event = InputEventKey.new()
	key_event.keycode = keycode
	InputMap.action_add_event(action_name, key_event)

func _physics_process(_delta):
	if not is_multiplayer_authority():
		return

	get_input()
	move_and_slide()

func get_input():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * speed
