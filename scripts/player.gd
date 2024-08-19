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
@onready var speed_boost_timer: Timer = $SpeedBoostTimer
@onready var bullet_boost_timer: Timer = $BulletBoostTimer
@onready var game_manager: GameManager = $"/root/GameManager"
var bullet: PackedScene = preload("res://components/bullet.tscn")

var health = max_health
var charge_started = false
var speed_boost_amount = 1.0
var bullet_boost_amount = 1.0

func _ready() -> void:
	game_manager.update_health(max_health, health)
	cooldown.wait_time = shooting_cooldown
	charge.wait_time = charge_time
	bullet_boost_timer.timeout.connect(func(): cooldown.wait_time = shooting_cooldown)
	speed_boost_timer.timeout.connect(func(): speed_boost_amount = 1)

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
	motion = motion.normalized() * speed * speed_boost_amount
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
	bullet_instance.direction = bullet_direction.normalized()
	bullet_instance.position = bullet_direction.normalized() * 50
	bullet_instance.apply_impulse(bullet_direction.normalized() * bullet_speed)
	cooldown.start()

func take_damage(damage: int):
	health -= damage
	game_manager.update_health(max_health, health)

func heal(heal_amount: int):
	health += heal_amount
	game_manager.update_health(max_health, health)

func speed_boost(amount: float):
	speed_boost_timer.start()
	speed_boost_amount = amount

func bullet_boost(amount: float):
	bullet_boost_timer.start()
	cooldown.wait_time *= 1 / amount
