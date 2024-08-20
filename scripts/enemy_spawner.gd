@tool
class_name EnemySpawner
extends Node2D

@export var level_1_enemy_types: Array[PackedScene]
@export var level_2_enemy_types: Array[PackedScene]
@export var level_3_enemy_types: Array[PackedScene]

@export var spawn_radius = 500.0:
	set(value):
		spawn_radius = value
		queue_redraw()
@export var spawn_amount = 4
@export var spawn_cooldown = 5.0

@onready var spawn_area = $Area2D
@onready var spawn_area_shape = $Area2D/CollisionShape2D
@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var shape := spawn_area_shape.shape as CircleShape2D
	shape.radius = spawn_radius
	spawn_area.body_entered.connect(_on_body_entered)
	timer.wait_time = spawn_cooldown

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, spawn_radius, Color.RED)

func _on_body_entered(body: Object):
	var player := body as Player
	if not player: return
	if timer.is_stopped():
		call_deferred("spawn_enemies")
	
func spawn_enemies():
	var level = GameManager.level
	var enemies: Array[PackedScene] = []
	match level:
		1, 2, 3: enemies = level_1_enemy_types
		4, 5, 6: enemies = level_2_enemy_types
		_: enemies = level_3_enemy_types
	var current_enemies = $Enemies.get_child_count()
	for _i in spawn_amount - current_enemies:
		var enemy_scene: PackedScene = enemies.pick_random()
		var enemy: Enemy = enemy_scene.instantiate()
		var random_jitter = Vector2(randf_range(-spawn_radius, spawn_radius), randf_range(-spawn_radius, spawn_radius))
		$Enemies.add_child(enemy)
		enemy.global_position = global_position + random_jitter
	timer.start()
