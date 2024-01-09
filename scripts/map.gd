extends RigidBody3D

var left_hold_map = false
var right_hold_map = false

var left_selecting = false
var right_selecting = false

var corner1 = Vector2(0,0)
var corner2 = Vector2(0,0)

var plane_size = Vector2(1, 1)
var selection_box = null
var current_size = Vector2(0.1, 0.1)

var amplitude = 4
var length = 2
var width = 2

#var visible = false
var offset_distance = 0.2
# Called when the node enters the scene tree for the first time.
func _ready():
	selection_box = null
	%Tree.visible = false
	%Bush.visible = false
	%Rock.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.global_position.y = 1.5
	if left_hold_map:
		var left_controller_transform = %LeftController.global_transform
		var offset_vector = -left_controller_transform.basis.z * offset_distance
		$Map.global_transform.origin = left_controller_transform.origin + offset_vector
		var terrain_rotation = left_controller_transform.basis.get_euler()
		terrain_rotation.x = 0
		terrain_rotation.z = 0 
		var rotated_basis = Basis(Quaternion(Vector3(0, terrain_rotation.y, 0).normalized(), 0))
		global_transform.basis = rotated_basis
		$Map.global_position.y = %LeftController.global_position.y
		$CollisionShape3D.global_position = $Map.global_position
	if right_hold_map:
		var right_controller_transform = %RightController.global_transform
		var offset_vector = -right_controller_transform.basis.z * offset_distance
		$Map.global_transform.origin = right_controller_transform.origin + offset_vector
		var terrain_rotation = right_controller_transform.basis.get_euler()
		terrain_rotation.x = 0
		terrain_rotation.z = 0 
		var rotated_basis = Basis(Quaternion(Vector3(0, terrain_rotation.y, 0).normalized(), 0))
		global_transform.basis = rotated_basis
		$Map.global_position.y = %RightController.global_position.y
		$CollisionShape3D.global_position = $Map.global_position
	if left_selecting:
		set_corner(2, %LeftController.global_position)
		
	if right_selecting:
		set_corner(2, %RightController.global_position)
func _on_left_button_pressed(name):
	if name == "ax_button":
		if left_hold_map:
			left_hold_map = false
			self.visible = false
			%Tree.visible = false
			%Bush.visible = false
			%Rock.visible = false
			
		elif !right_hold_map:
			left_hold_map = true
			self.visible = true
			%Tree.visible = true
			%Bush.visible = true
			%Rock.visible = true

			
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

func _on_right_button_pressed(name):
	if name == "ax_button":
		if right_hold_map:
			right_hold_map = false
			self.visible = false
			%Tree.visible = false
			%Bush.visible = false
			%Rock.visible = false
			
			
		elif !left_hold_map:
			right_hold_map = true
			self.visible = true
			%Tree.visible = true
			%Bush.visible = true
			%Rock.visible = true
			
	if !right_hold_map && name == "trigger_click":
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
