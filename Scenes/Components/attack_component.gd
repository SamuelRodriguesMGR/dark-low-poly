class_name AttackComponent extends Area3D


@export var damage_points : float = 0
@export var delay_attack : float = 0.5
@export var knockback_force : float = 10

@onready var parent := get_parent()
@onready var collision : CollisionShape3D = get_child(0)

var knockback_direction : Vector3 = Vector3.ZERO
var timer     : Timer = Timer.new()
var body_inside : bool = false
var activate : bool = false

func _init():
	var __ = connect("body_entered", Callable(self, "_on_body_entered"))
	__ = connect("body_exited", Callable(self, "_on_body_exited"))
	
func _ready():
	add_child(timer)
	timer.autostart = true
	# Ошибка если нету коллизии
	assert(collision != null)
	
func _on_body_entered(body):
	body_inside = true
	timer.start(delay_attack)
	# Пока зона урона внутри тела, будет наноситься урон с частотой в timer
	while body_inside:
		if not is_instance_valid(body):
			return
			
		if body in get_overlapping_bodies() and activate:
			activate = false
			_attack(body)
			
		await timer.timeout

func _on_body_exited(_body):
	body_inside = false
	timer.stop()

func _attack(body) -> void:
	if body != null and body != owner and body.has_node("HealthComponent"):
		body.get_node("HealthComponent").take_damage(parent, damage_points)
