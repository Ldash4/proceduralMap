extends Camera

const MAXSPEED = 5
const ACCELERATION_SPEED = 1
const DECELERATION_SPEED = 0.1
const SENSITIVITY = 0.001

var velocity = Vector3()

func _physics_process(delta):
	var movement = Vector3()
	var got_input = false
	if Input.is_action_pressed("move_forward"):
		movement.z = -1
		got_input = true
	elif Input.is_action_pressed("move_backward"):
		movement.z = 1
		got_input = true

	if Input.is_action_pressed("move_right"):
		movement.x = 1
		got_input = true
	elif Input.is_action_pressed("move_left"):
		movement.x = -1
		got_input = true

	if got_input:
		velocity += movement * ACCELERATION_SPEED * delta
	else:
		velocity = velocity.linear_interpolate(Vector3(), DECELERATION_SPEED)
	translate(velocity)

func _input(event):
	if event is InputEventMouseMotion:
		rotation.x -= event.relative.y * SENSITIVITY
		rotation.y -= event.relative.x * SENSITIVITY
	elif event is InputEventKey:
		if event.scancode == KEY_ESCAPE:
			get_tree().quit()
		elif event.scancode == KEY_F11:
			OS.window_fullscreen = not OS.window_fullscreen

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	OS.window_fullscreen = true