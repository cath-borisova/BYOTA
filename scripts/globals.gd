extends Node

var active_grabbers = []
var active_selected = []
var terrian_info = null
var x_axis_number_symbol = ["π", 1.0]
var y_axis_number = [5, 26]
var z_axis_number_symbol = ["π", 1.0]

var xrorigin3d = null
var left = null
var right = null
var camera = null
var equations = initializeArray() #[amplitude, width, length]

func _ready():
	xrorigin3d = get_node("/root/Main/XROrigin3D")
	left = get_node("/root/Main/XROrigin3D/LeftController")
	right = get_node("/root/Main/XROrigin3D/RightController")
	camera = get_node("/root/Main/XROrigin3D/XRCamera3D")
func initializeArray():
	var array = []
	for r in range(513):
		var row = []
		for c in range(513):
			row.push_back([0,0,0])
		array.push_back(row)
	return array

func get_equation(x, z):
	# y = equations[x][z][0] * sin(equations[x][z][1] * x) * cos(equations[x][z][2] * z)
	return equations[x][z]


func transform(object, controller):
	var controller_transform = controller.global_transform
	var offset_vector = -controller_transform.basis.z * 0.05
	object.global_transform.origin =controller_transform.origin 
	var my_rotation  =controller_transform.basis.get_euler()
	var rotated_basis = Basis(Quaternion(Vector3(0, my_rotation.y, 0).normalized(), 0))
	object.global_transform.basis = rotated_basis

func spindle(object):
	object.global_position = (left.global_position + right.global_position) / 2;
	var difference = abs(left.global_position.distance_to(right.global_position)) * 2;
	object.look_at(left.global_position);
	return difference

func position_relative_to_user(object):
	var xr_origin_transform = xrorigin3d.global_transform
	var offset_vector = -xr_origin_transform.basis.z * 0.1
	object.global_transform.origin = xr_origin_transform.origin + offset_vector
	object.rotation = Vector3(0,0,0)		

func position_above_user(object):
	var new_position = camera.global_position + -(camera.global_transform).basis.z.normalized() * 0.5
	new_position.y = xrorigin3d.global_position.y + 0.9
	object.global_transform.origin = new_position
	var projected_camera_pos = camera.global_position
	projected_camera_pos.y = xrorigin3d.global_position.y + 0.9
	object.look_at(projected_camera_pos, Vector3(0, 1, 0))
