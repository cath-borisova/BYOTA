extends RigidBody3D

var left_hold_graph = false
var right_hold_graph = false

var left_selecting = false
var right_selecting = false

var translate_graph = false

var my_rotation = Vector3(0,0,0)
var my_scale_x = 1
var my_scale_z = 1

var my_y = 1
var my_x = 0
var my_z = 0

var offset_distance = 0.1

var globals = null
func _ready():
	globals = get_node("/root/Globals")

func _process(_delta):
	if self.visible:
		if translate_graph:
			var difference = globals.spindle(self)
			my_scale_x = difference
			my_scale_z = difference
			my_rotation = self.rotation
			my_y = self.global_position.y
		else:
			if left_hold_graph:
				globals.transform(self, %LeftController)
				my_y = %LeftController.global_position.y
			elif right_hold_graph:
				globals.transform(self, %RightController)
				my_y = %RightController.global_position.y
			else:
				self.global_position.x = my_x
				self.global_position.z = my_z
		my_x = self.global_position.x
		my_z = self.global_position.z
		self.rotation = my_rotation
		self.global_position.y = my_y
		self.scale.x = my_scale_x
		self.scale.z = my_scale_z
		

func _on_left_button_pressed(button_name):
	if button_name == "grip_click" && %LeftController/Area3D.overlaps_body(self):
		if self.visible:
			if right_hold_graph:
				translate_graph = true
				left_hold_graph = true
			elif !right_hold_graph:
				left_hold_graph = true
				self.visible = true

func _on_left_controller_button_released(button_name):
	if button_name == "grip_click" && left_hold_graph:
		left_hold_graph = false
		if translate_graph:
			right_hold_graph = false
			translate_graph = false
		
func _on_right_button_pressed(button_name):
	if button_name == "grip_click" && %RightController/Area3D.overlaps_body(self):
		if self.visible:
			if left_hold_graph:
				translate_graph = true
				right_hold_graph = true
			elif !left_hold_graph:
				right_hold_graph = true
				self.visible = true

func _on_right_button_released(button_name):
	if button_name == "grip_click" && right_hold_graph:
		right_hold_graph = false
		if translate_graph:
			left_hold_graph = false
			translate_graph = false
		
func create():
	self.visible = false
	var globals = get_node("/root/Globals")
	%MapRigidBody.generate_terrain(globals.y_axis_number[1], globals.x_axis_number_symbol[1], globals.z_axis_number_symbol[1], globals.x_axis_number_symbol[0], globals.z_axis_number_symbol[0], globals.y_axis_number[0])

func cancel():
	self.visible = false

func graph_default_position():
	#globals.position_relative_to_user(self)
	#print(%XROrigin3D.global_position)
	self.global_position = %XROrigin3D.global_position
	self.global_position.y += 0.5
	my_y = self.global_position.y
	my_x = self.global_position.x
	my_z = self.global_position.z
