extends CSGMesh

export var rotate_speed = 3
onready var area_node = get_node("Area")

onready var game_variables = get_node("/root/GameVariables")

# Called when the node enters the scene tree for the first time.
func _ready():
	area_node.collision_layer = game_variables.COLLISION_LAYERS.powerup
	area_node.collision_mask = 0
	area_node.collision_mask += game_variables.COLLISION_LAYERS.player1
	area_node.collision_mask += game_variables.COLLISION_LAYERS.player2
	area_node.collision_mask += game_variables.COLLISION_LAYERS.player3
	area_node.collision_mask += game_variables.COLLISION_LAYERS.player4
	
	
	### Everythign's working correctly with Area. So commenting it out
	# area_node is the one with collision layers,
	# yet in my testing not having it on the msh would make the game skip the colission sometimes
	# copying them to the mesh as well
	#collision_layer = area_node.collision_layer
	#collision_mask = area_node.collision_mask


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	revolve(delta)

func revolve(delta):
	rotate_y(rotate_speed * delta)

func _on_area_entered(area):
	print("Powerup collected via area, area = ", area)
	queue_free()



### EXPERIMENTAL

func something():
	print(get_parent().get_parent().get_node("Bound Area/Bound Shape").shape)
	var m = get_parent().get_parent().get_node("Sphere Bound/Icosphere").mesh
	get_parent().get_parent().get_node("Bound Area/Bound Shape").shape = m.create_trimesh_shape()
	print(get_parent().get_parent().get_node("Bound Area/Bound Shape").shape)
	get_parent().get_parent().get_node("Bound Area/Bound Shape").scale = Vector3(14.0, 14.0, 14.0)



func _on_area_entered_sphere(area):
	print("Entered: ", area)


func _on_area_exited_sphere(area):
	print("Exited: ", area)


