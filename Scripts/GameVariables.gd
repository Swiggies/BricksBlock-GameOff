""" Singleton Data Store Class
"""
extends Node

const DEBUG_MODE = true


var NumberOfPlayers = 2		# Total Number of Players
var player_loaded = false
var bound_rad = null


enum COLLISION_LAYERS {
	default, # Everythign should be here, unless necessary
	player1,
	player2,
	player3,
	player4,
	powerup,
}
enum VISUAL_LAYERS {
	default, # Everythign should be here, unless necessary
	player1,
	player2,
	player3,
	player4,
}

var PLYAER_COLOR = {
	"player1": "ff0037",
	"player2": "00ff37",
	"player3": "37ffff",
	#"player3": "007cff",
	"player4": "ffff37",
	"disconnected": "8f8f8f",
}

var PLYAER_JOY_ID = {
	0: -1,
	1: -1,
	2: -1,
	3: -1,
}


func _ready():
	
	# Make the values of the collision layer bitwise ordered
	for i in COLLISION_LAYERS.keys():
		# COLLISION_LAYERS[i] = pow(2, COLLISION_LAYERS[i])
		COLLISION_LAYERS[i] = 1 << COLLISION_LAYERS[i]
	
	# Make the values of the visual sortling layer bitwise ordered
	for i in VISUAL_LAYERS.keys():
		# VISUAL_LAYERS[i] = pow(2, VISUAL_LAYERS[i])
		VISUAL_LAYERS[i] = 1 << VISUAL_LAYERS[i]

func all_collision_layer_bit_number():
	return pow(2, COLLISION_LAYERS.size()) - 1

func all_visual_layer_bit_number():
	return pow(2, VISUAL_LAYERS.size()) - 1


### Experiment ###
func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().current_scene.name == "Spatial":
			#get_tree().root.print_tree()
			while get_tree().root.get_child_count() > 1:
				get_tree().root.remove_child(get_tree().root.get_child(1))
			get_tree().change_scene("res://Menu.tscn")
			player_loaded = false
			return
		else:
			get_tree().quit()

	