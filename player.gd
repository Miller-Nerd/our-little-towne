extends CharacterBody2D

@export var speed = 400

func _ready():
	# Set up input actions for WASD movement
	InputMap.add_action("move_left")
	InputMap.add_action("move_right")
	InputMap.add_action("move_up")
	InputMap.add_action("move_down")
	
	# Map keys to actions
	InputMap.action_add_event("move_left", InputEventKey.new())
	InputMap.action_add_event("move_right", InputEventKey.new())
	InputMap.action_add_event("move_up", InputEventKey.new())
	InputMap.action_add_event("move_down", InputEventKey.new())
	
	# Configure key mappings for WASD
	var left_event = InputEventKey.new()
	left_event.keycode = Key.A
	left_event.scancode = KEY_A
	InputMap.action_add_event("move_left", left_event)
	
	var right_event = InputEventKey.new()
	right_event.keycode = Key.D
	right_event.scancode = KEY_D
	InputMap.action_add_event("move_right", right_event)
	
	var up_event = InputEventKey.new()
	up_event.keycode = Key.W
	up_event.scancode = KEY_W
	InputMap.action_add_event("move_up", up_event)
	
	var down_event = InputEventKey.new()
	down_event.keycode = Key.S
	down_event.scancode = KEY_S
	InputMap.action_add_event("move_down", down_event)

func get_input():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * speed

func _physics_process(delta):
	get_input()
	move_and_slide()