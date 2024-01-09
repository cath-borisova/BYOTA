extends Node3D

@export var max_speed:= 2.5
@export var dead_zone := 0.2

@export var smooth_turn_speed:= 45.0
@export var smooth_turn_dead_zone := 0.2

@export var snap_turn_speed:= 45.0
@export var snap_turn_degrees:= 45.0
@export var snap_turn_dead_zone := 0.9

var input_vector:= Vector2.ZERO
var camera_view = true
var snap_turn = true
var returned_to_dead_zone = true
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
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
			returned_to_dead_zone = false

func _process_input(input_name: String, input_value: Vector2):
	if input_name == "primary":
		input_vector = input_value
