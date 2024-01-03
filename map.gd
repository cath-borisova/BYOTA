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

var amplitude = 10
var length = 5
var width = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	selection_box = null
	%Tree.visible = false
	%Bush.visible = false
	%Rock.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print("corner1: ", corner1)
	#print("shader corner1: ", $Map/TEST.mesh.material.get_shader_parameter("corner1"))
	#print("corner2: ", corner2)
	#print("shader corner2: ", $Map/TEST.mesh.material.get_shader_parameter("corner2"))
	#print("\n\n")
	#print("")
	self.global_position.y = 1.5
	if left_hold_map:
		var controller_position = %LeftController.global_position
		var position_adjustment = %LeftController.global_transform.origin + Vector3(-plane_size.x / 3, 0, -plane_size.y / 2)
		$Map.global_transform.origin = position_adjustment
		$Map.global_position.y = controller_position.y
		$CollisionShape3D.global_position = $Map.global_position
		self.rotation = Vector3(0,0,0)
	if right_hold_map:
		var controller_position = %RightController.global_position
		var position_adjustment = %RightController.global_transform.origin - Vector3(plane_size.x / 3, -plane_size.y / 3, 0)    
		$Map.global_transform.origin = position_adjustment
		$Map.global_position.y = controller_position.y
		$CollisionShape3D.global_position = $Map.global_position
		self.rotation = Vector3(0,0,0)
	if left_selecting:
		#var corner2 = $Map/SelectionBox.to_local(%RightController.global_position)
		set_corner(2, %LeftController.global_position)
		#$Map/SelectionBox.mesh.material.set_shader_parameter("corner2", Vector2(clamp(corner2.x, 0, 0.5), clamp(corner2.z, 0, 0.5)))
		#var current_position = Vector2(%LeftController.global_position.x - current_size.x, %LeftController.global_position.z + current_size.y)
		#var current_size = Vector2(current_position.x/corner1.x, current_position.y/corner1.y)
		#
		#$Map/SelectionBox.scale = Vector3(current_size.x, 0, current_size.y)
		
	if right_selecting:
		#%Shader.set_shader_param("corner1", Vector3(-2, -2, 0))
		#%Shader.set_shader_param("corner2", Vector3(2, 2, 0))
		#var x = min($Map.global_position.x + 0.5, max(%RightController.global_position.x, $Map.global_position.x))
		#var z = min($Map.global_position.z + 0.5, max(%RightController.global_position.z, $Map.global_position.z))
		#if x = top_left_coo
		#var size_x = max(x, top_left_coordinate.x)
		#var size_y = max(y, top_left_coordinate.y)
		#var current_size = Vector2(current_position.x/top_left_coordinate.x, current_position.y/top_left_coordinate.y)
		#print("current size: ", current_size)
		#$Map/SelectionBox.scale = Vector3(current_size.x, 0, current_size.y)
		#print("map size: ", $Map/SelectionBox.scale)
		#print("map position: ", $Map/SelectionBox.position)
		#$Map/SelectionBox.position = Vector3(0,0.1, 0)
		
		#var corner2 = $Map/SelectionBox.to_local(%RightController.global_position)
		#$Map/SelectionBox.mesh.material.set_shader_parameter("corner2", Vector2(clamp(corner2.x, 0, 0.5), clamp(corner2.z, 0, 0.5)))
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
		#commmented
		#corner1 = $Map/SelectionBox.to_local(%RightController.global_position)
		#$Map/SelectionBox.mesh.material.set_shader_parameter("corner1",  Vector2(clamp(corner1.x, 0, 0.5), clamp(corner1.z, 0, 0.5)))
		set_corner(2, %LeftController.global_position)
		set_corner(1, %RightController.global_position)
		#$Map/SelectionBox.set_shader_param("corner2", Vector3(2, 2, 0))
		#$Map/SelectionBox.global_position.x = top_left_coordinate.x
		#$Map/SelectionBox.global_position.z = top_left_coordinate.y
		
		$Map/SelectionBox.visible = true
		

func _on_left_controller_button_released(name):
	if name == "trigger_click" && left_selecting:
		left_selecting = false
		set_corner(2, %LeftController.global_position)		
		generate_terrain()
		$Map/SelectionBox.mesh.material.set_shader_parameter("corner2", Vector2(0,0))
		$Map/SelectionBox.mesh.material.set_shader_parameter("corner1", Vector2(0,0))
		
		#corner2 = Vector2(%LeftController.global_position.x, %LeftController.global_position.z)
		#$Map/SelectionBox.visible = false

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
			$Map.position.z += 1
			
	if !right_hold_map && name == "trigger_click":
		right_selecting = true
		$Map/SelectionBox.visible = true
		#commented:
		#corner1 = $Map/SelectionBox.to_local(%LeftController.global_position)
		#$Map/SelectionBox.mesh.material.set_shader_parameter("corner1",  Vector2(clamp(corner1.x, 0, 1), clamp(corner1.z, 0, 1)))
		set_corner(2, %RightController.global_position)
		set_corner(1, %RightController.global_position)
		#$Map/SelectionBox.global_position.x = top_left_coordinate.x
		#k$Map/SelectionBox.global_position.z = top_left_coordinate.y
	


func _on_right_button_released(name):
	if name == "trigger_click" && right_selecting:
		right_selecting = false
		#corner2 = Vector2(%RightController.global_position.x, %RightController.global_position.z)
		#$Map/SelectionBox.mesh.material.set_shader_parameter("corner2",  Vector2(clamp(corner1.x, 0, 1), clamp(corner1.z, 0, 1)))
		#$Map/SelectionBox.visible = false
		set_corner(2, %RightController.global_position)
		generate_terrain()
		$Map/SelectionBox.mesh.material.set_shader_parameter("corner2", Vector2(0,0))
		$Map/SelectionBox.mesh.material.set_shader_parameter("corner1", Vector2(0,0))
		
func set_corner(corner, pos):
	print("corner ", corner)
	var local_pos = $Map.to_local(pos)
	print("local pos: ", local_pos)
	var corner_pos = Vector2(clamp(local_pos.x, 0, 0.5) * 2, clamp(local_pos.z, 0, 0.5) * 2)
	print("corner pos: ", corner_pos)
	if corner == 1:
		var other_corner = $Map/SelectionBox.mesh.material.get_shader_parameter("corner2")
		if corner_pos.x > other_corner.x && corner_pos.y > other_corner.y:
			corner1 = corner2
			corner2 = corner_pos
			$Map/SelectionBox.mesh.material.set_shader_parameter("corner2", corner2)
			$Map/SelectionBox.mesh.material.set_shader_parameter("corner1", corner1)
			print("one")
		else:
			corner1 = corner_pos
			$Map/SelectionBox.mesh.material.set_shader_parameter("corner1", corner1)
			print("two")
	else:
		var other_corner = $Map/SelectionBox.mesh.material.get_shader_parameter("corner1")
		if corner_pos.x < other_corner.x && corner_pos.y < other_corner.y:
			corner2 = corner1
			corner1 = corner_pos
			$Map/SelectionBox.mesh.material.set_shader_parameter("corner2", corner2)
			$Map/SelectionBox.mesh.material.set_shader_parameter("corner1", corner1)
			print("three")
		else:
			corner2 = corner_pos
			$Map/SelectionBox.mesh.material.set_shader_parameter("corner2", corner2)
			print("four")
	print("corner 1 position: ", $Map/SelectionBox.mesh.material.get_shader_parameter("corner1"))
	print("corner 2 position: ", $Map/SelectionBox.mesh.material.get_shader_parameter("corner2"))
	print("\n\n\n")
			
func generate_terrain():
	var adjusted_corner2 = Vector2(round((corner2.x/2) * 1026), round((corner2.y/2) * 1026))
	var adjusted_corner1 = Vector2(round((corner1.x/2) * 1026), round((corner1.y/2) * 1026))
	get_node("/root/Main")._edit(min(adjusted_corner1.y, adjusted_corner2.y), max(adjusted_corner1.y, adjusted_corner2.y), min(adjusted_corner1.x, adjusted_corner2.x), max(adjusted_corner1.x, adjusted_corner2.x), amplitude, width, length)
