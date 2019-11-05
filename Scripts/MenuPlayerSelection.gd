""" Button Script, allow to select the # of Players & start the game
"""
extends Button

onready var player_variables = get_node("/root/PlayerVariables")
export var NumberOfPlayers = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func OnPress():
	player_variables.NumberOfPlayers = NumberOfPlayers
	get_tree().change_scene("res://Spatial.tscn")
