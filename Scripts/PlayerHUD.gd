extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var health_label = $"Health BG/Label"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_health_change(health):
	health_label.text = str(health)+"%"