extends Node2D

@export var kills_to_next_infection: int = 1
@export var additional_kills_per_level: int = 2

var kills = 0
var level = 1

signal update_healthbar(max, current)
signal update_killcount(current, kills_to_next_level)
signal update_level(level, kills_to_next_level)

func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS

func update_health(new_max: int, new_value: int):
	update_healthbar.emit(new_max, new_value)
	if new_value <= 0:
		death()

func death():
	var death_overlay = get_tree().current_scene.get_node("%HUD/DeathOverlay")
	death_overlay.visible = true
	var label: Label = death_overlay.get_child(1)
	label.text = label.text % level
	get_tree().paused = true

func increase_kill_count():
	kills += 1
	update_killcount.emit(kills, kills_to_next_infection)

func next_level():
	level += 1
	if level > 8:
		var win_overlay: Control = get_tree().current_scene.get_node("%HUD/WinOverlay")
		win_overlay.visible = true
		get_tree().paused = true
		
	kills = 0
	kills_to_next_infection += additional_kills_per_level
	update_level.emit(level, kills_to_next_infection)
	var core_light: PointLight2D = get_tree().current_scene.get_node("%CoreLight")
	core_light.energy += 0.5

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		var overlay: Control = get_tree().current_scene.get_node("%HUD/PauseOverlay")
		overlay.visible = not get_tree().paused
		get_tree().paused = not get_tree().paused
		print_debug(get_tree().paused)
