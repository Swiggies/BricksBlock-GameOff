extends RigidBody

# Declare member variables here. Examples:
export var speed = 10

var camera
var direction = Vector3()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if Input.is_action_pressed("move_forward"):
		direction = Vector3(0,0,1) * speed
	else:
		direction = Vector3(0,0,0)
		
	print(direction)	
	velocity