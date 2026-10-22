class_name HealthComponent extends Node


@export var health_points : float = 100.0 : set = set_hp
@export var MAX_HEALTH_POINT : float = 100.0

@onready var parent := get_parent()

var last_attacker : Node2D

func take_damage(attacker : Node2D, damage : float) -> void: 
	last_attacker = attacker
	health_points -= damage
	parent.sprite.modulate += Color(
		0.0, -1 / MAX_HEALTH_POINT, -1 / MAX_HEALTH_POINT, -0.65 / MAX_HEALTH_POINT
		)
	if health_points <= 0:
		parent.queue_free()
		
func set_hp(new_hp : float) -> void:
	health_points = clamp(new_hp, 0, MAX_HEALTH_POINT)
	
