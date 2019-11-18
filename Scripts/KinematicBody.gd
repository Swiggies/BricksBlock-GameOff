extends KinematicBody

export var speed = 5
export var gravity = -9.8
export var jump_force = 5
export var accelleration = 4.5
export var decelleration = 14
export var kick_force = 50
export var grid_shader : ShaderMaterial

var default_acceleration
var default_decelleration
var default_speed

var air_decelleration = 4.5
var air_acceleration = 4.5

var percent_health = 0
signal on_health_change

var camera
signal on_wallrun
var wallrun_dir

var direction : Vector3
var vel : Vector3
var wall_normal : Vector3
var ray_hit : bool
var input_movement : Vector2

onready var game_variables = get_node("/root/GameVariables")
var myPlayerNumber = -1

onready var myViewportContainer = get_node("ViewportContainer")
onready var my_mesh = get_node("MeshInstance")

#var my_visual_layer

var controller_sensitivty = -5
const deadzone = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
#	Used for splitscreensetupmyPlayerNumber
	setUpInitPosition()
	setUpViewport()
	setup_layers()
	setup_area() # Call after setting up the layers
	
#	Setting some defaults used for wallrunning
	default_acceleration = accelleration
	default_decelleration = decelleration
	default_speed = speed

func setup_area():
	var area = get_node("Area")
	var coll_shape = get_node("CollisionShape")
	var coll = coll_shape.duplicate(DUPLICATE_USE_INSTANCING)
	area.add_child(coll)

func setup_layers():
	#my_mesh.layers = pow(2, (myPlayerNumber + 2))
	#my_visual_layer = game_variables.VISUAL_LAYERS["player" + str(myPlayerNumber+1)]
	#my_mesh.layers = my_visual_layer
	
	my_mesh.layers = game_variables.VISUAL_LAYERS["player" + str(myPlayerNumber+1)]
	collision_layer += game_variables.COLLISION_LAYERS["player" + str(myPlayerNumber+1)]
	collision_mask += game_variables.COLLISION_LAYERS.powerup
	

func setUpInitPosition():
	# Random position to prevent the player from colliding into each other and get thrown off due to physics
	# A Temp Fix. Should be spawned at predetermined designated positions 
	# translation = Vector3(rand_range(-5, 5), 1, rand_range(-5, 5))
	rotation = Vector3.ZERO
	

func setUpViewport():
	# Legacy Code - Deletes any extra player instantiated
	if myPlayerNumber < 0 or myPlayerNumber > game_variables.NumberOfPlayers - 1:
		queue_free()
	
	# Set the anchor
	myViewportContainer.anchor_left = 0.0 if myPlayerNumber % 2 == 0 else 0.5
	myViewportContainer.anchor_right = 1.0 if myPlayerNumber % 2 == 1 else 0.5
	myViewportContainer.anchor_top = 0.0 if myPlayerNumber < 2 else 0.5
	myViewportContainer.anchor_bottom = 1.0
	
	# Set Viewport Size (as all will have the same view port size, this could be calculated just once
	# Though there's much of a performance hit either way
	var size = get_viewport().size
	var viewportSize = size
	viewportSize.x /= 2 if game_variables.NumberOfPlayers > 1 else 1
	viewportSize.y /= 2 if game_variables.NumberOfPlayers == 4 else 1
	myViewportContainer.rect_size = viewportSize
	
	# Set Position
	myViewportContainer.rect_position.x = 0 if myPlayerNumber % 2 == 0 else viewportSize.x
	myViewportContainer.rect_position.y = 0 if myPlayerNumber < 2 else viewportSize.y

func _process(delta):
	process_input(delta)
	wallrun()
	process_movement(delta)
	grid_shader.set_shader_param("pos"+str(myPlayerNumber),translation)
	#grid_shader.set("pos"+str(myPlayerNumber), translation)
	
func wallrun():
	emit_signal("on_wallrun", wallrun_dir, ray_hit)
	if(ray_hit):
		accelleration = air_acceleration
		decelleration = air_decelleration
		
		vel.y = 0
		var dir_dot = wall_normal.dot(transform.basis.x)
		direction = wall_normal.cross(transform.basis.y) * -round(dir_dot)
		if myPlayerNumber == 0:
			if Input.is_action_just_pressed("ui_accept"):
				vel = wall_normal * kick_force + (Vector3(0,0,kick_force) * -transform.basis.z) + (Vector3.UP * 5)
		else:
			if Input.is_joy_button_pressed(myPlayerNumber - 1, JOY_R):
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

func process_input(delta):
    direction = Vector3()

    input_movement = Vector2()

    if myPlayerNumber == 0:
        if Input.is_action_pressed("move_forward"):
            input_movement.y += 1
        if Input.is_action_pressed("move_back"):
            input_movement.y -= 1
        if Input.is_action_pressed("move_right"):
            input_movement.x += 1
        if Input.is_action_pressed("move_left"):
            input_movement.x -= 1
    else:
        if abs(Input.get_joy_axis(game_variables.PLYAER_JOY_ID[myPlayerNumber], JOY_ANALOG_LX)) > deadzone or abs(Input.get_joy_axis(game_variables.PLYAER_JOY_ID[myPlayerNumber], JOY_ANALOG_LY)) > deadzone:
            input_movement = Vector2(Input.get_joy_axis(game_variables.PLYAER_JOY_ID[myPlayerNumber], JOY_ANALOG_LX), -Input.get_joy_axis(game_variables.PLYAER_JOY_ID[myPlayerNumber], JOY_ANALOG_LY))

    input_movement = input_movement.normalized()

    direction += -transform.basis.z * input_movement.y
    direction += transform.basis.x * input_movement.x

    if myPlayerNumber == 0:
        if Input.is_action_just_pressed("ui_accept"):
            vel.y = jump_force
    elif Input.is_joy_button_pressed(myPlayerNumber - 1, JOY_R):
        vel.y = jump_force

func charge(dir, force):
	vel = dir * force

func knockback(dir, distance):
	var new_dir = translation - dir
	var normalized_distance = inverse_lerp(5,0,distance)
	new_dir = new_dir.normalized() * normalized_distance
	percent_health += 10 * normalized_distance;
	vel = new_dir * (percent_health)
	emit_signal("on_health_change", percent_health)

func on_hit(hit, dir, normal):
	ray_hit = hit
	wallrun_dir = dir
	wall_normal = normal
