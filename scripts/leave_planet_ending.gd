extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var menu_button: Button = $CanvasLayer/Control/Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false
	animation_player.current_animation = "leave_planet"
	animation_player.play()
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(_name: String):
	menu_button.disabled = false
	menu_button.pressed.connect(_on_menu_button_pressed)


func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://levels/start.tscn")
