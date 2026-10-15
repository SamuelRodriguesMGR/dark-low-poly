extends FiniteStateMachine



const LOCOMOTION_BLEND: StringName = &"parameters/LocomotionBlend/blend_amount"
const ATTACK_REQUEST: StringName = &"parameters/AttackOneShot/request"
const ATTACK_ACTIVE: StringName = &"parameters/AttackOneShot/active"
const ROLL_REQUEST: StringName = &"parameters/RollOneShot/request"
const ROLL_ACTIVE: StringName = &"parameters/RollOneShot/active"
	
@onready var animation_tree: AnimationTree = parent.get_node("AnimationTree")

var blend_speed: float = 6.0 
var run_value: float = 0.0
var previous_can_move: bool = true
var lock_movement_during_attack: bool = true 

# Направление переката (передаётся в скрипт игрока)
var roll_direction: Vector3 = Vector3.ZERO


func _init() -> void:
	_add_state("locomotion")
	_add_state("attack")
	_add_state("roll")


func _ready() -> void:
	set_state(states.locomotion)


func _state_logic(delta: float) -> void:
	_update_locomotion(delta)


func _get_transition() -> int:
	match state:
		states.locomotion:
			if (
				parent.can_move
				and parent.is_on_floor()
				and Input.is_action_just_pressed(&"attack")
			):
				return states.attack
			
			if (
				parent.can_move
				and parent.is_on_floor()
				and Input.is_action_just_pressed(&"roll")
			):
				return states.roll

		states.attack:
			var attack_active: bool = animation_tree.get(ATTACK_ACTIVE)

			if not attack_active:
				return states.locomotion
		
		states.roll:
			var roll_active: bool = animation_tree.get(ROLL_ACTIVE)
			if not roll_active:
				return states.locomotion
				
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.locomotion:
			pass

		states.attack:
			previous_can_move = parent.can_move

			if lock_movement_during_attack:
				parent.can_move = false

			animation_tree.set(
				ATTACK_REQUEST,
				AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
			)
		
		states.roll:
			# Определяем направление переката
			var input_dir := Input.get_vector(&"left", &"right", &"up", &"down")
			if input_dir.is_zero_approx():
				# Нырок вперёд по камере
				roll_direction = -parent.camera_pivot.global_transform.basis.z
				roll_direction.y = 0.0
				roll_direction = roll_direction.normalized()
			else:
				# Нырок в сторону ввода
				roll_direction = parent._get_camera_relative_direction(input_dir)
			
			# Запускаем анимацию переката
			animation_tree.set(
				ROLL_REQUEST,
				AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
			)

func _exit_state(exited_state: int) -> void:
	if exited_state == states.attack:
		parent.can_move = previous_can_move


# AnimationTree
func _update_locomotion(delta: float) -> void:
	var horizontal_speed := Vector2(
		parent.velocity.x,
		parent.velocity.z
	).length()

	# Скорость, при которой Blend2 полностью переключается на Run.
	var target_value := clampf(
		horizontal_speed / 7.5,
		0.0,
		1.0
	)

	var weight := 1.0 - exp(-blend_speed * delta)

	run_value = lerpf(
		run_value,
		target_value,
		weight
	)

	animation_tree.set(
		LOCOMOTION_BLEND,
		run_value
	)
