class_name EnemyShooting
extends Enemy

@export var bullet_speed = 500
@export var accuracy = 0.8

@onready var bullet_scene = preload("res://components/bullet.tscn")

func attack_player():
	if not player.global_position.distance_to(global_position) <= attack_radius or not cooldown_timer.is_stopped():
		return
	var bullet_direction = player.global_position - global_position
	var random_offset = Vector2(randf_range(-accuracy, accuracy), randf_range(-accuracy, accuracy))
	bullet_direction += random_offset
	var bullet: Bullet = bullet_scene.instantiate()
	bullet.rotate(-bullet_direction.angle_to(Vector2.UP))
	bullet.damage = attack_damage
	add_child(bullet)
	bullet.position = bullet_direction.normalized() * 50
	bullet.apply_impulse(bullet_direction.normalized() * bullet_speed)
	cooldown_timer.start()
