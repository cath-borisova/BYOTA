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
var length = 2
var width = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	selection_box = null
	%Tree.visible = false
	%Bush.visible = false
	%Rock.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# dont worry about this code its not relevant
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
		# if left hand is free and press trigger click, let the selection box appear and send in the current corners (theyre the same so doesnt matter)
		left_selecting = true
		set_corner(2, %LeftController.global_position)
		set_corner(1, %LeftController.global_position)
		$Map/SelectionBox.visible = true
		

func _on_left_controller_button_released(name):
	if name == "trigger_click" && left_selecting:
		# if you released trigger when selecting, hide map, and set the second corner
		left_selecting = false
		set_corner(2, %LeftController.global_position)		
		#ignore
		generate_terrain()
		#defaults the corners to 0. i dont think this should do anything
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
			$Map.position.z += 1
			
	if !right_hold_map && name == "trigger_click":
		# same as before, if trigger with right hand send in its positions 
		right_selecting = true
		$Map/SelectionBox.visible = true
		set_corner(2, %RightController.global_position)
		set_corner(1, %RightController.global_position)
	


func _on_right_button_released(name):
	if name == "trigger_click" && right_selecting:
		# if right hand let go of corner get second corner
		right_selecting = false
		set_corner(2, %RightController.global_position)
		generate_terrain()
		$Map/SelectionBox.mesh.material.set_shader_parameter("corner2", Vector2(0,0))
		$Map/SelectionBox.mesh.material.set_shader_parameter("corner1", Vector2(0,0))
		$Map/SelectionBox.visible = false
		
func set_corner(corner, pos):
	#i played around with a lot of stuff here...
	# takes pos of the corner sent in as a parameter and maps it from global space to the map's local space (since the shader is a child of the map and uses the map local space)
	var local_pos = $Map.to_local(pos)
	# then make sure the coordinates are in bounds (0 to 0.5) in case someone started/ended selecting outside of the map
	var corner_pos = Vector2(clamp(local_pos.x, 0, 0.5), clamp(local_pos.z, 0, 0.5))
	#the thought process below was make sure corner 1 is always top left and corner 2 is always bottom right, so compare values and if corner 1 is about to have "bottom right" values, then swap them
	#it kind of works? no worse than anything else so feel free to uncomment and try 
	
	#var corner_pos = Vector2(local_pos.x, local_pos.z)
		#if corner == 1:
			#
			#var other_corner = $Map/SelectionBox.mesh.material.get_shader_parameter("corner2")
			#
			#if corner_pos.x > other_corner.x && corner_pos.y < other_corner.y:
				#
				#corner1 = corner2
				#corner2 = corner_pos
				#$Map/SelectionBox.mesh.material.set_shader_parameter("corner2", corner2)
				#$Map/SelectionBox.mesh.material.set_shader_parameter("corner1", corner1)
			#else:
				#corner1 = corner_pos
				#$Map/SelectionBox.mesh.material.set_shader_parameter("corner1", corner1)
		#else:
			#var other_corner = $Map/SelectionBox.mesh.material.get_shader_parameter("corner1")
			#if corner_pos.x > other_corner.x && corner_pos.y < other_corner.y:
				#corner2 = corner1
			#corner1 = corner_pos
			#$Map/SelectionBox.mesh.material.set_shader_parameter("corner2", corner2)
			#$Map/SelectionBox.mesh.material.set_shader_parameter("corner1", corner1)
		#else:
			#corner2 = corner_pos
			#$Map/SelectionBox.mesh.material.set_shader_parameter("corner2", corner2)
	
	#the thouoght process here was make corner 1 the smallest values since top left is (0,0) and corner 2 the bigger values so like (0.5, 0.5)
	$Map/SelectionBox.mesh.material.set_shader_parameter("corner1", Vector2(min(corner1.x, corner2.x), min(corner1.y, corner2.y)))
	$Map/SelectionBox.mesh.material.set_shader_parameter("corner2", Vector2(max(corner1.x, corner2.x), max(corner1.y, corner2.y)))
	#stuff worth noting:
	#1. when i print the final coordinates (below in generate_terrain), top left is (0, 0.5) and bottom right is (0.5. 0)
	#but when i play around in the inspector, it seems like corner 1 maps to top right and corner 2 maps to bottom left (e.g. if you set corner 1 to (0,0) and corner 2 to (0.5, 0.5)
	# it covers the whole map (and in line 161 i just said top left is (0, 0.5) so it makes sense that top right is (0,0) i think?)
	#2. so thereotically the uncommented code doesnt make sense and shouldnt work? but if i do this:
	#$Map/SelectionBox.mesh.material.set_shader_parameter("corner1", Vector2(min(corner1.x, corner2.x), max(corner1.y, corner2.y)))
	#$Map/SelectionBox.mesh.material.set_shader_parameter("corner2", Vector2(max(corner1.x, corner2.x), min(corner1.y, corner2.y)))
	#it doesnt work?
	
			
func generate_terrain():
	print("CORNER 1: ", $Map/SelectionBox.mesh.material.get_shader_parameter("corner1"))
	print("CORNER 2: ", $Map/SelectionBox.mesh.material.get_shader_parameter("corner2"))
	print("\n")
	#you can ignore this, generate terrain is just the last thing called when triggers are releasesd so i use it to print
	
	#keep in mind that terrain is going to be off rn because we are playing with the coordinates and im going to have to remap it later
	var adjusted_corner2 = Vector2(floor((corner2.x/2 * 512)), floor((corner2.y/2 * 512)))
	var adjusted_corner1 = Vector2(floor((corner1.x/2 * 512)), floor((corner1.y/2 * 512)))
	get_node("/root/Main")._edit(min(adjusted_corner1.y, adjusted_corner2.y), max(adjusted_corner1.y, adjusted_corner2.y), min(adjusted_corner1.x, adjusted_corner2.x), max(adjusted_corner1.x, adjusted_corner2.x), amplitude, width, length)
