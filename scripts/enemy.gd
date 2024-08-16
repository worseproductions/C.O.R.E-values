extends CharacterBody2D


@export var speed = 300.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var player: CharacterBody2D = %Player

func _ready() -> void:
	nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func set_movement_target(movement_target: Vector2):
	nav_agent.set_target_position(movement_target)

func _physics_process(delta):
	nav_agent.target_position = player.global_position
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

func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()
