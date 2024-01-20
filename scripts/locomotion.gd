extends Node3D

@export var max_speed:= 2.5
@export var dead_zone := 0.2

@export var smooth_turn_speed:= 45.0
@export var smooth_turn_dead_zone := 0.2

@export var snap_turn_speed:= 15.0
@export var snap_turn_degrees:= 45.0
@export var snap_turn_dead_zone := 0.9

var input_vector:= Vector2.ZERO
var camera_view = true
var snap_turn = true
var returned_to_dead_zone = true

var rotation_position = 0

#1 = radians 2 = NESW 3=Coordinates
var compass_mode = 1
func _ready():
	pass 

func _process(_delta):
	if self.input_vector.y > self.dead_zone || self.input_vector.y < -self.dead_zone:
		var movement_vector = Vector3(0, 0, max_speed * -self.input_vector.y * _delta)
		if camera_view:
			self.position += movement_vector.rotated(Vector3.UP, $XRCamera3D.global_rotation.y)
	if snap_turn:
		if (self.input_vector.x >= 0 && self.input_vector.x < self.dead_zone) || (self.input_vector.x <= 0 && self.input_vector.x > -self.dead_zone):
			returned_to_dead_zone = true
			
		if returned_to_dead_zone && (self.input_vector.x > self.snap_turn_dead_zone || self.input_vector.x < -self.snap_turn_dead_zone):
			self.rotate(Vector3.UP, deg_to_rad(snap_turn_speed) * -self.input_vector.x)
			%MapRigidBody/Map.rotate(Vector3.UP, deg_to_rad(snap_turn_speed) * -self.input_vector.x)
			%MapRigidBody/Map/MiniUser.rotate(Vector3.UP, (deg_to_rad(snap_turn_speed) * -self.input_vector.x))
			if (deg_to_rad(snap_turn_speed) * -self.input_vector.x) < 0:
				rotation_position += snap_turn_speed
				if rotation_position == 360:
					rotation_position = 0
			else:
				rotation_position -= snap_turn_speed
				if rotation_position == -360:
					rotation_position = 0
			returned_to_dead_zone = false
	var radian_values = {0: "0", 15:"π/12" ,30:"π/6", 45:"π/4", 60:"π/3", 75:"5π/12", 90:"π/2", 105:"7π/12", 120:"2π/3", 135:"3π/4", 150:"5π/6", 165:"11π/12", 180:"π", 195:"13π/12", 210:"7π/6", 225:"5π/4", 240:"4π/3", 255:"17π/12", 270: "3π/2", 285:"19π/12", 300:"5π/3", 315:"7π/4", 330:"11π/6", 345:"23π/12",
	 							 -345:"π/12",-330:"π/6",-315:"π/4",-300:"π/3",-285:"5π/12",-270:"π/2",-255:"7π/12",-240:"2π/3",-225:"3π/4",-210:"5π/6",-195:"11π/12", -180:"π",-165:"13π/12",-150:"7π/6",-135:"5π/4",-120:"4π/3",-105:"17π/12", -90: "3π/2",-75:"19π/12",-60:"5π/3", -45:"7π/4", -30:"11π/6", -15:"23π/12"}
	var coord_values = {0: "(1, 0)", 15:"(0.96, 0.26)" ,30:"(√3/2, 1/2)", 45:"(√2/2, √2/2)", 60:"(1/2, √3/2)", 75:"(0.26, 0.97)", 90:"(0, 1)", 105:"(-0.26, 0.97)", 120:"(-1/2, √3/2)", 135:"(-√2/2, √2/2)", 150:"(-√3/2, 1/2)", 165:"(-0.97, 0.26)", 180:"(-1, 0)", 195:"(-0.97, -0.26)", 210:"(-√3/2, -1/2)", 225:"(-√2/2, -√2/2)", 240:"(-1/2, -√3/2)", 255:"(-0.27, -0.97)", 270:"(0, -1)", 285:"(0.27, -0.97)", 300:"(1/2, -√3/2)", 315:"(√2/2, -√2/2)", 330:"(√3/2, -1/2)", 345:"(0.97, -0.26)",
	 							 -345:"(0.96, 0.26",-330:"(√3/2, 1/2)",-315:"(√2/2, √2/2)",-300:"(1/2, √3/2)",-285:"(0.26, 0.97)",-270:"(0, 1)",-255:"(-0.26, 0.97)",-240:"(-1/2, √3/2)",-225:"(-√2/2, √2/2)",-210:"(-√3/2, 1/2)",-195:"(-0.97, 0.26)", -180:"(-1, 0)",-165:"(-0.97, -0.26)",-150:"(-√3/2, -1/2)",-135:"(-√2/2, -√2/2)",-120:"(-1/2, -√3/2)",-105:"(-0.27, -0.97)", -90:"(0, -1)",-75:"(0.27, -0.97)",-60:"(1/2, -√3/2)", -45:"(√2/2, -√2/2)", -30:"(√3/2, -1/2)", -15:"(0.97, -0.26)"}
	var degree_values = {0: "0", 15:"15", 30:"30", 45:"45", 60:"60", 75:"75", 90:"90", 105:"105", 120:"120", 135:"135", 150:"150", 165:"165", 180:"180", 195:"195", 210:"210", 225:"225", 240:"240", 255:"255", 270: "270", 285:"285", 300:"300", 315:"315", 330:"330", 345:"345",
	 							 -345:"15",-330:"30",-315:"45",-300:"60",-285:"75",-270:"90",-255:"105",-240:"120",-225:"135",-210:"150",-195:"165", -180:"180",-165:"195",-150:"210",-135:"225",-120:"240",-105:"255", -90: "270",-75:"285",-60:"300", -45:"315", -30:"330", -15:"345"}
	if compass_mode == 3:
		%MapRigidBody/Map/MiniUser/compass.text = radian_values[int(rotation_position)]
	elif compass_mode == 2: #degrees
		%MapRigidBody/Map/MiniUser/compass.text = degree_values[int(rotation_position)]
	elif compass_mode == 1:
		if rotation_position == 90 or rotation_position == -270:
			%MapRigidBody/Map/MiniUser/compass.text = "N"
		elif rotation_position == 45 or rotation_position == -315:
			%MapRigidBody/Map/MiniUser/compass.text = "NE"
		elif rotation_position == 0:
			%MapRigidBody/Map/MiniUser/compass.text ="E"
		elif rotation_position == 135 or rotation_position == -225:
			%MapRigidBody/Map/MiniUser/compass.text = "NW"
		elif rotation_position == 180 or rotation_position == -180:
			%MapRigidBody/Map/MiniUser/compass.text = "W"
		elif rotation_position == 225 or rotation_position == -135:
			%MapRigidBody/Map/MiniUser/compass.text = "SW"
		elif rotation_position == 270 or rotation_position == -90:
			%MapRigidBody/Map/MiniUser/compass.text = "S"
		elif rotation_position == 315 or rotation_position == -45:
			%MapRigidBody/Map/MiniUser/compass.text = "SE"
		else:
			%MapRigidBody/Map/MiniUser/compass.text = " "
	elif compass_mode == 4:
		%MapRigidBody/Map/MiniUser/compass.text = coord_values[int(rotation_position)]

func _process_input(input_name: String, input_value: Vector2):
	if input_name == "primary":
		input_vector = input_value


func _on_right_controller_button_pressed(button_name):
	if button_name == "by_button":
		compass_mode += 1
		if compass_mode == 5:
			compass_mode = 1
