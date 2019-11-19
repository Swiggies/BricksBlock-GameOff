extends KinematicBody

export var speed = 5
export var gravity = -9.8
export var jump_force = 5
export var accelleration = 4.5
export var decelleration = 14
export var kick_force = 50


export var bound_damage:Vector2 = Vector2(0.075, 0.150)
export var bound_stuck_time:float = 3
var bound_stuck_time_elapsed:float = 0
var last_transform = null
var bound_rebound:Vector3 = Vector3.ZERO
var disable_movement:bool = false


var default_acceleration
var default_decelleration
var default_speed

var air_decelleration = 4.5
var air_acceleration = 4.5

var percent_health = 0
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

onready var health_bar = get_node("ViewportContainer/Viewport/Camera/HUD/Health Bar")
onready var electric_shock = get_node("MeshInstance/Electric Shock Effect")

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
	get_bound_radius()
	
	# Default health
	health_bar.health = 100.0
	
#	Setting some defaults used for wallrunning
	default_acceleration = accelleration
	default_decelleration = decelleration
	default_speed = speed

func get_bound_radius():
	if not game_variables.bound_rad:
		var level = get_tree().root.find_node("Spatial", false, false)
		var sphere_parent = level.find_node("Sphere Bound", false, false) as Spatial
		game_variables.bound_rad = abs(floor(sphere_parent.scale.x))
		game_variables.bound_rad *= abs(floor((sphere_parent.get_child(1) as Spatial).scale.x))
		
		var coll_scale = get_node("CollisionShape").scale
		game_variables.bound_rad -= max(coll_scale.x, max(coll_scale.y, coll_scale.z)) * 4.0
		
		print(game_variables.bound_rad)

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
	var screen_num = -1
	for i in game_variables.PLYAER_JOY_ID:
		if game_variables.PLYAER_JOY_ID[i] != -1:
			screen_num += 1
		if i == myPlayerNumber:
			break
	
	if screen_num < 0 or screen_num > game_variables.NumberOfPlayers - 1:
		queue_free()

	# Set the anchor
	myViewportContainer.anchor_left = 0.0 if screen_num % 2 == 0 else 0.5
	myViewportContainer.anchor_right = 1.0 if screen_num % 2 == 1 else 0.5
	myViewportContainer.anchor_top = 0.0 if screen_num < 2 else 0.5
	myViewportContainer.anchor_bottom = 0.5 if screen_num < 2 else 1.0

	# Set Viewport Size (as all will have the same view port size, this could be calculated just once
	# Though there's much of a performance hit either way
	var size = get_viewport().size
	var viewportSize = size
	viewportSize.x /= 2 if game_variables.NumberOfPlayers > 1 else 1
	viewportSize.y /= 2 if game_variables.NumberOfPlayers > 2 else 1
	myViewportContainer.rect_size = viewportSize

	# Set Position
	myViewportContainer.rect_position.x = 0 if screen_num % 2 == 0 else viewportSize.x
	myViewportContainer.rect_position.y = 0 if screen_num < 2 else viewportSize.y

func _process(delta):
	process_input(delta)
	wallrun()
	process_movement(delta)
	check_bound(delta)

func check_bound(delta):
	if translation.distance_to(Vector3.ZERO) > game_variables.bound_rad:
		direction = Vector3.ZERO
		vel = Vector3.ZERO
		disable_movement = true
		
		electric_shock.visible = true
		health_bar.add_health(-rand_range(bound_damage.x, bound_damage.y) * delta * 100)
		bound_stuck_time_elapsed += delta
		if last_transform == null:
			#translation = translation.normalized() * (game_variables.bound_rad + 0.01)
			last_transform = transform
		if bound_stuck_time_elapsed <= bound_stuck_time:
			transform = last_transform
		else:
			bound_rebound = (Vector3.ZERO - translation).normalized()
			translation +=  bound_rebound * delta * 10.0
	else:
		electric_shock.visible = false
		if last_transform and bound_stuck_time_elapsed <= bound_stuck_time * 1.5:
			bound_stuck_time_elapsed += delta
			move_and_collide(bound_rebound * delta * 50.0)
			bound_rebound -= bound_rebound * delta * 3.0
			bound_rebound.y += delta * gravity * 0.025
			return
		bound_stuck_time_elapsed = 0
		last_transform = null
		disable_movement = false

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
			if Input.is_joy_button_pressed(game_variables.PLYAER_JOY_ID[myPlayerNumber], JOY_R):
				vel = wall_normal * kick_force + (Vector3(0,0,kick_force) * -transform.basis.z) + (Vector3.UP * 5)

	elif is_on_floor():
		accelleration = default_acceleration
		decelleration = default_decelleration

func process_movement(delta):
	if disable_movement:
		return
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
