extends Camera

export var sensitivty = 0.1

onready var TweenNode = get_node("Tween")
onready var game_variables = get_node("/root/GameVariables")
onready var my_player_number = get_parent().get_parent().get_parent().myPlayerNumber
onready var my_player = get_parent().get_parent().get_parent()
var start_y
var timer = 0
var is_tweening = false
var camera_raycyast : RayCast
var camera_offset = Vector3(0,0.6,0)

var controller_sensitivty = -5
var x_axis = 0
var y_axis = 0
const deadzone = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	start_y = translation.y
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	translation = get_parent().get_parent().get_parent().translation + camera_offset
	cull_mask -= game_variables.VISUAL_LAYERS["player" + str(my_player.myPlayerNumber+1)]

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	translation = get_parent().get_parent().get_parent().translation + camera_offset
	rotation.y = get_parent().get_parent().get_parent().rotation.y

func _process(delta):
	if abs(Input.get_joy_axis(my_player_number - 1, JOY_ANALOG_RX)) > deadzone or abs(Input.get_joy_axis(my_player_number - 1, JOY_ANALOG_RY)) > deadzone:
		rotate_cam_y(Input.get_joy_axis(my_player_number - 1, JOY_ANALOG_RX) * controller_sensitivty)
		rotate_cam_x(Input.get_joy_axis(my_player_number - 1, JOY_ANALOG_RY) * controller_sensitivty)

func _input(event):
	if event.device != my_player_number:
		return
	
	if event is InputEventMouseMotion:
		var position = Vector2(0,0)
		position += event.relative * sensitivty
		rotate_cam_x(-position.y)
		rotate_cam_y(-position.x)
	if Input.is_action_just_pressed("attack"):
		knockback_other()
	
		
func knockback_other():
	var from = global_transform.origin
	var to = from + -global_transform.basis.z * 5
	var result = get_world().direct_space_state.intersect_ray(from, to, [self])
	if not result.empty():
		print("Other player gets knocked back")
#		print(result.get("collider").get_parent().translate(Vector3(0,50,0)))
		
func rotate_cam_x(x_rotation):
	rotation_degrees.x = clamp(rotation_degrees.x + rad2deg(x_rotation / 100), -90, 90)
	
func rotate_cam_y(y_rotation):
	get_parent().get_parent().get_parent().rotate_y(y_rotation / 100)

func on_wallrun(dir, ray_hit):
	if ray_hit == true:
		TweenNode.interpolate_property(self, "rotation_degrees:z", rotation_degrees.z, dir.x * 10, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
		TweenNode.start()
	elif ray_hit == false:
		TweenNode.interpolate_property(self, "rotation_degrees:z", rotation_degrees.z, 0, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
		TweenNode.start()

func _on_tween_started(object, key):
	is_tweening = true
