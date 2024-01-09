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

var amplitude = 10
var length = 5
var width = 5

var my_rotation = Vector3(0,0,0)
var my_height = 1
var my_scale_x = 1
var my_scale_z = 1
#var visible = false
var offset_distance = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	selection_box = null
	%Tree.visible = false
	%Bush.visible = false
	%Rock.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if translate_map:
		print("translating")
		self.global_position = (%LeftController.global_position + %RightController.global_position) / 2;
		var difference = abs(%LeftController.global_position.distance_to(%RightController.global_position));
		my_scale_x = difference
		my_scale_z = difference
		#self.look_at(%LeftController.global_position);
		my_rotation = self.rotation
		my_height = min(self.global_position.y, 1)
	else:
		if left_hold_map:
			var left_controller_transform = %LeftController.global_transform
			var offset_vector = -left_controller_transform.basis.z * offset_distance
			self.global_transform.origin = left_controller_transform.origin + offset_vector
			var terrain_rotation = left_controller_transform.basis.get_euler()
			terrain_rotation.x = 0
			terrain_rotation.z = 0 
			var rotated_basis = Basis(Quaternion(Vector3(0, terrain_rotation.y, 0).normalized(), 0))
			global_transform.basis = rotated_basis
			my_height = %LeftController.global_position.y
			
		if right_hold_map:
			var right_controller_transform = %RightController.global_transform
			var offset_vector = -right_controller_transform.basis.z * offset_distance
			self.global_transform.origin = right_controller_transform.origin + offset_vector
			var terrain_rotation = right_controller_transform.basis.get_euler()
			terrain_rotation.x = 0
			terrain_rotation.z = 0 
			var rotated_basis = Basis(Quaternion(Vector3(0, terrain_rotation.y, 0).normalized(), 0))
			global_transform.basis = rotated_basis
			my_height = %RightController.global_position.y
			
		if left_selecting:
			set_corner(2, %LeftController.global_position)
		if right_selecting:
			set_corner(2, %RightController.global_position)
	self.rotation = my_rotation
	self.global_position.y = my_height
	self.scale.x = my_scale_x
	self.scale.z = my_scale_z
	#$CollisionShape3D.global_transform = $Map.global_transform
func _on_left_button_pressed(name):
	if name == "grip_click" && %LeftController/Area3D.overlaps_body(self):
		print("left grip")
		if map_visible:
			if right_hold_map:
				translate_map = true
				left_hold_map = true
			elif !right_hold_map:
				left_hold_map = true
				self.visible = true
				%Tree.visible = true
				%Bush.visible = true
				%Rock.visible = true
	if name == "ax_button":
		if map_visible:
			map_visible = false
			self.visible = false
		else:
			map_visible = true
			self.visible = true
			%Tree.visible = true
			%Bush.visible = true
			%Rock.visible = true
			map_default_position()
	if !left_hold_map && name == "trigger_click":
		left_selecting = true
		set_corner(2, %LeftController.global_position)
		set_corner(1, %RightController.global_position)
		$Map/SelectionBox.visible = true
		

func _on_left_controller_button_released(name):
	if name == "trigger_click" && left_selecting:
		left_selecting = false
		set_corner(2, %LeftController.global_position)		
		generate_terrain()
		$Map/SelectionBox.mesh.material.set_shader_parameter("corner2", Vector2(0,0))
		$Map/SelectionBox.mesh.material.set_shader_parameter("corner1", Vector2(0,0))
		$Map/SelectionBox.visible = false
	if name == "grip_click" && left_hold_map:
		left_hold_map = false
		translate_map = false
		
		
func _on_right_button_pressed(name):
	if name == "grip_click" && %RightController/Area3D.overlaps_body(self):
		if map_visible:
			if left_hold_map:
				translate_map = true
				right_hold_map = true
			elif !left_hold_map:
				right_hold_map = true
				self.visible = true
				%Tree.visible = true
				%Bush.visible = true
				%Rock.visible = true
	if name == "ax_button":
		if map_visible:
			map_visible = false
			self.visible = false
		else:
			map_visible = true
			self.visible = true
			%Tree.visible = true
			%Bush.visible = true
			%Rock.visible = true
			map_default_position()
	if !right_hold_map && name == "trigger_click" && map_visible:
		right_selecting = true
		$Map/SelectionBox.visible = true
		set_corner(2, %RightController.global_position)
		set_corner(1, %RightController.global_position)
	


func _on_right_button_released(name):
	if name == "trigger_click" && right_selecting:
		right_selecting = false
		set_corner(2, %RightController.global_position)
		generate_terrain()
		$Map/SelectionBox.mesh.material.set_shader_parameter("corner2", Vector2(0,0))
		$Map/SelectionBox.mesh.material.set_shader_parameter("corner1", Vector2(0,0))
		$Map/SelectionBox.visible = false
	if name == "grip_click" && right_hold_map:
		right_hold_map = false
		translate_map = false
func set_corner(corner, pos):
	var local_pos = $Map.to_local(pos)
	var corner_pos = Vector2(clamp(local_pos.x, 0, 0.5) * 2, clamp(local_pos.z, 0, 0.5) * 2)
	if corner == 1:
		var other_corner = $Map/SelectionBox.mesh.material.get_shader_parameter("corner2")
		if corner_pos.x > other_corner.x && corner_pos.y > other_corner.y:
			corner1 = corner2
			corner2 = corner_pos
			$Map/SelectionBox.mesh.material.set_shader_parameter("corner2", corner2)
			$Map/SelectionBox.mesh.material.set_shader_parameter("corner1", corner1)
		else:
			corner1 = corner_pos
			$Map/SelectionBox.mesh.material.set_shader_parameter("corner1", corner1)
	else:
		var other_corner = $Map/SelectionBox.mesh.material.get_shader_parameter("corner1")
		if corner_pos.x < other_corner.x && corner_pos.y < other_corner.y:
			corner2 = corner1
			corner1 = corner_pos
			$Map/SelectionBox.mesh.material.set_shader_parameter("corner2", corner2)
			$Map/SelectionBox.mesh.material.set_shader_parameter("corner1", corner1)
		else:
			corner2 = corner_pos
			$Map/SelectionBox.mesh.material.set_shader_parameter("corner2", corner2)
			
func generate_terrain():
	var adjusted_corner2 = Vector2(round((corner2.x/2) * 1026), round((corner2.y/2) * 1026))
	var adjusted_corner1 = Vector2(round((corner1.x/2) * 1026), round((corner1.y/2) * 1026))
	get_node("/root/Main")._edit(min(adjusted_corner1.y, adjusted_corner2.y), max(adjusted_corner1.y, adjusted_corner2.y), min(adjusted_corner1.x, adjusted_corner2.x), max(adjusted_corner1.x, adjusted_corner2.x), amplitude, width, length)
	
func map_default_position():
	var transform = %XROrigin3D.global_transform
	var offset_vector = -transform.basis.z * offset_distance * 2
	self.global_transform.origin = transform.origin + offset_vector
	var terrain_rotation = transform.basis.get_euler()
	terrain_rotation.x = 0
	terrain_rotation.z = 0 
	var rotated_basis = Basis(Quaternion(Vector3(0, terrain_rotation.y, 0).normalized(), 0))
	global_transform.basis = rotated_basis
	my_height = 1
	self.global_position.y = my_height
	my_scale_x = 1
	my_scale_z = 1
	self.scale.x = my_scale_x
	self.scale.z = my_scale_z
