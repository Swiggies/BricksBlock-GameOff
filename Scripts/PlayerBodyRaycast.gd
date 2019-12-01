extends RayCast

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const ray_distance = .75
export var resource_shape : Resource

signal on_hit
var input_vector : Vector2

onready var my_player_number = get_parent().myPlayerNumber
var game_variables

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
		if my_player_number == 0:
			if Input.is_action_pressed("move_left"):
				cast_to = Vector3(-1,0,0) * ray_distance
			elif Input.is_action_pressed("move_right"):
				cast_to = Vector3(1,0,0) * ray_distance
			else:
				cast_to = Vector3.ZERO
		else:
			cast_to = Vector3(Input.get_joy_axis(game_variables.PLYAER_JOY_ID[my_player_number], JOY_ANALOG_LX),0,0) * ray_distance
		emit_signal("on_hit", is_colliding(), cast_to, get_collision_normal())