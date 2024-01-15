extends RigidBody3D

var left_hold_map = false
var right_hold_map = false

var left_selecting = false
var right_selecting = false

var map_visible = false
var translate_map = false
var corner1 = Vector2(0,0)
var corner2 = Vector2(0,0)

var plane_size = Vector2(1, 1)
var selection_box = null
var current_size = Vector2(0.1, 0.1)

#var amplitude = 4
#var length = 2
#var width = 2

var my_rotation = Vector3(0,0,0)
var my_scale_x = 1
var my_scale_z = 1

var my_x = 0
var my_z = 0
var my_y = 1
var offset_distance = 0.1

func _ready():
	selection_box = null
	%Tree.visible = false
	%Bush.visible = false
	%Rock.visible = false

func _process(_delta):
	if map_visible:
		if translate_map:
			self.global_position = (%LeftController.global_position + %RightController.global_position) / 2;
			var difference = abs(%LeftController.global_position.distance_to(%RightController.global_position));
			self.look_at(%LeftController.global_position);
			my_scale_x = difference
			my_scale_z = difference
			self.look_at(%LeftController.global_position);
			my_rotation = self.rotation
			my_y = self.global_position.y
			my_x = self.global_position.x
			my_z = self.global_position.z
		else:
			if left_hold_map:
				var left_controller_transform = %LeftController.global_transform
				var offset_vector = -left_controller_transform.basis.z * offset_distance
				self.global_transform.origin = left_controller_transform.origin + offset_vector
				var terrain_rotation = left_controller_transform.basis.get_euler()
				terrain_rotation.x = 0
				terrain_rotation.z = 0 
				var rotated_basis = Basis(Quaternion(Vector3(0, terrain_rotation.y, 0).normalized(), 0))
				self.global_transform.basis = rotated_basis
				my_y = %LeftController.global_position.y
				#my_y = self.global_position.y
				my_x = self.global_position.x
				my_z = self.global_position.z
			elif right_hold_map:
				var right_controller_transform = %RightController.global_transform
				var offset_vector = -right_controller_transform.basis.z * offset_distance
				self.global_transform.origin = right_controller_transform.origin + offset_vector
				var terrain_rotation = right_controller_transform.basis.get_euler()
				terrain_rotation.x = 0
				terrain_rotation.z = 0 
				var rotated_basis = Basis(Quaternion(Vector3(0, terrain_rotation.y, 0).normalized(), 0))
				self.global_transform.basis = rotated_basis
				my_y = %RightController.global_position.y
				#my_y = self.global_position.y
				my_x = self.global_position.x
				my_z = self.global_position.z
			else:
				self.global_position.x = my_x
				self.global_position.z = my_z
				self.global_position.y = my_y
			if left_selecting:
				set_corner(2, %LeftController.global_position)
			if right_selecting:
				set_corner(2, %RightController.global_position)
		self.rotation = my_rotation
		self.global_position.y = my_y
		self.scale.x = my_scale_x
		self.scale.z = my_scale_z

func _on_left_button_pressed(button_name):
	if button_name == "grip_click" && %LeftController/Area3D.overlaps_body(self):
		if map_visible:
			if right_hold_map:
				translate_map = true
				left_hold_map = true
			elif !right_hold_map:
				left_hold_map = true
				map_visible = true
				self.visible = map_visible
				%Tree.visible = true
				%Bush.visible = true
				%Rock.visible = true
	if button_name == "ax_button"  && !%GraphRigidBody.visible:
		if map_visible:
			map_visible = false
			self.visible = map_visible
		else:
			map_visible = true
			self.visible = map_visible
			%Tree.visible = true
			%Bush.visible = true
			%Rock.visible = true
			map_default_position()
	if !left_hold_map && button_name == "trigger_click":
		left_selecting = true
		set_corner(2, %LeftController.global_position)
		set_corner(1, %RightController.global_position)
		$Map/SelectionBox.visible = true
		

func _on_left_button_released(button_name):
	if button_name == "trigger_click" && left_selecting:
		left_selecting = false
		set_corner(2, %LeftController.global_position)		
		%GraphRigidBody.visible = true
		%GraphRigidBody.global_position = self.global_position
		$Map/SelectionBox.visible = false
		map_visible = false
		self.visible = map_visible
	if button_name == "grip_click" && left_hold_map:
		left_hold_map = false
		if translate_map:
			right_hold_map = false
			translate_map = false
		
		
		
func _on_right_button_pressed(button_name):
	if button_name == "grip_click" && %RightController/Area3D.overlaps_body(self):
		if map_visible:
			if left_hold_map:
				translate_map = true
				right_hold_map = true
			elif !left_hold_map:
				right_hold_map = true
				map_visible = true
				self.visible = map_visible
				%Tree.visible = true
				%Bush.visible = true
				%Rock.visible = true
	if button_name == "ax_button" && !%GraphRigidBody.visible:
		if map_visible:
			map_visible = false
			self.visible = map_visible
		else:
			map_visible = true
			self.visible = map_visible
			%Tree.visible = true
			%Bush.visible = true
			%Rock.visible = true
			map_default_position()
	if !right_hold_map && button_name == "trigger_click" && map_visible:
		right_selecting = true
		$Map/SelectionBox.visible = true
		set_corner(2, %RightController.global_position)
		set_corner(1, %RightController.global_position)
	


func _on_right_button_released(button_name):
	if button_name == "trigger_click" && right_selecting:
		right_selecting = false
		set_corner(2, %RightController.global_position)
		%GraphRigidBody.visible = true
		%GraphRigidBody.global_position = self.global_position
		$Map/SelectionBox.visible = false
		map_visible = false 
		self.visible = map_visible
	if button_name == "grip_click" && right_hold_map:
		right_hold_map = false
		if translate_map:
			left_hold_map = false
			translate_map = false
		
		
func set_corner(corner, pos):
	var local_pos = $Map/SelectionBox.to_local(pos)
	var corner_pos = Vector2(local_pos.x, local_pos.z)
	if corner == 1:
		corner1 = corner_pos
		$Map/SelectionBox.mesh.material.set_shader_parameter("corner1", corner1)
	else:
		corner2 = corner_pos
		$Map/SelectionBox.mesh.material.set_shader_parameter("corner2", corner2)
			
func generate_terrain(amplitude, width, length):
	print(corner1)
	print(corner2)
	var adjusted_corner2 = Vector2(round((-corner2.x) * 1026), round((-corner2.y) * 1026))
	var adjusted_corner1 = Vector2(round((-corner1.x) * 1026), round((-corner1.y) * 1026))
	print(adjusted_corner1)
	print(adjusted_corner2)
	get_node("/root/Main")._edit(512 - clamp(max(adjusted_corner1.y, adjusted_corner2.y), 0, 512), 512 - clamp(min(adjusted_corner1.y, adjusted_corner2.y), 0, 512), 512 - clamp(max(adjusted_corner1.x, adjusted_corner2.x), 0, 512), 512 - clamp(min(adjusted_corner1.x, adjusted_corner2.x), 0, 512), amplitude, width, length)
	#reset all previously place objects according to the new height map!
	var large_objects = get_tree().get_nodes_in_group("large_objects")
	for object in large_objects:
		var globals = get_node("/root/Globals")
		var terrain_data = globals.terrian_info
		var big_height = terrain_data.get_height_at((object.global_position.x+50)*5.13,(object.global_position.z+50)*5.13)
		if big_height > 0:
			object.global_position.y = big_height / 5.13 + 0.2
			print("adjusted height", object.name, big_height / 5.13 +0.2)
		elif big_height < 0:
			object.global_position.y = big_height / 5.13 - 0.2
			print("adjusted height",object.name, big_height / 5.13 -0.2)
		else:
			object.global_position.y = 0

func map_default_position():
	var xr_origin_transform = %XROrigin3D.global_transform
	var offset_vector = -xr_origin_transform.basis.z * offset_distance
	self.global_transform.origin = xr_origin_transform.origin + offset_vector

	self.rotation = Vector3(0,0,0)		
	my_y = 1
	my_scale_x = 1
	my_scale_z = 1
	my_rotation = Vector3(0,0,0)
	my_x = self.global_position.x
	my_z = self.global_position.z
	self.scale.x = my_scale_x
	self.scale.z = my_scale_z
	#my_rotation = %XROrigin3D.rotation

	
