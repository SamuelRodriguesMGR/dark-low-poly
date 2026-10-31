extends Character


# === НАСТРОЙКИ ПОВЕДЕНИЯ ===
@export_category("Enemy Behavior")
@export var attack_range: float = 1.3       # Дистанция для атаки
@export var chase_range: float = 35.0        # Дистанция преследования
@export var circle_strafe_speed: float = 4.0 # Скорость обхода по кругу
@export var circle_strafe_duration: float = 2.0  # Длительность обхода по кругу
@export var attack_cooldown: float = 1.5     # Пауза между атаками

@export var retreat_distance: float = 4.0    # Как далеко отступать
@export var retreat_speed: float = 6.0       # Скорость отступления
@export var retreat_chance: float = 0.0      # Шанс отступления после атаки (0-1)

# === СОСТОЯНИЕ ВРАГА ===
var attack_timer: float = 0.0
var circle_strafe_timer: float = 0.0
var circle_strafe_direction: float = 1.0  # 1 или -1 (по/против часовой)
var wants_to_attack: bool = false
var wants_to_retreat: bool = false
var face_to_player : bool = true



@onready var player : CharacterBody3D = get_tree().current_scene.get_node("Player")
@onready var aim_raycast: RayCast3D = $RayCast3D
@onready var attack_component = %AttackComponent


##Процессы больше с движением, прыжком, гравитацией
func _physics_process(delta):
	attack_timer = max(attack_timer - delta, 0.0)
	circle_strafe_timer = max(circle_strafe_timer - delta, 0.0)
	
	if can_move:
		_enemy_movement()
		
	else:
		move_direction = Vector3.ZERO
	
	super._physics_process(delta)
	
	if face_to_player:
		_rotate_visual(aim_raycast.target_position, delta)
		
	else:
		_rotate_visual(move_direction, delta)
		
		
func _enemy_movement():
	if !is_instance_valid(player):
		return 
		
	var distance_to_player : float = (player.position - global_position).length()
	aim_raycast.target_position = player.position - global_position
	
		
	var can_see_player: bool = (
		is_instance_valid(player) 
		and aim_raycast.get_collider() == player 
		and distance_to_player < chase_range
	)
	# Если не видит игрока - стоит
	if not can_see_player:
		move_direction = Vector3.ZERO
		return
	
	# Состояния преследования делятся на 3:
	# Если игрок в зоне атаки врага - обходим по кругу или готовимся к атаке
	# Если средняя дистанция - медленно подходим
	# Далеко - бежим к игроку
	
	if distance_to_player <= attack_range:
		if circle_strafe_timer > 0.0:
			_circle_strafe()
		else:
			move_direction = Vector3.ZERO
			
	elif distance_to_player <= attack_range + 2.0:
		move_direction = global_position.direction_to(player.global_position)
		movement_speed = 2.0  
	
	else:
		move_direction = global_position.direction_to(player.global_position)
		movement_speed = 5.0 


func _circle_strafe():
	face_to_player = false
	# Обход по кругу вокруг игрока
	var to_player: Vector3 = global_position.direction_to(player.global_position)
	var perpendicular: Vector3 = Vector3(-to_player.z, 0, to_player.x) * circle_strafe_direction
	
	move_direction = perpendicular.normalized()
	movement_speed = circle_strafe_speed


## Проверяет, должен ли враг атаковать
func should_attack() -> bool:
	if !is_instance_valid(player):
		return false
	
	var distance_to_player: float = global_position.distance_to(player.global_position)
	
	# Атакуем если: близко, нет кулдауна, видим игрока
	if (
		distance_to_player <= attack_range
		and attack_timer <= 0.0
		and aim_raycast.get_collider() == player
	):
		attack_timer = attack_cooldown
		face_to_player = true
		
		# Решаем, будем ли отступать после атаки
		# Иначе будем обходить по кругу
		if randf() < retreat_chance:
			wants_to_retreat = true
		else:
			circle_strafe_timer = circle_strafe_duration
			circle_strafe_direction = 1.0 if randf() > 0.5 else -1.0
		
		return true
	
	return false

## Проверяет, должен ли враг отступать
func should_retreat() -> bool:
	if wants_to_retreat:
		wants_to_retreat = false
		return true
	return false
	
