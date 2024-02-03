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

var my_rotation = Vector3(0,0,0)
var my_scale_x = 1
var my_scale_z = 1

var my_x = 0
var my_z = 0
var my_y = 1
var offset_distance = 0.1

var right_hand_grabbed_mini = false
var left_hand_grabbed_mini = false
var mini_object = null

var hand_grabbed_user = false


var globals = null
func _ready():
	selection_box = null
	%Tree.visible = false
	%Bush.visible = false
	%Rock.visible = false
	globals = get_node("/root/Globals")

func _process(_delta):
	if map_visible:
		if translate_map:
			var difference = globals.spindle(self)
			my_scale_x = difference
			my_scale_z = difference
			my_rotation = self.rotation
			my_y = self.global_position.y
			my_x = self.global_position.x
			my_z = self.global_position.z
		else:
			if left_hold_map:
				globals.transform(self, %LeftController)
				my_y = self.global_position.y
				my_x = self.global_position.x
				my_z = self.global_position.z
			elif right_hold_map:
				globals.transform(self, %RightController)
				my_y = self.global_position.y
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
	if button_name == "grip_click":
		if map_visible:
			if %LeftController/Area3D.overlaps_body($Map/MiniUser):
				$Map/MiniUser.grabbed_left = true
				$Map/MiniUser.grabbed_right = false
				hand_grabbed_user = true
			else:
				for mini in get_tree().get_nodes_in_group("mini"):
						if %LeftController/Area3D.overlaps_body(mini):
							mini_object = mini
							left_hand_grabbed_mini = true
							mini.left_hand_grabbed = true
							break
				if mini_object == null && %LeftController/Area3D.overlaps_body(self):
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
	if button_name == "by_button":
		if %Tree.visible:
			%Tree.visible = false
			%Rock.visible = false
			%Bush.visible = false
		else:
			%Tree.visible = true
			%Rock.visible = true
			%Bush.visible = true
	if button_name == "ax_button"  && !%GraphRigidBody.visible:
		if map_visible:
			map_visible = false
			self.visible = map_visible
			%Tree.visible = false
			%Rock.visible = false
			%Bush.visible = false
		else:
			map_visible = true
			self.visible = map_visible
			%Tree.visible = true
			%Bush.visible = true
			%Rock.visible = true
			map_default_position()
	if !left_hold_map && button_name == "trigger_click" && map_visible:
		left_selecting = true
		set_corner(2, %LeftController.global_position)
		set_corner(1, %LeftController.global_position)
		$Map/SelectionBox.visible = true
		

func _on_left_button_released(button_name):
	if button_name == "trigger_click" && left_selecting && map_visible:
		left_selecting = false
		set_corner(2, %LeftController.global_position)	
		if corner1.distance_to(corner2) > 0.1:	
			%GraphRigidBody.visible = true
			%GraphRigidBody.graph_default_position()
			map_visible = false
			self.visible = map_visible
			%Tree.visible = false
			%Rock.visible = false
			%Bush.visible = false
		$Map/SelectionBox.visible = false
	if button_name == "grip_click" && hand_grabbed_user:
		hand_grabbed_user = false
		$Map/MiniUser.grabbed_left = false
		$Map/MiniUser.teleport()
	if button_name == "grip_click" && left_hand_grabbed_mini && mini_object != null:
		release_mini_object()
	if button_name == "grip_click" && left_hold_map:
		left_hold_map = false
		if translate_map:
			right_hold_map = false
			translate_map = false
		
func _on_right_button_pressed(button_name):
	if button_name == "grip_click":
		if map_visible:
			if %RightController/Area3D.overlaps_body($Map/MiniUser):
				$Map/MiniUser.grabbed_right = true
				$Map/MiniUser.grabbed_left = false
				hand_grabbed_user = true
				
			else:
				for mini in get_tree().get_nodes_in_group("mini"):
					if %RightController/Area3D.overlaps_body(mini):
						mini_object = mini
						right_hand_grabbed_mini = true
						mini.right_hand_grabbed = true
						break
				if mini_object == null && %RightController/Area3D.overlaps_body(self):
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
			%Tree.visible = false
			%Rock.visible = false
			%Bush.visible = false
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
		print(corner1.distance_to(corner2))
		if corner1.distance_to(corner2) > 0.1:
			%GraphRigidBody.visible = true
			%GraphRigidBody.graph_default_position()
			map_visible = false 
			self.visible = map_visible
			%Tree.visible = false
			%Rock.visible = false
			%Bush.visible = false
		$Map/SelectionBox.visible = false
	if button_name == "grip_click" && hand_grabbed_user:
		$Map/MiniUser.grabbed_right = false
		$Map/MiniUser.teleport()
		hand_grabbed_user = false
	if button_name == "grip_click" && right_hand_grabbed_mini && mini_object != null:
		release_mini_object()
	if button_name == "grip_click" && right_hold_map:
		right_hold_map = false
		if translate_map:
			left_hold_map = false
			translate_map = false
		
func release_mini_object():
	right_hand_grabbed_mini = false
	left_hand_grabbed_mini = false
	mini_object.right_hand_grabbed = false
	mini_object.left_hand_grabbed = false
	#if mini_object.copy != null:
		#mini_object.copy.queue_free()
	#mini_object.copy = null
	mini_object.released = true
	mini_object.freeze = false
	mini_object.linear_velocity = Vector3(0, -0.1, 0)
	mini_object.angular_velocity = Vector3.ZERO
	mini_object.in_map = false
	mini_object = null
	
func set_corner(corner, pos):
	var local_pos = $Map/SelectionBox.to_local(pos)
	var corner_pos = Vector2(local_pos.x, local_pos.z)
	if corner == 1:
		corner1 = corner_pos
		$Map/SelectionBox.mesh.material.set_shader_parameter("corner1", corner1)
	else:
		corner2 = corner_pos
		$Map/SelectionBox.mesh.material.set_shader_parameter("corner2", corner2)
			
func generate_terrain(amplitude, width, length, string_width, string_length):
	var adjusted_corner2 = Vector2(round((-corner2.x) * 1026), round((-corner2.y) * 1026))
	var adjusted_corner1 = Vector2(round((-corner1.x) * 1026), round((-corner1.y) * 1026))
	get_node("/root/Main")._edit(512 - clamp(max(adjusted_corner1.y, adjusted_corner2.y), 0, 512), 512 - clamp(min(adjusted_corner1.y, adjusted_corner2.y), 0, 512), 512 - clamp(max(adjusted_corner1.x, adjusted_corner2.x), 0, 512), 512 - clamp(min(adjusted_corner1.x, adjusted_corner2.x), 0, 512), amplitude, width, length, string_width, string_length)
	#reset all previously place objects according to the new height map!
	var large_objects = get_tree().get_nodes_in_group("large_objects")
	for object in large_objects:
		var globals = get_node("/root/Globals")
		var terrain_data = globals.terrian_info
		var new_coordinates = globals.global_to_hterrain(object.global_position.x, object.global_position.z)
		var big_height =  terrain_data.get_height_at(new_coordinates.x, new_coordinates.y)
		if big_height != 0:
			object.global_position.y = (big_height / 5.13)
		#elif big_height < 0:
			#object.global_position.y = (big_height / 5.13) - 0.2
		#else:
			object.global_position.y = 0
		object.find_child("equation").text = globals.get_equation(object.global_position.x, object.global_position.z)
		#print(object.find_child("equation").text)

func map_default_position():
	globals.position_relative_to_user(self)
	self.global_position.y += 0.5
	my_y = self.global_position.y
	my_scale_x = 1
	my_scale_z = 1
	my_rotation = Vector3(0,0,0)
	my_x = self.global_position.x
	my_z = self.global_position.z
	self.scale.x = my_scale_x
	self.scale.z = my_scale_z
	

	
