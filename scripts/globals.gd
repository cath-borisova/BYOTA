extends Node

var active_grabbers = []
var active_selected = []
var terrian_info = null
var x_axis_number_symbol = [0.115, "π", 1]
var y_axis_number = 25
var z_axis_number_symbol = [-0.115, "π", 1]


var equations = initializeArray() #[amplitude, width, length]

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
