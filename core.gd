extends Node2D

@export var power: int

@onready var power_label: Label = %HUD/%PowerLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	power_label.text = "Power: %d" % power
	pass
