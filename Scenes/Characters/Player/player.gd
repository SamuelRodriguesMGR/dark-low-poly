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

# variables
var coyote_timer : float = 0.0
var jump_buffer_timer := 0.0
var headbob_timer : float = 0.0

# Nodes
@onready var camera : Camera3D = get_node(^"%Camera3D")
@onready var body : Node3D = get_node(^"Body")
@onready var head : Node3D = get_node(^"%Head") 

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

##Процессы больше с интерфейсом и камерой
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return

	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if not can_move:
		return

	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			_rotate_camera(event.relative)


func _rotate_camera(mouse_motion: Vector2) -> void:
	body.rotate_y(-mouse_motion.x * MOUSE_SENSITIVITY)

	head.rotate_x(-mouse_motion.y * MOUSE_SENSITIVITY)

	head.rotation.x = clamp(
		head.rotation.x,
		deg_to_rad(-90.0),
		deg_to_rad(90.0)
	)
	
	
##Процессы больше с движением, прыжком, гравитацией
func _physics_process(delta):
	if not can_move:
		_stop_movement(delta)
		move_and_slide()
		return
		
	_handle_movement(delta)
	
	_update_coyote_time(delta)
	_update_jump_buffer(delta)
	_handle_jump()
	
	_apply_gravity(delta)
	
	move_and_slide()
	
	_headbob_effect(delta)
	_title_effect(delta)
	
	
func _handle_movement(delta: float) -> void:
	var input_dir := Input.get_vector(&"left", &"right", &"up", &"down")
	move_direction = (body.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	var target_velocity := move_direction * (sprint_speed if Input.is_action_pressed(&"run") else walk_speed)

	var current_acceleration := acceleration
	
	# плавная остановка
	if move_direction == Vector3.ZERO:
		current_acceleration = deceleration

	velocity.x = move_toward(
		velocity.x,
		target_velocity.x,
		current_acceleration * delta
	)

	velocity.z = move_toward(
		velocity.z,
		target_velocity.z,
		current_acceleration * delta
	)

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
