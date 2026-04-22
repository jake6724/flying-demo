class_name Glider
extends CharacterBody3D

@export_group("Camera & Mouse")
@export var camera: Camera3D
@export var camera_pivot: Node3D
@export var mouse_sensitivty: float = 0.25
@export var camera_limit_down: float = (-PI / 4.0)
@export var camera_limit_up: float = (PI / 2)
var camera_input_direction: Vector2

@export_group("Movement")
@export var move_speed: float = 50.0
@export var move_speed_max: float = 250.0
@export var move_speed_min: float = 1.0
@export var move_speed_pitch_multiplier: float = 0.01
@export var acceleration: float = 1000
@export var rotation_speed: float = 15.0
@export var rotation_snap_threshold: float = 1.0
@export var boost_power: float = 50.0
@export var brake_power: float = 3.0
var move_direction: Vector3

@export_group("Roll")
@export var max_roll_degree: float = 75
@export var roll_sensitivity: float = 3
@export var roll_level_out_multiplier: float = 60.0
var roll: float = 0.0

@export_group("Gravity & Falling")
@export var max_fall_speed: float = 20
@export var gravity: float = -10
@export var fall_speed: float

@export_group("Trails")
@export var trail_left: Trail3D
@export var trail_right: Trail3D
@export var trail_visibilty_speed_threshold: float = 125

@export_group("Other")
@export var skin: MeshInstance3D
var _input_enabled: bool = true

func _ready():
	pass

func _input(_event):
	if _input_enabled:
		if Input.is_action_just_pressed("left_click"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			move_speed += boost_power
		if Input.is_action_just_pressed("escape"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	if _input_enabled:
		var is_camera_motion: bool = (event is InputEventMouseMotion) and (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED)
		if is_camera_motion:
			camera_input_direction = event.screen_relative * mouse_sensitivty
			roll = (clampf(roll + deg_to_rad((-event.screen_relative.x * roll_sensitivity)), -max_roll_degree, max_roll_degree))

		if Input.is_action_pressed("right_click"):
			move_speed = clampf(move_speed - brake_power, move_speed_min, move_speed_max)

func _physics_process(delta):
	# Set X and Y camera rotation. Clamp X axis so player cannot look fully up or down
	camera_pivot.rotation.x -= camera_input_direction.y * delta
	camera_pivot.rotation.y -= camera_input_direction.x  * delta
	camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, camera_limit_down, camera_limit_up)

	# Reset camera_input_direction for the next time _unhandled_input() is triggered
	# If this is not reset, the camera will keep rotating until new input comes in
	camera_input_direction = Vector2.ZERO

	# Move direction is solely based on camera/mouse positioning; not key inputs
	move_direction = -camera.global_transform.basis.z
	move_direction = move_direction.normalized() # This is just intended to be a direction vector so it needs to be normalized

	##TODO: Slow down faster when going up, speed up slower when going down. Gravity should help with this as well I think

	var move_speed_modifier: float = -camera.global_rotation_degrees.x * move_speed_pitch_multiplier
	move_speed = clampf(move_speed + move_speed_modifier, move_speed_min, move_speed_max)

	show_trails() if move_speed >= trail_visibilty_speed_threshold else hide_trails()
	
	# Acceleration can be added by using move_toward(). This will also prevent overshooting
	fall_speed = clampf(fall_speed + (gravity * delta), -max_fall_speed, max_fall_speed)
	var velocity_target: Vector3 = (move_direction * move_speed) + Vector3(0,fall_speed,0)
	velocity = velocity.move_toward(velocity_target, acceleration * delta)

	skin.look_at(skin.global_transform.origin + velocity)
	skin.global_rotation.y = lerp_angle(skin.global_rotation.y, camera_pivot.global_rotation.y + TAU , rotation_speed * delta)
	# Snap the skin's rotation if it is close enough to target, since lerp_angle will never actually reach target
	if abs(abs(skin.global_rotation.y) - abs(camera_pivot.global_rotation.y)) < rotation_snap_threshold:
		skin.global_rotation.y = camera_pivot.global_rotation.y
	
	skin.rotation_degrees.z = roll
	roll = move_toward(roll, 0, delta * roll_level_out_multiplier)

	move_and_slide()

func hide_trails() -> void:
	trail_left.hide()
	trail_right.hide()

func show_trails() -> void:
	trail_left.show()
	trail_right.show()
