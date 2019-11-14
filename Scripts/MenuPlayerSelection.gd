""" Button Script, allow to select the # of Players & start the game
"""
extends Button

onready var game_variables = get_node("/root/GameVariables")
export var NumberOfPlayers = 0    # The no of players this button is gonna load


func OnPress():
    game_variables.NumberOfPlayers = NumberOfPlayers
    get_tree().change_scene("res://Spatial.tscn")


func _ready():
    var numDevices = Input.get_connected_joypads().size()
    var deviceIDs = Input.get_connected_joypads()
    for i in range(numDevices):
        game_variables.PLYAER_JOY_ID[i] = deviceIDs[i]

    # Add a listner for joy connect/disconnect event
    Input.connect("joy_connection_changed", self, "_joy_connection_changed")

func _joy_connection_changed(id, connected):
    # If a new controller is connected, add it to PLYAER_JOY_ID dict
    # else remove it from the dict
    if(connected):
        for i in game_variables.PLYAER_JOY_ID:
            if game_variables.PLYAER_JOY_ID[i] == -1:
                game_variables.PLYAER_JOY_ID[i] = id
                return
    else:
        for i in game_variables.PLYAER_JOY_ID:
            if game_variables.PLYAER_JOY_ID[i] == id:
                game_variables.PLYAER_JOY_ID[i] = -1



func _process(delta):
    # NOTE: Not to be included in Prod (just the next 2 lines)
    if get_child_count() == 0:
        return

    # Light up the player icons for whom the controllers are connected
    for i in game_variables.PLYAER_JOY_ID:
        var key = "disconnected" if game_variables.PLYAER_JOY_ID[i] == -1 else "player" + str(i+1)
        get_child(i).modulate = game_variables.PLYAER_COLOR[key]