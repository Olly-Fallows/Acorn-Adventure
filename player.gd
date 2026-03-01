extends CharacterBody3D


const SPEED := 7.0
const ACCEL := 5.0
const JUMP_VELOCITY := 10

@onready var _camera_pivot := %CameraPivot as Node3D
@onready var _model := %Model as Node3D

@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_camera_pivot.rotation.x -= event.relative.y * mouse_sensitivity
		# Prevent the camera from rotating too far up or down.
		_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, -tilt_limit, tilt_limit)
		rotation.y += -event.relative.x * mouse_sensitivity
		
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerpf(velocity.x, direction.x * SPEED, ACCEL*delta)
		velocity.z = lerpf(velocity.z, direction.z * SPEED, ACCEL*delta)
	else:
		velocity.x = lerpf(velocity.x, 0, ACCEL*delta)
		velocity.z = lerpf(velocity.z, 0, ACCEL*delta)
	
	if velocity.x or velocity.z:
		var look_pos = global_position
		look_pos.x += velocity.x
		look_pos.z += velocity.z
		_model.look_at(look_pos)
	
	move_and_slide()
