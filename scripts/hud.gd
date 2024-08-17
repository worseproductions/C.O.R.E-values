extends CanvasLayer

@onready var healthbar: ProgressBar = %HealthBar

@onready var player: Player = %Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_health_changed(player.max_health, player.health)
	player.health_changed.connect(_on_health_changed)

func _on_health_changed(new_max: int, new_value: int):
	print_debug("Health changed")
	healthbar.max_value = new_max
	healthbar.value = new_value
