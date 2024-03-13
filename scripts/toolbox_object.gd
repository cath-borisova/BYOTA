extends RigidBody3D

var camera = null
var right_hand = null
var left_hand = null
var count = 0
var globals = null

func _ready():
	camera = %XRCamera3D
	right_hand = %RightController
	left_hand =  %LeftController
	self.freeze = true
	globals = get_node("/root/Globals")

func _process(_delta):
	if globals.item_showing == 3 && %MapRigidBody.visible:
		self.visible = true
		if self == right_hand.grabbed_object or self == left_hand.grabbed_object:
			var new_shape_scene = load("res://scenes/mini_tree.tscn")
			var new_shape = new_shape_scene.instantiate()
			get_node("/root/Main").add_child(new_shape)
			if self == right_hand.grabbed_object:
				right_hand.is_mini = true
				new_shape.global_position = right_hand.global_position
			else:
				left_hand.is_mini = true
				new_shape.global_position = left_hand.global_position
		
			new_shape.name = "mini_tree " + str(count)
			count += 1
			new_shape.freeze = true
			if self == right_hand.grabbed_object:
				right_hand.grabbed_object = new_shape
			else:
				left_hand.grabbed_object = new_shape
		else:
			var new_position = camera.global_position + -(camera.global_transform).basis.z.normalized() * 0.5
			new_position.y = %XROrigin3D.global_position.y + 0.9
			self.global_transform.origin = new_position
			var projected_camera_pos = camera.global_position
			projected_camera_pos.y = %XROrigin3D.global_position.y + 0.9
			self.look_at(projected_camera_pos, Vector3(0, 1, 0))
	else:
		if globals.item_showing == 3:
			globals.item_showing = 0
		self.visible = false
		
	
