extends RigidBody3D

var grabbed_right = false
var grabbed_left = false
var offset_distance = 0.05

var right_controller = null
var left_controller = null
var xr_origin = null
var map = null
# Called when the node enters the scene tree for the first time.
func _ready():
	right_controller = get_node("../XROrigin3D/RightController")
	left_controller = get_node("../XROrigin3D/LeftController")
	xr_origin = get_node("../XROrigin3D")
	map = get_node("../MapRigidBody")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if grabbed_right:
		$compass.visible = false
		var right_controller_transform = right_controller.global_transform
		var offset_vector = -right_controller_transform.basis.z * offset_distance
		self.global_transform.origin = right_controller_transform.origin + offset_vector
		var my_rotation = right_controller_transform.basis.get_euler()
		var rotated_basis = Basis(Quaternion(Vector3(0, my_rotation.y, 0).normalized(), 0))
		self.global_transform.basis = rotated_basis
	elif grabbed_left:
		$compass.visible = false
		var left_controller_transform = left_controller.global_transform
		var offset_vector = -left_controller_transform.basis.z * offset_distance
		self.global_transform.origin = left_controller_transform.origin + offset_vector
		var my_rotation = left_controller_transform.basis.get_euler()
		var rotated_basis = Basis(Quaternion(Vector3(0, my_rotation.y, 0).normalized(), 0))
		self.global_transform.basis = rotated_basis
func teleport():
	if self.position.x < -0.25 || self.position.x > 0.25 || self.position.z < -0.25 || self.position.z > 0.25:
		self.position = Vector3(0, 0, 0)
	else:
		self.position.y = 0
	map.visible = false
	xr_origin.global_position = Vector3((200 * self.position.x), 0, (200* self.position.z))
	$compass.visible = true
