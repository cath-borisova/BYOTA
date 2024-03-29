extends Label3D

var camera = null
var equation = 0
var globals = null

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = %XRCamera3D
	globals = get_node("/root/Globals")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if globals.item_showing == 0 || globals.item_showing == 3:
		self.visible = false
	elif globals.item_showing == 1:
		#change text to user position
		#self.text = "X: " + str(round(%XROrigin3D.global_position.x*pow(10,2))/pow(10,2)) + "\nY: " + str(round(%XROrigin3D.global_position.y*pow(10,2))/pow(10,2)) + "\nZ: " + str(round(%XROrigin3D.global_position.z*pow(10,2))/pow(10,2))
		var x_z = globals.global_to_hterrain(self.global_position.x, self.global_position.z)
		var terrain_data = globals.terrian_info
		var new_coordinates = globals.global_to_hterrain(self.global_position.x, self.global_position.z)
		var y =  round(terrain_data.get_height_at(new_coordinates.x, new_coordinates.y))
		self.text = "X: " + str(x_z.x) + "\nY: " + str(y) + "\nZ: " + str(x_z.y)
	elif globals.item_showing == 2:
		
		#var globals = get_node("/root/Globals")
		#var equation = globals.get_equation(clamp(round((%XROrigin3D.global_position.x+50)*5.13), 0, 512), clamp(round((%XROrigin3D.global_position.z+50)*5.13), 0, 512))
		#self.text = "y = "+ str(equation[0]) + " * sin(" + str(equation[1]) + " * " + str(round(%XROrigin3D.global_position.x*pow(10,2))/pow(10,2)) + ") * cos("+ str(equation[2])+ " * "+ str(round(%XROrigin3D.global_position.z*pow(10,2))/pow(10,2)) + ")"
		self.text = globals.get_equation(self.global_position.x, self.global_position.z)
	#var new_position = camera.global_position + -(camera.global_transform).basis.z.normalized() * 0.5
	#new_position.y = %XROrigin3D.global_position.y + 1.0
	#self.global_transform.origin = new_position
	#var projected_camera_pos = camera.global_position
	#projected_camera_pos.y = %XROrigin3D.global_position.y + 1.0
	#self.look_at(projected_camera_pos, Vector3(0, 1, 0))
	globals.position_above_user(self)

	
#func _on_right_controller_button_pressed(button_name):
	#if button_name == "trigger_click" and !%MapRigidBody.visible:
		#globals.item_showing = (globals.item_showing + 1/4)
		#self.visible = true

func _on_left_controller_button_released(button_name):
	if button_name == "by_button":
		globals.item_showing = (globals.item_showing + 1) % 4
		self.visible = true
