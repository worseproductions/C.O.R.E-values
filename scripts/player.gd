class_name Player 
extends CharacterBody2D


@export var speed = 10 # Pixels/second.
@export var max_health = 100
@export var bullet_speed = 500
@export var shooting_cooldown = 0.5
@export var bullet_damage = 1
@export var charge_time = 2

@onready var cooldown: Timer = $Cooldown
@onready var charge: Timer = $Charge
var bullet: PackedScene = preload("res://components/bullet.tscn")

var health = max_health
var charge_started = false

signal health_changed(new_max: int, new_value: int)

func _ready() -> void:
	health_changed.emit(max_health, health)
	cooldown.wait_time = shooting_cooldown
	charge.wait_time = charge_time

func _input(event):
	if event.is_action_pressed("attack"):
		charge.start()
		charge_started = true
	if event.is_action_released("attack"):
		shoot(charge.is_stopped() and charge_started)
		charge.stop()
		charge_started = false

func _physics_process(_delta):
	var motion = Vector2()
	motion.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	motion.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	motion.y /= 2
	motion = motion.normalized() * speed
	position += motion
	move_and_slide()

func shoot(is_special: bool = false):
	if not cooldown.is_stopped():
		return
	var bullet_instance: Bullet = bullet.instantiate()
	bullet_instance.damage = bullet_damage if not is_special else bullet_damage * 2
	add_child(bullet_instance)
	var mouse_pos = get_global_mouse_position()
	var bullet_direction = mouse_pos - global_position
	bullet_instance.position = bullet_direction.normalized() * 50
	bullet_instance.apply_impulse(bullet_direction.normalized() * bullet_speed)
	cooldown.start()

func take_damage(damage: int):
	health -= damage
	health_changed.emit(max_health, health)

func heal(heal_amount: int):
	health += heal_amount
	health_changed.emit(max_health, health)
