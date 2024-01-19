extends RigidBody3D
var selector = null
var right_hand = null
var equation = null

var x_symbols = {"0": ["2π", 2],
	"0.02875": ["7π/4", 7/4],
	"0.0575": ["3π/2", 3/2],
	"0.08625": ["5π/4", 5/4],
	"0.115": ["π", 1],
	"0.14375": ["3π/4", 3/4],
	"0.1725" : ["π/2", 1/2],
	"0.20125": ["π/4", 1/4],
	"0.23": ["0π", 0]}
	
var z_symbols = {"0": ["2π", 2],
	"-0.02875": ["7π/4", 7/4],
	"-0.0575": ["3π/2", 3/2],
	"-0.08625": ["5π/4", 5/4],
	"-0.115": ["π", 1],
	"-0.14375": ["3π/4", 3/4],
	"-0.1725" : ["π/2", 1/2],
	"-0.20125": ["π/4", 1/4],
	"-0.23": ["0π", 0]}

func _ready():
	selector = self.name.substr(0, 1)
	right_hand = %RightController
	equation = %Equation
	var globals = get_node("/root/Globals")

#find closest point from array 
func find_closest_node_to_point(array, point):
	var closest = null
	var closest_distance = 0.0
	for i in array:
		var current_node_distance = point.distance_to(i)
		if closest == null or current_node_distance < closest_distance:
			closest = i
			closest_distance = current_node_distance
	return closest

func _process(_delta):
	var globals = get_node("/root/Globals")
	if self == right_hand.selected_object:
		if selector == "X":
			# 2pi = 0.23
			# 7pi/4 = 0.20125
			# 3pi/2 = 0.1725
			# 5pi/4 = 0.14375
			# pi = 0.115
			# 3pi/4 = 0.08625
			# pi/2 = 0.0575
			# pi/4 0.02875
			# 0 = 0
			var x_fixed_points = [Vector3(0.23, self.position.y, self.position.z),
				Vector3(0.20125, self.position.y, self.position.z),
				Vector3(0.1725, self.position.y, self.position.z),
				Vector3(0.14375, self.position.y, self.position.z),
				Vector3(0.115, self.position.y, self.position.z),
				Vector3(0.08625, self.position.y, self.position.z),
				Vector3(0.0575, self.position.y, self.position.z),
				Vector3(0.02875, self.position.y, self.position.z),
				Vector3(0, self.position.y, self.position.z)]
			var right_pos = %GraphRigidBody.to_local(%RightController.global_position)
			var closest_point = self.find_closest_node_to_point(x_fixed_points, right_pos)
			self.position = closest_point
			var point = 0
			if closest_point[0] != 0:
				point = round(closest_point.x * 100000) / 100000
			%Model.scale.x = clamp(self.position.x * 0.0065, 0.0000001, 0.0015)
			globals.x_axis_number_symbol = [self.global_position.x, x_symbols[str(point)], x_symbols[str(point)][1]]
			
		if selector == "Y":
			var right_pos = self.to_local(%RightController.global_position)
			self.position.y = clamp(right_pos.y, 0,  0.23)
			%Model.scale.y = clamp(self.position.y * 0.0065, 0.0000001, 0.0015)
			var scaled_point = clamp(round(self.position.y * 108.7), 0, 25)
			globals.y_axis_number = [scaled_point, clamp(round(scaled_point * 5.13), 0, 513)]
		
		if selector == "Z":
			var z_fixed_points = [Vector3(self.position.x, self.position.y, -0.23),
				Vector3(self.position.x, self.position.y, -0.20125),
				Vector3(self.position.x, self.position.y, -0.1725),
				Vector3(self.position.x, self.position.y, -0.14375),
				Vector3(self.position.x, self.position.y, -0.115),
				Vector3(self.position.x, self.position.y, -0.08625),
				Vector3(self.position.x, self.position.y, -0.0575),
				Vector3(self.position.x, self.position.y, -0.02875),
				Vector3(self.position.x, self.position.y, 0)]
				
			var right_pos = %GraphRigidBody.to_local(%RightController.global_position)
			var closest_point = self.find_closest_node_to_point(z_fixed_points, right_pos)
			self.position = closest_point
			var point = 0
			if closest_point[2] != 0:
				point = round(closest_point.z * 100000) / 100000
			globals.z_axis_number_symbol =  [self.global_position.z, z_symbols[str(point)], z_symbols[str(point)][1]]
			%Model.scale.z = clamp(-self.position.z * 0.0065, 0.0000001, 0.0015)
	var amplitude = str(globals.y_axis_number[0])
	var width = globals.x_axis_number_symbol[1][0]
	var length =  globals.z_axis_number_symbol[1][0]
	equation.text =  "Amplitude: " + amplitude + "\nWidth: " + width + "\nLength: " + length + "\ny = " + amplitude + "×sin(" + width+"×x)×cos("+length+"×z)"

