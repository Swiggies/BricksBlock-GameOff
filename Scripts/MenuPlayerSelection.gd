""" Button Script, allow to select the # of Players & start the game
"""
extends Button

onready var game_variables = get_node("/root/GameVariables")
# export var NumberOfPlayers = 0	# The no of players this button is gonna load
var last_connection_status = [false, false, false, false]
var shake_strength = 20


func OnPress():
	get_tree().change_scene("res://Spatial.tscn")
	if get_tree().root.get_node("/root/Menu"):
		get_tree().root.remove_child(get_tree().root.get_node("/root/Menu"))

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
		if id in game_variables.PLYAER_JOY_ID.values():
			return
		for i in game_variables.PLYAER_JOY_ID:
			if game_variables.PLYAER_JOY_ID[i] == -1:
				game_variables.PLYAER_JOY_ID[i] = id
				return
	else:
		for i in game_variables.PLYAER_JOY_ID:
			if game_variables.PLYAER_JOY_ID[i] == id:
				game_variables.PLYAER_JOY_ID[i] = -1

func _process(delta):
	# Play Button
	if Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_select"):
		OnPress()
		return
	
	# NOTE: Not to be included in Prod (just the next 2 lines)
	if get_child_count() == 0:
		return

	# Light up the player icons for whom the controllers are connected, and set NumberOfPlayers
	game_variables.NumberOfPlayers = 0
	var key = ""
	for i in game_variables.PLYAER_JOY_ID:
		if game_variables.PLYAER_JOY_ID[i] == -1:
			key = "disconnected"
			last_connection_status[i] = false
		else:
			key = "player" + str(i+1)
			game_variables.NumberOfPlayers += 1
			if last_connection_status[i] == false:
				shake_child(get_child(i), 0)
			last_connection_status[i] = true
		get_child(i).modulate = game_variables.PLYAER_COLOR[key]

func shake_child(node, n):
	if not get_tree():
		return
	node = node as Sprite
	if n > shake_strength:
		return
	node.rotation_degrees = (shake_strength - n)/5 * (1 if n%2==0 else -1)
	n += 1
	var timer = get_tree().create_timer(0.02)
	timer.connect("timeout", self, "shake_child", [node, n])
	


### FOR TESTING PURPOSES ONLY ###
var flag = false
func _input(event):
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.scancode == KEY_1:
		flag = !flag
		_joy_connection_changed(0, flag)
	elif event.scancode == KEY_2:
		flag = !flag
		_joy_connection_changed(1, flag)
	elif event.scancode == KEY_3:
		flag = !flag
		_joy_connection_changed(2, flag)
	elif event.scancode == KEY_4:
		flag = !flag
		_joy_connection_changed(3, flag)

