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
			var rotation_values = {0: "0", 15:"π/12" ,30:"π/6", 45:"π/4", 60:"π/3", 75:"5π/12", 90:"π/2", 105:"7π/12", 120:"2π/3", 135:"3π/4", 150:"5π/6", 165:"11π/12", 180:"π", 195:"13π/12", 210:"7π/6", 225:"5π/4", 240:"4π/3", 255:"17π/12", 270: "3π/2", 285:"19π/12", 300:"5π/3", 315:"7π/4", 330:"11π/6", 345:"23π/12",
			 							 -345:"π/12",-330:"π/6",-315:"π/4",-300:"π/3",-285:"5π/12",-270:"π/2",-255:"7π/12",-240:"2π/3",-225:"3π/4",-210:"5π/6",-195:"11π/12", -180:"π",-165:"13π/12",-150:"7π/6",-135:"5π/4",-120:"4π/3",-105:"17π/12", -90: "3π/2",-75:"19π/12",-60:"5π/3", -45:"7π/4", -30:"11π/6", -15:"23π/12"}
			if rotation_position == 90 or rotation_position == -270:
				var new_text = "N\n"+ rotation_values[int(rotation_position)]
				%MapRigidBody/Map/MiniUser/compass.text = new_text
			elif rotation_position == 0:
				var new_text = "E\n"+ rotation_values[int(rotation_position)]
				%MapRigidBody/Map/MiniUser/compass.text = new_text
			elif rotation_position == 180 or rotation_position == -180:
				var new_text = "W\n"+ rotation_values[int(rotation_position)]
				%MapRigidBody/Map/MiniUser/compass.text = new_text
			elif rotation_position == 270 or rotation_position == -90:
				var new_text = "S\n"+ rotation_values[int(rotation_position)]
				%MapRigidBody/Map/MiniUser/compass.text = new_text
			else:
				%MapRigidBody/Map/MiniUser/compass.text = rotation_values[int(rotation_position)]
			
			returned_to_dead_zone = false

func _process_input(input_name: String, input_value: Vector2):
	if input_name == "primary":
		input_vector = input_value
