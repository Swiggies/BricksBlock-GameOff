extends Line2D

onready var health_label = get_node("HealthLabel") as Label
var health = 0.0

func _ready():
	for i in range(5):
		var bar = get_node("Health FG" + str(i+1)) as Line2D
		#bar.z_index = i
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed(KEY_U):
		health += rand_range(0, 15)
		health = health if health < 500 else 500
	elif Input.is_key_pressed(KEY_P):
		health -= rand_range(0, 15)
		health = health if health > 0 else 0
	health_label.text = str(int(health)) + "%"
	
	var max_index = int(health/100) + 1
	max_index = max_index if max_index <= 5 else 5
	for i in range(5):
		var bar = get_node("Health FG" + str(i + 1)) as Line2D
		if i < max_index:
			bar.visible = true
			var x = (health - (i * 100)) / 100
			x = x if x <= 1 else 1
			bar.points[2] = Vector2(x * 150 + 10, 10)
		else:
			bar.visible = false
