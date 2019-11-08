extends RayCast

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal on_hit

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	emit_signal("on_hit", is_colliding())