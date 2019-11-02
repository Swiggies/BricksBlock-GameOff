extends KinematicBody

export var speed = 10
export var gravity = -9.8
export var jump_force = 5
export var accelleration = 4.5
export var decelleration = 14

var camera
signal on_wallrun
var wallrun_dir

var direction : Vector3
var vel : Vector3
var ray_hit : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	process_input(delta)
	wallrun()
	process_movement(delta)
	
func wallrun():
	emit_signal("on_wallrun", wallrun_dir, ray_hit)
	if(ray_hit):
		vel.y = 0
	
func process_movement(delta):	
	direction.y = 0
	direction = direction.normalized()
	
	vel.y += delta * gravity
	
	var hvel = vel
	hvel.y = 0
	
	var target = direction
	target *= speed
	
	var accel
	if direction.dot(hvel) > 0:
		accel = accelleration
	else:
		accel = decelleration
	
	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0,1,0), 0.05, 4, deg2rad(65))
	
func process_input(delta):
	direction = Vector3()
	
	var input_movement = Vector2()
	
	if Input.is_action_pressed("move_forward"):
		input_movement.y += 1
	if Input.is_action_pressed("move_back"):
		input_movement.y -= 1
	if Input.is_action_pressed("move_right"):
		input_movement.x += 1
	if Input.is_action_pressed("move_left"):
		input_movement.x -= 1
	
		
	input_movement = input_movement.normalized()
	
	direction += -transform.basis.z * input_movement.y
	direction += transform.basis.x * input_movement.x
	
	if Input.is_action_just_pressed("ui_accept"):
		vel.y = jump_force

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	direction = move_and_slide(direction)

func on_hit(hit, dir, normal):
	ray_hit = hit
	wallrun_dir = dir
