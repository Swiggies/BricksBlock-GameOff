""" Singleton Data Store Class
"""
extends Node

var NumberOfPlayers = 2		# Total Number of Players
var player_loaded = false


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
	"player4": "ffff37",
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


# Not needed anymore, left for ref purposes
"""
var playersCalled = 0		# Used to help players get their player number

func GetPlayerNumber():
	# Players call this to get a player number
	# NOTE: Calling this method incorrectly can break the game, casuing less the required number of players to instantiate
	# We can instead index the caller and assign them number accordingly if we want to prevent this
	playersCalled += 1
	return NumberOfPlayers - playersCalled
"""
