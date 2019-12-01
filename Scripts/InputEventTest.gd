extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var events = InputEvent.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	events.device = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if events.is_action_pressed("ui_select"):
		print(events)
	