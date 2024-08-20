extends HBoxContainer

@onready var button_continue: Button = $ButtonContinue
@onready var button_quit: Button = $ButtonQuit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_continue.pressed.connect(_on_continue_pressed)
	button_quit.pressed.connect(_on_quit_pressed)

func _on_continue_pressed():
	get_parent().visible = false
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://levels/start.tscn")
