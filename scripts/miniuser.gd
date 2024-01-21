extends RigidBody3D

var grabbed_right = false
var grabbed_left = false
var offset_distance = 0.05

var right_controller = null
var left_controller = null
var xr_origin = null
var map = null
var globals = null

func _ready():
	right_controller = get_node("../XROrigin3D/RightController")
	left_controller = get_node("../XROrigin3D/LeftController")
	xr_origin = get_node("../XROrigin3D")
	map = get_node("../MapRigidBody")
	globals = get_node("/root/Globals")

func _process(delta):
	if grabbed_right:
		$compass.visible = false
		globals.transform(self, right_controller)
	elif grabbed_left:
		$compass.visible = false
		globals.transform(self, left_controller)
		
func teleport():
	if self.position.x < -0.5 || self.position.x > 0.5 || self.position.z < -0.5 || self.position.z > 0.5:
		self.position = Vector3(0, 0, 0)
	else:
		self.position.y = 0
	map.visible = false
	xr_origin.global_position = globals.map_local_to_global_pos(self.position.x, self.position.z)
	$compass.visible = true
