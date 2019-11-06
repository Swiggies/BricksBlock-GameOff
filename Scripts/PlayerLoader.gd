""" Instantiates the correct number of Players.
"""
extends Node

onready var player_variables = get_node("/root/PlayerVariables")

func _ready():
	for i in range(player_variables.NumberOfPlayers):
		get_tree().root.add_child(load("res://Prefabs/Player.tscn").instance())
	
	# Delete this node now
	queue_free()
