class_name Pickup
extends Node2D

enum PickupType {
	HEALTH,
	RUNNING_SPEED,
	SHOOTING_SPEED
}

@export var pickup_type: PickupType
@export var pickup_strength: float = 1
@export var time_to_live: int = 10

@onready var timer: Timer = $Timer
@onready var area: Area2D = $Area2D

func _ready() -> void:
	timer.wait_time = time_to_live
	timer.timeout.connect(func(): queue_free())
	area.body_entered.connect(_on_body_entered)
	

func _on_body_entered(body: Object):
	var player := body as Player
	if not player: return
	
	match pickup_type:
		PickupType.HEALTH:
			player.heal(ceil(pickup_strength))
		PickupType.RUNNING_SPEED:
			player.speed_boost(pickup_strength)
		PickupType.SHOOTING_SPEED:
			player.bullet_boost(pickup_strength)
	queue_free()
