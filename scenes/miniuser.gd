extends RigidBody3D

var grabbed_right = false
var grabbed_left = false
var offset_distance = 0.05

var right_controller = null
var left_controller = null
var xr_origin = null
var map = null
var globals = null
var camera = null

var previous_rotation
func _ready():
	right_controller = get_node("../XROrigin3D/RightController")
	left_controller = get_node("../XROrigin3D/LeftController")
	xr_origin = get_node("../XROrigin3D")
	camera = get_node("../XROrigin3D/XRCamera3D")
	map = get_node("../MapRigidBody")
	globals = get_node("/root/Globals")
	previous_rotation = 0

func _process(delta):
#	print("Rotate " ,self.rotation_degrees.y)
	#camera movement
	var camera_transform = camera.global_transform
	var camera_rotation = rad_to_deg(camera_transform.basis.get_euler().y)
#	#delta: get prevous - camera_rotation
	var delta_rotation = previous_rotation - camera_rotation
	#var mini_user_transform = %MapRigidBody/Map/MiniUser.global_transform.basis.get_euler().y
	#rotate compass
	#%MapRigidBody/Map/MiniUser.rotation.y = %MapRigidBody/Map/MiniUser.rotation.y + delta_rotation
	
	#off by 45degrees?
	self.rotate(Vector3.UP, deg_to_rad(-delta_rotation))
	previous_rotation = camera_rotation
	
	if grabbed_right:
		$compass.visible = false
		globals.transform(self, right_controller)
	elif grabbed_left:
		$compass.visible = false
		globals.transform(self, left_controller)
		
func teleport():
	if self.position.x < -0.25 || self.position.x > 0.25 || self.position.z < -0.25 || self.position.z > 0.25:
		self.position = Vector3(0, 0, 0)
	else:
		self.position.y = 0
	map.visible = false
	xr_origin.global_position = Vector3((200 * self.position.x), 0, (200* self.position.z))
	$compass.visible = true
