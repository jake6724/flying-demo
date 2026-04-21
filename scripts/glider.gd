class_name Glider
extends CharacterBody3D

@export var camera: Camera3D
@export var camera_pivot: Node3D
var camera_input_direction: Vector2

var move_direction: Vector3
var move_speed: float = 50.0
var acceleration: float = 200.0

var max_tilt: float = 45
var tilt: float = 0.0
var tilt_multiplier: float = 1.8
var level_out_multiplier: float = 40.0

var gravity: float = 0

@export var skin: MeshInstance3D

var rotation_speed: float = 15.0

@export var mouse_sensitivty: float = 0.25

var input_enabled: bool = true

func _ready():
	pass

func _input(_event):
	if input_enabled:
		if Input.is_action_just_pressed("left_click"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

		if Input.is_action_just_pressed("escape"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	if input_enabled:
		var is_camera_motion: bool = (event is InputEventMouseMotion) and (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED)
		if is_camera_motion:
			camera_input_direction = event.screen_relative * mouse_sensitivty
			tilt = (clampf(tilt + deg_to_rad((-event.screen_relative.x * tilt_multiplier)), -max_tilt, max_tilt))

func _physics_process(delta):
	# Set X and Y camera rotation. Clamp X axis so player cannot look fully up or down
	camera_pivot.rotation.x -= camera_input_direction.y * delta
	camera_pivot.rotation.y -= camera_input_direction.x  * delta
	camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, (-PI / 16.0), (PI / 6.0))

	# Reset camera_input_direction for the next time _unhandled_input() is triggered
	# If this is not reset, the camera will keep rotating until new input comes in
	camera_input_direction = Vector2.ZERO
	var raw_input: Vector2 = Vector2.ZERO
	if input_enabled:
		# Get the raw 2-axis input data, forward direction of camera, and right direction of camera
		# Forward direction is used to move back-and-forth, right direction is used to move left-and-right
		raw_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	var forward_direction: Vector3 = camera.global_basis.z
	var right_direction: Vector3 = camera.global_basis.x

	# Final move direction is the sum of back-and-forth and left-and-right movement
	move_direction = (forward_direction * raw_input.y) + (right_direction * raw_input.x)
	move_direction.y = 0.0 # Player will never give up-and-down move input. Jumping and falling with handle this
	move_direction = move_direction.normalized() # This is just intended to be a direction vector so it needs to be normalized

	# Acceleration can be added by using move_toward(). This will also prevent overshooting
	var y_velocity = velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward((move_direction * move_speed), acceleration * delta)
	velocity.y = (y_velocity + (gravity * delta))

	skin.global_rotation.y = lerp_angle(skin.global_rotation.y, camera.global_rotation.y + TAU , rotation_speed * delta)
	
	skin.rotation_degrees.z = tilt
	tilt = move_toward(tilt, 0, delta*level_out_multiplier)

	move_and_slide()
