class_name Glider
extends CharacterBody3D

@export var camera: Camera3D
@export var camera_pivot: Node3D
var camera_input_direction: Vector2

var move_direction: Vector3
var move_speed: float = 50.0
var acceleration: float = 1000

var roll: float = 0.0
var max_roll: float = 75
var roll_sensitivity: float = 3
var roll_level_out_multiplier: float = 60.0

## CURRENTLY UN-USED
var pitch: float = 0.0
var max_pitch: float = 70.0
var pitch_multiplier: float = 1.8


var vertical_move: float

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

			move_speed += 50


		if Input.is_action_just_pressed("escape"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	if input_enabled:
		var is_camera_motion: bool = (event is InputEventMouseMotion) and (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED)
		if is_camera_motion:
			camera_input_direction = event.screen_relative * mouse_sensitivty
			roll = (clampf(roll + deg_to_rad((-event.screen_relative.x * roll_sensitivity)), -max_roll, max_roll))

		if Input.is_action_pressed("right_click"):
			move_speed = clampf(move_speed - 3, 1, 250)

func _physics_process(delta):

	# Set X and Y camera rotation. Clamp X axis so player cannot look fully up or down
	camera_pivot.rotation.x -= camera_input_direction.y * delta
	camera_pivot.rotation.y -= camera_input_direction.x  * delta
	camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, (-PI / 4.0), (PI / 2))

	# print("camera_pivot.rotation.x: ", camera_pivot.rotation.x)

	# Reset camera_input_direction for the next time _unhandled_input() is triggered
	# If this is not reset, the camera will keep rotating until new input comes in
	camera_input_direction = Vector2.ZERO
	var raw_input: Vector2 = Vector2.ZERO
	# if input_enabled:
		# Get the raw 2-axis input data, forward direction of camera, and right direction of camera
		# Forward direction is used to move back-and-forth, right direction is used to move left-and-right
		# raw_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	var forward_direction: Vector3 = camera.global_basis.z
	var right_direction: Vector3 = camera.global_basis.x

	# Final move direction is the sum of back-and-forth and left-and-right movement
	# move_direction = (forward_direction * raw_input.y) + (right_direction * raw_input.x)
	move_direction = -camera.global_transform.basis.z
	# move_direction.y = 0.0 # Player will never give up-and-down move input. Jumping and falling with handle this
	move_direction = move_direction.normalized() # This is just intended to be a direction vector so it needs to be normalized
	# print("Move direction: ", move_direction)
	# vertical_move += (Vector3.UP * camera_pivot.rotation.x)
	# vertical_move

	##TODO: Slow down faster when going up, speed up slower when going down. Gravity should help with this as well I think

	var move_speed_modifier: float = -camera.global_rotation_degrees.x * .01
	move_speed = clampf(move_speed + move_speed_modifier, 1, 250)
	# print("camera.rotation_degrees.x: ", camera.global_rotation_degrees.x)
	# print("MoveSpeed: ", move_speed)
	# print("MoveSpeedModifier: ", move_speed_modifier)

	# Acceleration can be added by using move_toward(). This will also prevent overshooting
	var y_velocity = velocity.y
	# velocity.y = 0.0
	velocity = velocity.move_toward((move_direction * move_speed), acceleration * delta)
	# velocity.y = y_velocity + (gravity * delta)
	# print("velocity: ", velocity)


	skin.look_at(skin.global_transform.origin + velocity)

	skin.global_rotation.y = lerp_angle(skin.global_rotation.y, camera_pivot.global_rotation.y + TAU , rotation_speed * delta)
	# Snap the skin's rotation if it is close enough to target, since lerp_angle will never actually reach target
	if abs(abs(skin.global_rotation.y) - abs(camera_pivot.global_rotation.y)) < 1:
		skin.global_rotation.y = camera_pivot.global_rotation.y
	
	skin.rotation_degrees.z = roll
	roll = move_toward(roll, 0, delta * roll_level_out_multiplier)

	move_and_slide()
