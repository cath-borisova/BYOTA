extends Node3D

var camera = null
# Called when the node enters the scene tree for the first time.
func _ready():
	camera = %XRCamera3D
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if %GraphRigidBody.visible:
		self.visible = true
		#var new_position = camera.global_position + -(camera.global_transform).basis.z.normalized() * 0.5
		#new_position.y = 1.4
		self.global_position = %GraphRigidBody.global_position
		self.global_position.y += 0.5
		#self.global_transform.origin = new_position
		var projected_camera_pos = camera.global_position
		projected_camera_pos.y = 1.2
		self.look_at(projected_camera_pos, Vector3(0, 1, 0))
	else:
		self.visible = false
