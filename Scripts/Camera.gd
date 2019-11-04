extends Camera

export var sensitivty = 0.1

onready var TweenNode = get_node("Tween")
#onready var Player = get_node("/root/Spatial/KinematicPlayer") as KinematicBody
var start_y
var timer = 0
var is_tweening = false

# Called when the node enters the scene tree for the first time.
func _ready():
	start_y = translation.y
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	translation = get_parent().get_parent().get_parent().translation

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta * 5
	#translate(Vector3(0, start_y + sin(timer) * 0.3,0) * delta)
	#transform = Player.transform
	#transform.origin = Player.transform.origin
	translation = get_parent().get_parent().get_parent().translation
	rotation.y = get_parent().get_parent().get_parent().rotation.y
	

func _input(event):
	if event is InputEventMouseMotion:
		var position = Vector2(0,0)
		position += event.relative * sensitivty
		rotate_cam_x(-position.y)
		rotate_cam_y(-position.x)
		
func rotate_cam_x(x_rotation):
	rotate_x(x_rotation / 100)
	rotation_degrees.x = clamp(rotation_degrees.x, -90, 90)
	#Player.rotation_degrees.x = clamp(Player.rotation_degrees.x + rad2deg(x_rotation / 100), -90, 90)
	#pass
	
func rotate_cam_y(y_rotation):
	get_parent().get_parent().get_parent().rotate_y(y_rotation / 100)
	#get_tree().get_root().rotate_y(y_rotation / 100)
	#Player.rotate_y(y_rotation / 100)

func on_wallrun(dir, ray_hit):
	if ray_hit == true:
		TweenNode.interpolate_property(self, "rotation_degrees:z", rotation_degrees.z, dir.x * 10, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
		TweenNode.start()
	elif ray_hit == false:
		TweenNode.interpolate_property(self, "rotation_degrees:z", rotation_degrees.z, 0, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
		TweenNode.start()

func _on_tween_started(object, key):
	is_tweening = true


func _on_Tween_tween_started(object, key):
	pass # Replace with function body.


func _on_KinematicPlayer_on_wallrun():
	pass # Replace with function body.
