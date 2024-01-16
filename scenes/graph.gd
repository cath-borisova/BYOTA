extends RigidBody3D

var left_hold_graph = false
var right_hold_graph = false

var left_selecting = false
var right_selecting = false

var translate_graph = false

var my_rotation = Vector3(0,0,0)
var my_scale_x = 1
var my_scale_z = 1

#var my_x = 0
#var my_z = 0
var my_y = 1

var offset_distance = 0.1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if self.visible:
		if translate_graph:
			self.global_position = (%LeftController.global_position + %RightController.global_position) / 2;
			var difference = abs(%LeftController.global_position.distance_to(%RightController.global_position));
			self.look_at(%LeftController.global_position);
			my_scale_x = difference
			my_scale_z = difference
			self.look_at(%LeftController.global_position);
			my_rotation = self.rotation
			my_y = self.global_position.y
		else:
			if left_hold_graph:
				var left_controller_transform = %LeftController.global_transform
				var offset_vector = -left_controller_transform.basis.z * offset_distance
				self.global_transform.origin = left_controller_transform.origin + offset_vector
				var graph_rotation = left_controller_transform.basis.get_euler()
				graph_rotation.x = 0
				graph_rotation.z = 0 
				var rotated_basis = Basis(Quaternion(Vector3(0, graph_rotation.y, 0).normalized(), 0))
				self.global_transform.basis = rotated_basis
				my_y = %LeftController.global_position.y
			elif right_hold_graph:
				var right_controller_transform = %RightController.global_transform
				var offset_vector = -right_controller_transform.basis.z * offset_distance
				self.global_transform.origin = right_controller_transform.origin + offset_vector
				var graph_rotation = right_controller_transform.basis.get_euler()
				graph_rotation.x = 0
				graph_rotation.z = 0 
				var rotated_basis = Basis(Quaternion(Vector3(0, graph_rotation.y, 0).normalized(), 0))
				self.global_transform.basis = rotated_basis
				my_y = %RightController.global_position.y
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
	#%MapRigidBody.visible = true
	var globals = get_node("/root/Globals")
	%MapRigidBody.generate_terrain(globals.y_axis_number, globals.x_axis_number_symbol[2], globals.z_axis_number_symbol[2])

func cancel():
	self.visible = false
	#%MapRigidBody.visible = true
	
func _graph_default_position():
	var xr_origin_transform = %XROrigin3D.global_transform
	var offset_vector = -xr_origin_transform.basis.z * offset_distance
	self.global_transform.origin = xr_origin_transform.origin + offset_vector

	self.rotation = Vector3(0,0,0)		
	#my_y = 1
	#my_scale_x = 1
	#my_scale_z = 1
	#my_rotation = Vector3(0,0,0)
	#my_x = self.global_position.x
	#my_z = self.global_position.z
	#self.scale.x = my_scale_x
	#self.scale.z = my_scale_z
