class_name Character extends CharacterBody3D


const FRICTION : float = 0.1

# Setttings
@export_category("Movement")
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 7.5
@export var jump_velocity: float = 5.0

##Чем выше этот параметр, тем быстрее скорость движения накапливается 
##до нужной (при ходьбе или беге)
@export var acceleration: float = 12.0
##Чем ниже этот параметр, тем дольше останавливается
@export var deceleration: float = 16.0


# variables
var can_move: bool = true
var move_direction: Vector3 



##Гравитация
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Возвращаем игрока вверх, если он упал слишком низко
	if global_position.y < -50.0:
		velocity.y = jump_velocity * 7.0


func _stop_movement(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)
	velocity.z = move_toward(velocity.z, 0.0, deceleration * delta)

#func _play_footstep_sound() -> void:
	#if not sound_steps.playing:
		#sound_steps.pitch_scale = randf_range(0.9, 1.1)  # Случайная высота тона для разнообразия
		#sound_steps.play()
