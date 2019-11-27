extends Node

onready var game_variables = get_node("/root/GameVariables")

func _ready():
	if not game_variables.DEBUG_MODE:
		OS.window_resizable = false
		OS.window_fullscreen = true
		OS.window_size = OS.get_screen_size()
	queue_free()