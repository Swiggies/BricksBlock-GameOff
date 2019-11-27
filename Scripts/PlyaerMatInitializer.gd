extends MeshInstance

onready var game_variables = get_node("/root/GameVariables")

func apply_color(my_number):
	var mat = get_surface_material(0).duplicate()
	mat.albedo_color = game_variables.PLYAER_COLOR["player" + str(my_number+1)]
	for i in [0,2,3,4,5,15,16,17,18]:
		set_surface_material(i, mat)
