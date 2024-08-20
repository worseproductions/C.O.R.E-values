extends CanvasLayer

@onready var healthbar: ProgressBar = %HealthBar
@onready var killcount: ProgressBar = %DataProgress
@onready var level_label: Label = %LevelLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.update_healthbar.connect(_on_update_health)
	GameManager.update_killcount.connect(_on_update_killcount)
	GameManager.update_level.connect(_on_update_level)

func _on_update_health(max_health, current):
	healthbar.max_value = max_health
	healthbar.value = current

func _on_update_killcount(kills, _kills_to_next_level):
	killcount.value = kills

func _on_update_level(level, kills_to_next_level):
	killcount.max_value = kills_to_next_level
	level_label.text = "Lvl %d" % level
