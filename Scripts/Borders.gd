extends Node

onready var game_variables = get_node("/root/GameVariables")

func _ready():
	if get_tree().current_scene.name != "Spatial":
		queue_free()
		return

func _process(delta):
	if game_variables.player_loaded == false:
		return
	
	for i in range(game_variables.NumberOfPlayers / 2):
		# Create a new Color Rect
		var border = ColorRect.new()
		
		# Color
		border.color = Color.black
		
		# Size
		border.rect_size = Vector2(2 if i==0 else get_viewport().size.x, get_viewport().size.y if i==0 else 2)
		border.rect_position = Vector2(get_viewport().size.x/2-1 if i==0 else 0, 0 if i==0 else get_viewport().size.y/2-1)
		
		# Add the border to hierarchy
		get_tree().root.add_child(border)
	
	# Delete this node
	queue_free()
