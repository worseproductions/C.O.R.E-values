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
@onready var speed_boost_info: Control = get_tree().current_scene.get_node("%SpeedBoostInfo")
@onready var speed_boost_info_progress_bar: Control = get_tree().current_scene.get_node("%SpeedBoostInfo/ProgressBar")
@onready var shooting_speed_boost_info: Control = get_tree().current_scene.get_node("%ShootingSpeedBoostInfo")
@onready var shooting_speed_boost_info_progress_bar: Control = get_tree().current_scene.get_node("%ShootingSpeedBoostInfo/ProgressBar")
var bullet: PackedScene = preload("res://components/bullet.tscn")

var health = max_health
var charge_started = false
var speed_boost_amount = 1.0
var bullet_boost_amount = 1.0

func _ready() -> void:
	GameManager.update_health(max_health, health)
	cooldown.wait_time = shooting_cooldown
	charge.wait_time = charge_time
	bullet_boost_timer.timeout.connect(func(): 
		cooldown.wait_time = shooting_cooldown
		shooting_speed_boost_info.visible = false
	)
	speed_boost_timer.timeout.connect(func(): 
		speed_boost_amount = 1
		speed_boost_info.visible = false
	)

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

func _process(_delta: float) -> void:
	if not speed_boost_timer.is_stopped():
		speed_boost_info_progress_bar.value = speed_boost_timer.time_left
	if not bullet_boost_timer.is_stopped():
		shooting_speed_boost_info_progress_bar.value = bullet_boost_timer.time_left

func shoot(is_special: bool = false):
	if not cooldown.is_stopped():
		return
	var bullet_instance: Bullet = bullet.instantiate()
	bullet_instance.damage = bullet_damage if not is_special else bullet_damage * 2
	add_child(bullet_instance)
	var mouse_pos = get_global_mouse_position()
	var bullet_direction = mouse_pos - global_position
	bullet_instance.rotate(-bullet_direction.angle_to(Vector2.UP))
	bullet_instance.direction = bullet_direction.normalized()
	bullet_instance.position = bullet_direction.normalized() * 50
	bullet_instance.apply_impulse(bullet_direction.normalized() * bullet_speed)
	cooldown.start()

func take_damage(damage: int):
	health -= damage
	GameManager.update_health(max_health, health)

func heal(heal_amount: int):
	health += heal_amount
	if health >= max_health:
		health = max_health
	GameManager.update_health(max_health, health)

func speed_boost(amount: float):
	speed_boost_timer.start()
	speed_boost_amount = amount
	speed_boost_info.visible = true
	speed_boost_info_progress_bar.max_value = speed_boost_timer.wait_time
	speed_boost_info_progress_bar.value = speed_boost_timer.wait_time

func bullet_boost(amount: float):
	bullet_boost_timer.start()
	cooldown.wait_time *= 1 / amount
	shooting_speed_boost_info.visible = true
	shooting_speed_boost_info_progress_bar.max_value = speed_boost_timer.wait_time
	shooting_speed_boost_info_progress_bar.value = speed_boost_timer.wait_time
