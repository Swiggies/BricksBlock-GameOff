""" Menu BG Camera
Menu BG camera, revolves around the main game level
"""
extends Camera

export var rotation_speed = 0.2
#var main_scene = load("res://Spatial.tscn").instance() as Spatial

func _ready():
	#get_node("/root/Menu")
	#add_child(main_scene)
	#main_scene.translation.y =- 7
	#main_scene.translation.z = -25
	
	
	if get_tree().current_scene.name != "Menu":
		queue_free()
		return
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#main_scene.rotation.y += rotation_speed * delta
	get_node("Spatial").rotation.y += rotation_speed * delta
