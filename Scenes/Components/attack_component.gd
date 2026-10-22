class_name AttackComponent extends Node


@export var damage_points : float = 0

@onready var parent := get_parent()

func attack(enity) -> void:
	if enity != null and enity != owner and enity.has_node("HealthComponent"):
		enity.get_node("HealthComponent").take_damage(parent, damage_points)
		

	
