extends RigidBody3D
var selector = null
var right_hand = null
var equation = null


# Called when the node enters the scene tree for the first time.
func _ready():
	selector = self.name.substr(0, 1)
	right_hand = %RightController
	equation = %Equation
	var globals = get_node("/root/Globals")
	globals.x_axis_number_symbol = [0.5, "2π"]
	globals.y_axis_number = 100
	globals.z_axis_number_symbol =  [-0.889, "2π"]
	#add default y val here


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
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var globals = get_node("/root/Globals")
	if self == right_hand.grabbed_object:
		if selector == "x":
			var x_fixed_points = [Vector3(0.5, self.global_position.y, self.global_position.z), Vector3(0.375, self.global_position.y, self.global_position.z), Vector3(0.25, self.global_position.y, self.global_position.z), Vector3(0.125, self.global_position.y, self.global_position.z),Vector3(0, self.global_position.y, self.global_position.z), Vector3(-0.5, self.global_position.y, self.global_position.z), Vector3(-0.375, self.global_position.y, self.global_position.z), Vector3(-0.25, self.global_position.y, self.global_position.z), Vector3(-0.125, self.global_position.y, self.global_position.z)]
			#if within bounds then move ball
			if right_hand.global_position.x < 0.5 and right_hand.global_position.x > -0.5:
				#fixed points on a line
				
				var closest_point = self.find_closest_node_to_point(x_fixed_points, right_hand.global_position)
				self.global_position = closest_point
				#update globals
				var symbols = {"0.5": "2π", "0.375": "3π/2", "0.25":"π", "0.125": "π/2", "0": "0","-0.5": "-2π", "-0.375": "-3π/2", "-0.25":"-π", "-0.125": "-π/2"}
				globals.x_axis_number_symbol = [self.global_position.x, symbols[str(self.global_position.x)]]
		if selector == "y":
			if right_hand.global_position.y < 1.711 and right_hand.global_position.y > 0.711:
				self.global_position.y = right_hand.global_position.y
				# max = 0, 1.711, -1.377 
				# min = 0, 0.711, -1.377
				#rounded:
				var scaled_point = ((right_hand.global_position.y - 0.711) / (1.711 - 0.711)) * 200 - 100
				var rounded_scaled_point = round(scaled_point*pow(10,2))/pow(10,2)
				#update globals
				globals.y_axis_number = rounded_scaled_point
		
		if selector == "z":
			if right_hand.global_position.z < -0.889 and right_hand.global_position.z > -1.889:
				var z_fixed_points = [Vector3(self.global_position.x, self.global_position.y, -0.889), Vector3(self.global_position.x, self.global_position.y, -1.014 ),Vector3(self.global_position.x, self.global_position.y, -1.139),Vector3(self.global_position.x, self.global_position.y, -1.264),Vector3(self.global_position.x, self.global_position.y, -1.389),Vector3(self.global_position.x, self.global_position.y, -1.514), Vector3(self.global_position.x, self.global_position.y, -1.639 ),Vector3(self.global_position.x, self.global_position.y,-1.764),Vector3(self.global_position.x, self.global_position.y, -1.889)]
				self.global_position.z = right_hand.global_position.z
				#fixed points on a line
				#-0.125 apart from each other
				#-0.889 = 2pi, -1.014 = 3pi/2, -1.139= pi, -1.264 = pi/2 -1.389 = 0 -1.514 , -1.639, -1.764 -1.889
				var closest_point = self.find_closest_node_to_point(z_fixed_points, right_hand.global_position)
				self.global_position = closest_point
				var symbols = {"-0.889": "2π", "-1.014": "3π/2", "-1.139":"π", "-1.264": "π/2", "-1.389": "0","-1.889": "-2π", "-1.764": "-3π/2", "-1.639":"-π", "-1.514": "-π/2"}
				print(closest_point.z)
				var point = round(closest_point.z*pow(10,3))/pow(10,3)
				#update globals
				globals.z_axis_number_symbol =  [self.global_position.z, symbols[str(point)]]
	
	equation.text =  "X: " + globals.x_axis_number_symbol[1] + "\nY: " + str(globals.y_axis_number) + "\nZ: " + globals.z_axis_number_symbol[1]

