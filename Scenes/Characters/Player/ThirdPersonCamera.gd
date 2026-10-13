class_name ThirdPersonCamera extends Node3D


# Camera Rotation
@export var mouse_sensitivity: float = 0.12
@export var min_pitch: float = -45.0
@export var max_pitch: float = 25.0

# Camera Distance
@export var default_distance: float = 4.0
@export var min_distance: float = 1.5
@export var max_distance: float = 6.0
@export var zoom_step: float = 0.5
@export var zoom_smoothing: float = 12.0

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera: Camera3D = %Camera3D

var target_distance: float


func _ready() -> void:
	target_distance = default_distance
	spring_arm.spring_length = default_distance

	# Не допускаем столкновения камеры с самим игроком.
	var player := get_parent() as CollisionObject3D
	if player:
		spring_arm.add_excluded_object(player.get_rid())

	# Мышь должна управлять камерой сразу, без задержки физического тика.
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	_handle_zoom(delta)


func _unhandled_input(event: InputEvent) -> void:
	# Освободить курсор.
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return

	# Повторно захватить курсор кликом.
	if event is InputEventMouseButton and event.pressed:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			return

	# Вращение камеры мышью.
	if event is InputEventMouseMotion:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			return

		rotation_degrees.y -= (
			event.relative.x * mouse_sensitivity
		)

		rotation_degrees.x -= (
			event.relative.y * mouse_sensitivity
		)

		rotation_degrees.x = clampf(
			rotation_degrees.x,
			min_pitch,
			max_pitch
		)


func _handle_zoom(delta: float) -> void:
	if event_zoom_in():
		target_distance -= zoom_step

	if event_zoom_out():
		target_distance += zoom_step

	target_distance = clampf(
		target_distance,
		min_distance,
		max_distance
	)

	var weight := 1.0 - exp(-zoom_smoothing * delta)

	spring_arm.spring_length = lerpf(
		spring_arm.spring_length,
		target_distance,
		weight
	)


func event_zoom_in() -> bool:
	return Input.is_action_just_pressed("zoom_camera_in")


func event_zoom_out() -> bool:
	return Input.is_action_just_pressed("zoom_camera_out")
