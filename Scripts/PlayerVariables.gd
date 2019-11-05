""" Singleton Data Store Class
"""
extends Node

var NumberOfPlayers = 2		# Total Number of Players
var playersCalled = 0		# Used to help players get their player number

func GetPlayerNumber():
	# Players call this to get a player number
	# NOTE: Calling this method incorrectly can break the game, casuing less the required number of players to instantiate
	# We can instead index the caller and assign them number accordingly if we want to prevent this
	playersCalled += 1
	return NumberOfPlayers - playersCalled
