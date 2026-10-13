extends Character


const MOUSE_SENSITIVITY : float = 0.007
# прикольчики с прыжками
const COYOTE_TIME : float = 0.1
const JUMP_BUFFER_TIME : float = 0.15
# качание головой
const HEADBOB_MOVE_AMOUNT : float = 0.06
const HEADBOB_FREQUENCY : float = 2.4
# наклон камеры
const CAMERA_TILT_AMOUNT : float = 2
const CAMERA_TILT_SPEED : float = 4


@export_category("Player Movement")
@export var walk_speed: float = 5.5
@export var sprint_speed: float = 5.5
@export var jump_velocity: float = 7.5

# Nodes
@onready var camera : Camera3D = get_node(^"%Camera3D")
@onready var camera_pivot: Node3D = $CameraPivot

# variables
var coyote_timer : float = 0.0
var jump_buffer_timer : float = 0.0
var headbob_timer : float = 0.0
var is_sprinting : bool = false


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

##Процессы больше с интерфейсом и камерой
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return

	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


##Процессы больше с движением, прыжком, гравитацией
func _physics_process(delta):
	_update_coyote_time(delta)
	
	if can_move:
		_player_movement()
		_update_jump_buffer(delta)
		_handle_jump()
	else:
		move_direction = Vector3.ZERO
		jump_buffer_timer = 0.0
	
	super._physics_process(delta)
	
	# Визуализация движения при поворотах
	_rotate_visual(move_direction, delta)
	#_update_animation()
	
	_headbob_effect(delta)
	_title_effect(delta)
	

func _player_movement() -> void:
	var input_dir := Input.get_vector(&"left", &"right", &"up", &"down")
	
	is_sprinting = (Input.is_action_pressed(&"run") and not input_dir.is_zero_approx())
	movement_speed = (sprint_speed if is_sprinting else walk_speed)
	# Направление игрока за камерой
	move_direction = _get_camera_relative_direction(input_dir)


##Прыжок
func _handle_jump() -> void:
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_velocity
		coyote_timer = 0.0
		jump_buffer_timer = 0.0
	
	if Input.is_action_just_released(&"jump") and velocity.y > 0.0:
		velocity.y *= 0.5
		

##Даёт возможность прыгнуть, если нажал слишком поздно
func _update_coyote_time(delta: float) -> void:
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)


##Даёт возможность пргынуть, если нажал слишком рано 
func _update_jump_buffer(delta) -> void:
	if Input.is_action_just_pressed(&"jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer = maxf(jump_buffer_timer - delta, 0.0)
		

##Качание камеры при ходьбе
func _headbob_effect(delta) -> void:
	if not is_on_floor():
		return
	
	# Headbob
	headbob_timer += delta * velocity.length()
	camera.transform.origin = Vector3(
		cos(headbob_timer * HEADBOB_FREQUENCY * 0.5) * HEADBOB_MOVE_AMOUNT, 
		sin(headbob_timer * HEADBOB_FREQUENCY) * HEADBOB_MOVE_AMOUNT, 
		0
		)


## Наклон камеры влево/вправо
func _title_effect(delta) -> void:
	var tilt_amount := CAMERA_TILT_AMOUNT
	if Input.is_action_pressed(&"run"):
		tilt_amount *= 1.5
		
	var input_dir := Input.get_vector(&"left", &"right", &"up", &"down")
	var target_tilt := -input_dir.x * deg_to_rad(tilt_amount)
	
	camera.rotation.z = lerp(
		camera.rotation.z,
		target_tilt,
		CAMERA_TILT_SPEED * delta
	)
	

func _get_camera_relative_direction(input_direction: Vector2) -> Vector3:
	var camera_basis: Basis = camera_pivot.global_transform.basis

	var forward: Vector3 = -camera_basis.z
	var right: Vector3 = camera_basis.x

	# Движение происходит только по горизонтали.
	forward.y = 0.0
	right.y = 0.0

	forward = forward.normalized()
	right = right.normalized()

	return (
		right * input_direction.x
		- forward * input_direction.y
	).normalized()
	
	
func _rotate_visual(direction: Vector3, delta: float) -> void:
	if direction.is_zero_approx():
		return

	var target_yaw := atan2(
		-direction.x,
		-direction.z
	)

	var weight := 1.0 - exp(-12.0 * delta)

	visual_root.rotation.y = lerp_angle(
		visual_root.rotation.y,
		target_yaw,
		weight
	)
	
