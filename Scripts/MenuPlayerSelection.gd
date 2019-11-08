""" Button Script, allow to select the # of Players & start the game
"""
extends Button

onready var game_variables = get_node("/root/GameVariables")
export var NumberOfPlayers = 0	# The no of players this button is gonna load

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func OnPress():
	game_variables.NumberOfPlayers = NumberOfPlayers
	get_tree().change_scene("res://Spatial.tscn")
