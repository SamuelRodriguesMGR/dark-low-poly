class_name Character extends CharacterBody3D


const FRICTION : float = 0.1

# Setttings
@export_category("Movement")
@export var movement_speed: float = 5.0
##Чем выше этот параметр, тем быстрее скорость движения накапливается до нужной (при ходьбе или беге)
@export var acceleration: float = 12.0
##Чем ниже этот параметр, тем дольше останавливается
@export var deceleration: float = 30.0

@onready var visual_root: Node3D = get_node("VisualRoot")
@onready var finite_state_machine = $FiniteStateMachine

# variables
var can_move: bool = true
var override_movement: bool = false
var move_direction: Vector3 = Vector3.ZERO
 

func _physics_process(delta):
	# Если движение не перехвачено (например, перекатом), обрабатываем нормально
	if not override_movement:
		if can_move:
			_handle_movement(delta)
		else:
			move_direction = Vector3.ZERO
			_stop_movement(delta)
	
	_apply_gravity(delta)
	move_and_slide()


# Movement
func _handle_movement(delta: float) -> void:
	var target_velocity: Vector3 = move_direction * movement_speed

	var current_acceleration := (
		acceleration
		if not move_direction.is_zero_approx()
		else deceleration
	)

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

func _stop_movement(delta: float) -> void:
	velocity.x = move_toward(
		velocity.x, 0.0, deceleration * delta
	)

	velocity.z = move_toward(
		velocity.z, 0.0, deceleration * delta
	)


##Гравитация
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Возвращаем игрока вверх, если он упал слишком низко
	if global_position.y < -50.0:
		velocity.y = 6 * 7.0
