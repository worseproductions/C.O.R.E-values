extends VBoxContainer

@onready var button_destroy: Button = $ButtonDestroy
@onready var button_leave: Button = $ButtonLeave

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_destroy.pressed.connect(_on_button_destroy_pressed)
	button_leave.pressed.connect(_on_button_leave_pressed)

func _on_button_destroy_pressed():
	get_tree().change_scene_to_file("res://levels/destroy_core_ending.tscn")
	
func _on_button_leave_pressed():
	get_tree().change_scene_to_file("res://levels/leave_planet_ending.tscn")
