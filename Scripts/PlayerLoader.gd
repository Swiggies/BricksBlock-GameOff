""" Instantiates the correct number of Players.
"""
extends Node

onready var player_variables = get_node("/root/PlayerVariables")

func _ready():
	for i in range(player_variables.NumberOfPlayers):
		var player_resource = preload("res://Prefabs/Player.tscn")
		var player = player_resource.instance()
		player.myPlayerNumber = i
		player.set_translation(Vector3(i + 1 * 5, 5, i + 1 * 5))
		get_tree().root.add_child(player)
	# Delete this node now
	queue_free()
