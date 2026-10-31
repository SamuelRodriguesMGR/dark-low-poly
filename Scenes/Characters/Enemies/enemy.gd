extends Character


# плавные повороты туловищем
const SMOOTH_ROTATE : float = 7.0

@onready var player : CharacterBody3D = get_tree().current_scene.get_node("Player")
@onready var aim_raycast: RayCast3D = $RayCast3D
@onready var attack_component = %AttackComponent

##Процессы больше с движением, прыжком, гравитацией
func _physics_process(delta):
	if can_move:
		_enemy_movement()
	else:
		move_direction = Vector3.ZERO
	
	super._physics_process(delta)
	
	# Визуализация движения при поворотах
	_rotate_visual(move_direction, delta)
		
		
func _enemy_movement():
	if !player:
		return 
		
	var distance_to_player : float = (player.position - global_position).length()
	aim_raycast.target_position = player.position - global_position
	
	if is_instance_valid(player) and aim_raycast.get_collider() == player and distance_to_player < 35:
		move_direction = global_position.direction_to(player.global_position)
	else:
		move_direction = Vector3.ZERO


func _rotate_visual(direction: Vector3, delta: float) -> void:
	if direction.is_zero_approx():
		return

	var target_yaw := atan2(
		-direction.x,
		-direction.z
	)

	var weight := 1.0 - exp(-SMOOTH_ROTATE * delta)

	visual_root.rotation.y = lerp_angle(
		visual_root.rotation.y,
		target_yaw,
		weight
	)


func _on_attack_component_body_entered(body):
	pass # Replace with function body.
