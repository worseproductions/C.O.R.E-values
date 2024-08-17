extends CanvasLayer

@export var kills_to_next_infection: int = 2

var kills = 0

signal update_healthbar(max, current)
signal update_killcount(max, current, total)

func update_health(new_max: int, new_value: int):
	print_debug("Health changed")
	update_healthbar.emit(new_max, new_value)

func increase_kill_count():
	kills += 1
	update_killcount.emit(kills_to_next_infection, kills)

func next_level():
	kills = 0
	kills_to_next_infection += 1
