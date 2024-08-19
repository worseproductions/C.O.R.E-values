class_name Enemy
extends CharacterBody2D

enum EnemyState {
	PATROL,
	CHASE,
	SEARCH,
	ATTACK
}

@export var patrol_speed = 50.0
@export var chase_speed = 300.0
@export var search_speed = 200.0
@export var search_radius = 300.0
@export var patrol_radius = 150.0
@export var attack_radius = 50.0
@export var attack_damage = 5
@export var crit_damage = 10
@export var crit_chance = 0.1
@export var attack_cooldown = 1.0
@export var state: EnemyState = EnemyState.PATROL
@export var max_health = 10
@export_range(0, 1) var drop_chance = 0.5

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var player: Player = %Player
@onready var ray_cast: RayCast2D = $RayCast2D
@onready var cooldown_timer: Timer = $AttackCooldown
@onready var game_manager: GameManager = $"/root/GameManager"
@onready var health = max_health

@onready var health_pickup = preload("res://components/pickup_health.tscn")
@onready var speed_pickup = preload("res://components/pickup_speed.tscn")
@onready var bullet_speed_pickup = preload("res://components/pickup_shooting_speed.tscn")

var last_known_pos: Vector2

signal health_changed(max, current)

func _ready() -> void:
	nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	cooldown_timer.wait_time = attack_cooldown

func set_movement_target(movement_target: Vector2):
	nav_agent.set_target_position(movement_target)

#func _draw() -> void:
	#draw_circle(Vector2.ZERO, search_radius, Color.ANTIQUE_WHITE, false)
	#draw_circle(Vector2.ZERO, patrol_radius, Color.AQUAMARINE, false)
	#draw_circle(Vector2.ZERO, attack_radius, Color.BROWN, false)

func _physics_process(_delta: float):
	ray_cast.target_position = player.global_position - ray_cast.global_position
	if state == EnemyState.PATROL:
		if (player.global_position.distance_to(global_position) <= search_radius and not ray_cast.is_colliding()):
			state = EnemyState.CHASE
		if nav_agent.is_navigation_finished():
			var random_pos = get_random_pos_in_radius()
			nav_agent.target_position = global_position + random_pos
		navigate(patrol_speed)
	elif state == EnemyState.CHASE:
		if player.global_position.distance_to(global_position) > search_radius or ray_cast.is_colliding():
			state = EnemyState.SEARCH
		if player.global_position.distance_to(global_position) <= attack_radius and not ray_cast.is_colliding():
			state = EnemyState.ATTACK
		nav_agent.target_position = player.global_position
		navigate(chase_speed)
	elif state == EnemyState.SEARCH:
		if player.global_position.distance_to(global_position) <= search_radius and not ray_cast.is_colliding():
			state = EnemyState.CHASE
		if nav_agent.is_navigation_finished():
			state = EnemyState.PATROL
		navigate(search_speed)
	elif state == EnemyState.ATTACK:
		if player.global_position.distance_to(global_position) > attack_radius:
			state = EnemyState.CHASE
		nav_agent.target_position = player.global_position
		navigate(chase_speed)
		attack_player()


func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()


func navigate(speed: float):
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0:
		return
	if nav_agent.is_navigation_finished():
		return

	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * speed
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func get_random_pos_in_radius() -> Vector2:
	var random_radius = randf_range(0, patrol_radius)
	var random_angle = randf_range(0, 360)
	
	var x = random_radius * cos(random_angle)
	var y = random_radius * sin(random_angle)
	
	return Vector2(x, y)

func attack_player():
	if not player.global_position.distance_to(global_position) <= attack_radius or not cooldown_timer.is_stopped():
		return
	var damage = attack_damage
	if randf() < crit_chance:
		damage = crit_damage
	player.take_damage(damage)
	cooldown_timer.start()

func take_damage(damage: int, direction: Vector2):
	health -= damage
	state = EnemyState.SEARCH
	nav_agent.target_position = global_position - direction * search_radius
	health_changed.emit(max_health, health)
	if health <= 0:
		game_manager.increase_kill_count()
		if (randf() < drop_chance):
			match randi_range(0, 2):
				0: drop(health_pickup)
				1: drop(speed_pickup)
				2: drop(bullet_speed_pickup)
		queue_free()

func drop(scene: PackedScene):
	var dropped_item: Pickup = scene.instantiate()
	add_sibling(dropped_item)
	dropped_item.global_position = global_position
