extends Area

### EXPERIMENTAL

func _ready():
	var sphere = get_parent().get_node("Sphere Bound/Icosphere")
	var player_coll = get_node("/root/KinematicPlayer/CollisionShape")
	var shape = get_node("Bound Shape")
	#get_node("MeshInstance").mesh = sphere.get_parent().get_child(2).mesh
	shape.make_convex_from_brothers()
	shape.scale = Vector3.ONE
	self.scale = sphere.scale * sphere.get_parent().scale * -1
	if player_coll:
		scale -= player_coll.scale * 2.0
	scale -= Vector3(0.5, 0.5, 0.5)
	print(shape.shape)
	print(scale)
	get_node("MeshInstance").queue_free()



func _on_Bound_Area_area_entered(area):
	print("Entered: ", (area.get_parent() as Node).name)


func _on_Bound_Area_area_exited(area):
	print("Exited: ", (area.get_parent() as Node).name)
