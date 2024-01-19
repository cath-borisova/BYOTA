extends Label3D

var camera = null
var equation = null
var globals = null

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = %XRCamera3D
	globals = get_node("/root/Globals")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if %Tree.visible == false && %GraphRigidBody.visible == false:
		self.visible = true
		if !equation:
			#change text to user position
			self.text = "X: " + str(round(%XROrigin3D.global_position.x)) + " Y: " + str(round(%XROrigin3D.global_position.y)) + " Z: " + str(round(%XROrigin3D.global_position.z))
		elif equation:
			var globals = get_node("/root/Globals")
			var equation = globals.get_equation(clamp(round((%XROrigin3D.global_position.x+50)*5.13), 0, 512), clamp(round((%XROrigin3D.global_position.z+50)*5.13), 0, 512))
			self.text = "y = "+ str(equation[0]) + " * sin(" + str(equation[1]) + " * " + str(round(%XROrigin3D.global_position.x)) + ") * cos("+ str(equation[2])+ " * "+ str(round(%XROrigin3D.global_position.z)) + ")"	
		var new_position = camera.global_position + -(camera.global_transform).basis.z.normalized() * 0.5
		new_position.y = %XROrigin3D.global_position.y + 0.9
		self.global_transform.origin = new_position
		var projected_camera_pos = camera.global_position
		projected_camera_pos.y = %XROrigin3D.global_position.y + 0.9
		self.look_at(projected_camera_pos, Vector3(0, 1, 0))
	else:
		self.visible = false
	
func _on_right_controller_button_pressed(button_name):
	if button_name == "trigger_click" and !%MapRigidBody.visible:
		equation = !equation

func _on_left_controller_button_pressed(button_name):
	if button_name == "trigger_click" and !%MapRigidBody.visible:
		equation = !equation
