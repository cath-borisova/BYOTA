extends RigidBody3D

var camera
var right_hand
var left_hand
var menu 
# Called when the node enters the scene tree for the first time.
func _ready():
	camera = %XRCamera3D
	right_hand = %RightController
	left_hand =  %LeftController
	menu = %menu
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#code to follow users view
	
	
	#code that detects if object is grabbed
	if self == right_hand.grabbed_object or self == left_hand.grabbed_object:
		var new_shape_scene = load("res://scenes/mini_tree.tscn")
		var new_shape = new_shape_scene.instantiate()
		get_node("/root/Main").add_child(new_shape)
		if self == right_hand.grabbed_object:
			right_hand.is_mini = true
			new_shape.global_position = right_hand.global_position
#			new_shape.global_position.y += 0.2
		else:
			left_hand.is_mini = true
			new_shape.global_position = left_hand.global_position
#			new_shape.global_position.y += 0.2
		#grabbable_body.freeze = true
		new_shape.name = "TEST"
		#cannot call method add_child on a null value
		new_shape.freeze = true
		right_hand.grabbed_object = new_shape
		#set position?")
	else:
		self.global_position =  camera.global_position
		self.global_position.z = camera.global_position.z - 0.5
		self.global_position.x = camera.global_position.x + 0.4
		
	
