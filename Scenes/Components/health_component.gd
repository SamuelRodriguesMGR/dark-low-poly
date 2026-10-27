class_name HealthComponent extends Node


@export var health_points : float = 100.0 : set = set_hp
@export var MAX_HEALTH_POINT : float = 100.0

@onready var parent := get_parent()

var last_attacker : Node3D

func take_damage(attacker : Node3D, damage : float) -> void: 
	last_attacker = attacker
	health_points -= damage
	print("Health : " + str(health_points) + "Damage ^ " + str(damage))
	if health_points <= 0:
		parent.queue_free()
		
func set_hp(new_hp : float) -> void:
	health_points = clamp(new_hp, 0, MAX_HEALTH_POINT)
	
