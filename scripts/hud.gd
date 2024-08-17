extends CanvasLayer

@onready var game_manager: GameManager = $"/root/GameManager"
@onready var healthbar: ProgressBar = %HealthBar
@onready var killcount: ProgressBar = %DataProgress

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_manager.update_healthbar.connect(_on_update_health)
	game_manager.update_killcount.connect(_on_update_killcount)

func _on_update_health(max_health, current):
	healthbar.max_value = max_health
	healthbar.value = current

func _on_update_killcount(kills_to_next_infection, kills):
	killcount.max_value = kills_to_next_infection
	killcount.value = kills
