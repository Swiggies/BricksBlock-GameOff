extends CSGMesh

export var rotate_speed = 3
onready var rb = get_node("RigidBody")

onready var game_variables = get_node("/root/GameVariables")

# Called when the node enters the scene tree for the first time.
func _ready():
	rb.collision_layer = game_variables.COLLISION_LAYERS.powerup
	rb.collision_mask = 0
	rb.collision_mask += game_variables.COLLISION_LAYERS.player1
	rb.collision_mask += game_variables.COLLISION_LAYERS.player2
	rb.collision_mask += game_variables.COLLISION_LAYERS.player3
	rb.collision_mask += game_variables.COLLISION_LAYERS.player4


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	revolve(delta)

func revolve(delta):
	rotate_y(rotate_speed * delta)


func _on_collision_entered(body):
	print("Powerup collected")
	queue_free()
