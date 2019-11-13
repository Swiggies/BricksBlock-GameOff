""" Instantiates the correct number of Players.
"""
extends Node

onready var game_variables = get_node("/root/GameVariables")

func _ready():
	if get_tree().current_scene.name != "Spatial":
		queue_free()
		return
	
	var playerID = 0
	
	for i in range(game_variables.NumberOfPlayers):
		var player_resource = preload("res://Prefabs/Player.tscn")
		var player = player_resource.instance()
		while game_variables.PLYAER_JOY_ID[playerID] == -1:
			playerID += 1
		player.myPlayerNumber = playerID
		playerID += 1
		player.set_translation(Vector3(i + 1 * 5, 5, i + 1 * 5))
		get_tree().root.add_child(player)
		
		# Just to test the culling mask.
		# TODO: Remove this after it has been approved.
		player.set_translation(Vector3(i + 1 * 5, 5, i + 1 * 5 + rand_range(-1, 1)))
	
	# Tell that players have been loaded
	game_variables.player_loaded = true
	
	# Delete this node now
	queue_free()
