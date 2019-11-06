extends KinematicBody

export var speed = 5
export var gravity = -9.8
export var jump_force = 5
export var accelleration = 4.5
export var decelleration = 14
export var kick_force = 50

var default_acceleration
var default_decelleration
var default_speed

var air_decelleration = 4.5
var air_acceleration = 4.5

var percent_health
var camera
signal on_wallrun
var wallrun_dir

var direction : Vector3
var vel : Vector3
var wall_normal : Vector3
var ray_hit : bool
var input_movement : Vector2

onready var player_variables = get_node("/root/PlayerVariables")
var myPlayerNumber = -1

onready var myViewportContainer = get_node("ViewportContainer")

# Called when the node enters the scene tree for the first time.
func _ready():
	default_acceleration = accelleration
	default_decelleration = decelleration
	default_speed = speed
	myPlayerNumber = player_variables.GetPlayerNumber()
	setUpInitPosition()
	setUpViewport()

func setUpInitPosition():
	# Random position to prevent the player from colliding into each other and get thrown off due to physics
	# A Temp Fix. Should be spawned at predetermined designated positions 
	translation = Vector3(rand_range(-5, 5), 1, rand_range(-5, 5))
	rotation = Vector3.ZERO
	

func setUpViewport():
	# Legacy Code - Deletes any extra player instantiated
	if myPlayerNumber < 0 or myPlayerNumber > player_variables.NumberOfPlayers - 1:
		queue_free()
	
	# Set the anchor
	myViewportContainer.anchor_left = 0 if myPlayerNumber % 2 == 0 else 0.5
	myViewportContainer.anchor_right = 1 if myPlayerNumber % 2 == 1 else 0.5
	myViewportContainer.anchor_top = 0 if myPlayerNumber < 2 else 0.5
	myViewportContainer.anchor_bottom = 0 if myPlayerNumber < 2 else 0.5
	
	# Set Viewport Size (as all will have the same view port size, this could be calculated just once
	# Though there's much of a performance hit either way
	var size = get_viewport().size
	var viewportSize = size
	viewportSize.x /= 2
	viewportSize.y /= 1 if player_variables.NumberOfPlayers == 2 else 2
	myViewportContainer.rect_size = viewportSize
	
	# Set Position
	myViewportContainer.rect_position.x = 0 if myPlayerNumber % 2 == 0 else viewportSize.x
	myViewportContainer.rect_position.y = 0 if myPlayerNumber < 2 else viewportSize.y

func _process(delta):
	# TODO: Remove this once the controllers have been set up to accept input only from the correct device
	if myPlayerNumber != 0:
		return

	process_input(delta)
	wallrun()
	process_movement(delta)
	
func wallrun():
	emit_signal("on_wallrun", wallrun_dir, ray_hit)
	if(ray_hit):
		accelleration = air_acceleration
		decelleration = air_decelleration
		
		vel.y = 0
		var dir_dot = wall_normal.dot(transform.basis.x)
		direction = wall_normal.cross(transform.basis.y) * -round(dir_dot)
		if Input.is_action_just_pressed("ui_accept"):
			vel = wall_normal * kick_force + (Vector3(0,0,kick_force) * -transform.basis.z) + (Vector3.UP * 5)
	elif is_on_floor():
		accelleration = default_acceleration
		decelleration = default_decelleration
	
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

func _input(event):
	input_movement = Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		input_movement.y += 1
	if Input.is_action_pressed("move_back"):
		input_movement.y -= 1
	if Input.is_action_pressed("move_right"):
		input_movement.x += 1
	if Input.is_action_pressed("move_left"):
		input_movement.x -= 1

func process_input(delta):
	direction = Vector3()
		
	input_movement = input_movement.normalized()
	
	direction += -transform.basis.z * input_movement.y
	direction += transform.basis.x * input_movement.x
	
	if Input.is_action_just_pressed("ui_accept"):
		vel.y = jump_force

func knockback(dir):
	#when you get hit override the input
	#lower/higher% health makes ytou lose control for longer
	pass

func on_hit(hit, dir, normal):
	ray_hit = hit
	wallrun_dir = dir
	wall_normal = normal
