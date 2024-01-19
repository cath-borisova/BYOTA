extends Node3D

var camera = null
func _ready():
	camera = %XRCamera3D

func _process(delta):
	if %GraphRigidBody.visible:
		self.visible = true
		self.global_position = %GraphRigidBody.global_position
		self.global_position.y += 0.5
		var projected_camera_pos = camera.global_position
		#projected_camera_pos.y = 1.2
		self.look_at(projected_camera_pos, Vector3(0, 1, 0))
		#self.rotation.y = 0
	else:
		self.visible = false
