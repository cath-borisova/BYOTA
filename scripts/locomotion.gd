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
func _process(delta):
	# Forward translation
	if self.input_vector.y > self.dead_zone || self.input_vector.y < -self.dead_zone:
		var movement_vector = Vector3(0, 0, max_speed * -self.input_vector.y * delta)
		if camera_view:
			#Camera view
			self.position += movement_vector.rotated(Vector3.UP, $XRCamera3D.global_rotation.y)
#		else:
#			#Hand view
#			self.position += movement_vector.rotated(Vector3.UP, %RightController.global_rotation.y)
#	if smooth_turn:
#		# Smooth turn
#		if self.input_vector.x > self.smooth_turn_dead_zone || self.input_vector.x < -self.smooth_turn_dead_zone:
#
#			# move to the position of the camera
#			self.translate(%XRCamera3D.position)
#
#			# rotate about the camera's position
#			self.rotate(Vector3.UP, deg_to_rad(smooth_turn_speed) * -self.input_vector.x * delta)
#
#			# reverse the translation to move back to the original position
#			self.translate(%XRCamera3D.position * -1)
	if snap_turn:
		# Snap turn
		if (self.input_vector.x >= 0 && self.input_vector.x < self.dead_zone) || (self.input_vector.x <= 0 && self.input_vector.x > -self.dead_zone):
			returned_to_dead_zone = true
			
		if returned_to_dead_zone && (self.input_vector.x > self.snap_turn_dead_zone || self.input_vector.x < -self.snap_turn_dead_zone):

			# rotate about the camera's position
			self.rotate(Vector3.UP, deg_to_rad(snap_turn_speed) * -self.input_vector.x) #  * delta

			returned_to_dead_zone = false

func _process_input(input_name: String, input_value: Vector2):
	if input_name == "primary":
		input_vector = input_value


#func _on_button_pressed(button_name: String) -> void:
#	if button_name == "ax_button":
#		camera_view = !camera_view
#		if camera_view:
#			print("Camera view")
#		else:
#			print("Hand view")
#
#	if button_name == "by_button":
#		smooth_turn = !smooth_turn
#		if smooth_turn:
#			print("Smooth turn")
#		else:
#			print("Snap turn")
#			returned_to_dead_zone = true
