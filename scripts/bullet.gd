class_name Bullet
extends RigidBody2D

var damage = 1
var direction = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.timeout.connect(destroy)
	body_entered.connect(destroy)
	


func destroy(body: Object = null):
	var enemy := body as Enemy
	if enemy:
		enemy.take_damage(damage, direction)
	var player := body as Player
	if player:
		player.take_damage(damage)
	queue_free()
