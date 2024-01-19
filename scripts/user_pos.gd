extends Label3D

var camera
var equation
# Called when the node enters the scene tree for the first time.
func _ready():
	camera = %XRCamera3D
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !equation:
		#change text to user position
		self.text = "X: " + str(round(%XROrigin3D.global_position.x)) + " Y: " + str(round(%XROrigin3D.global_position.y)) + " Z: " + str(round(%XROrigin3D.global_position.z))
	elif equation:
		var globals = get_node("/root/Globals")
		var equation = globals.get_equation((%XROrigin3D.global_position.x+50)*5.13,(%XROrigin3D.global_position.z+50)*5.13)
		self.text = "y = "+ str(equation[0]) + " * sin(" + str(equation[1]) + " * " + str(round(%XROrigin3D.global_position.x)) + ") * cos("+ str(equation[2])+ " * "+ str(round(%XROrigin3D.global_position.z)) + ")"	
	var new_position = camera.global_position + -(camera.global_transform).basis.z.normalized() * 0.5
	new_position.y = 1.8
	self.global_transform.origin = new_position
	var projected_camera_pos = camera.global_position
	projected_camera_pos.y = 1.2
	self.look_at(projected_camera_pos, Vector3(0, 1, 0))
	
	pass
	
func _on_right_controller_button_pressed(button_name):
	if button_name == "trigger_click" and !%MapRigidBody.visible:
		equation = !equation

func _on_left_controller_button_pressed(button_name):
	if button_name == "trigger_click" and !%MapRigidBody.visible:
		equation = !equation
