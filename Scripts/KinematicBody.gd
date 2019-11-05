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

onready var player_variables = get_node("/root/PlayerVariables")
var myPlayerNumber = -1

onready var myViewportContainer = get_node("ViewportContainer")

# Called when the node enters the scene tree for the first time.
func _ready():
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
