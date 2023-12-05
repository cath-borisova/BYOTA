extends Node3D

@export var move_speed := 2.5
@export var move_dead_zone := 0.2

@export var smooth_turn_speed := 45
@export var smooth_turn_dead_zone := 0.2

var input_vector = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.input_vector.y > self.move_dead_zone || self.input_vector.y < -self.move_dead_zone:
		var movement_vector = Vector3(0, 0, -self.input_vector.y * self.move_speed * delta)
		self.position += movement_vector.rotated(Vector3.UP, $XRCamera3D.global_rotation.y)

	if self.input_vector.x > self.smooth_turn_dead_zone || self.input_vector.x < -self.smooth_turn_dead_zone:
		self.translate($XRCamera3D.position)
		self.rotate_y(deg_to_rad(-self.input_vector.x * self.smooth_turn_speed * delta))
		self.translate(-$XRCamera3D.position)

func _process_input(input_name: String, input_value: Vector2):
	if input_name == "primary":
		self.input_vector = input_value