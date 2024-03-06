extends Node
var user = null
var original = null
var equation = null
# Called when the node enters the scene tree for the first time.
func _ready():
	equation = %equation
	#/XRUser/
	user = get_node("../XROrigin3D/XRCamera3D")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	equation.global_position.y = user.global_position.y
	if original == null:
		self.queue_free()
		print("copy freed")
