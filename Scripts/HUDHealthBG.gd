extends Line2D

onready var game_variables = get_node("/root/GameVariables")
onready var health_label = get_node("HealthLabel") as Label
var health = 0.0
signal on_die

func _ready():
	for i in range(5):
		var bar = get_node("Health FG" + str(i+1)) as Line2D

func add_health(amount):
	health += amount
	health = clamp(health, 0.0, 500.0)
	if health <= 0.0:
		emit_signal("on_die")
	on_health_change()

func on_health_change():
	# Update the Label
	health_label.text = str(int(health)) + "%"
	
	# Num of bars to show
	var max_index = int(health/100) + 1
	max_index = max_index if max_index <= 5 else 5
	
	# Update the health bars
	for i in range(5):
		var bar = get_node("Health FG" + str(i + 1)) as Line2D
		if i < max_index:
			bar.visible = true
			var x = (health - (i * 100)) / 100
			x = x if x <= 1 else 1
			bar.points[2] = Vector2(x * 150 + 10, 10)
		else:
			bar.visible = false
	
		

# TEST CODE
func _process(delta):
	if not game_variables.DEBUG_MODE:
		return
	
	if Input.is_key_pressed(KEY_U):
		health += rand_range(0, 15)
		health = health if health < 500 else 500
	elif Input.is_key_pressed(KEY_P):
		health -= rand_range(0, 15)
		health = health if health > 0 else 0
	
	on_health_change()
