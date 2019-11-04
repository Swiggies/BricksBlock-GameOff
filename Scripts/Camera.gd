extends Camera

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var sensitivty = 0.1

onready var TweenNode = get_node("Tween")
onready var camera_raycast = get_node("CameraRaycast")
var start_y
var timer = 0
var is_tweening = false
var camera_raycyast : RayCast

# Called when the node enters the scene tree for the first time.
func _ready():
	start_y = translation.y
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta * 5
#	translate(Vector3(0, start_y + sin(timer) * 0.3,0) * delta)

func _input(event):
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
	get_parent_spatial().rotate_y(y_rotation / 100)

func on_wallrun(dir, ray_hit):
	if ray_hit == true:
		TweenNode.interpolate_property(self, "rotation_degrees:z", rotation_degrees.z, dir.x * 10, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
		TweenNode.start()
	elif ray_hit == false:
		TweenNode.interpolate_property(self, "rotation_degrees:z", rotation_degrees.z, 0, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
		TweenNode.start()

func _on_tween_started(object, key):
	is_tweening = true
