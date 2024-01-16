extends Node

var active_grabbers = []
var active_selected = []
var terrian_info = null
var x_axis_number_symbol = [2, ""]
var y_axis_number = 10
var z_axis_number_symbol = [4, ""]


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
