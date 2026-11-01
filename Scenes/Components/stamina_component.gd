class_name StaminaComponent extends Timer


@export var stamina_points : float = 100.0 : set = set_stamina
@export var MAX_STAMINA_POINT : float = 100.0

@onready var parent := get_parent()


func set_stamina(new_stamina : float) -> void:
	stamina_points = clamp(new_stamina, 0, MAX_STAMINA_POINT)
	parent.emit_signal("stamina_changed", stamina_points)
	

func _on_timeout():
	if parent.move_direction == Vector3.ZERO:
		stamina_points += 3
		return
		
	elif parent.movement_speed == parent.walk_speed:
		stamina_points += 1
		return
		
	elif parent.movement_speed == parent.sprint_speed:
		stamina_points -= 2
		return
	
	
	
