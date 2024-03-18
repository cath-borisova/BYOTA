extends Node3D

const HTerrain = preload("res://addons/zylann.hterrain/hterrain.gd")
const HTerrainData = preload("res://addons/zylann.hterrain/hterrain_data.gd")
#const HTerrainTextureSet = preload("res://addons/zylann.hterrain/hterrain_texture_set.gd")

var xr_interface: XRInterface

var terrain_data = null
var map_data = null
var model_data = null
var model_data2 = null

var terrain = null
var map_terrain = null

var mini_user = null

var selection_box = null

var arrowstem = null
var arrowhead = null
var compass

var globals = null
var user = null

var curr_object_displaying_equation = null

var terrain_heightmap: Image = null
var terrain_normalmap: Image = null
var terrain_colormap: Image = null

var map_heightmap: Image = null
var map_normalmap: Image = null
var map_colormap: Image = null


func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully!")

		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized. Please check if your headset is connected.")
	
	$XROrigin3D.rotation.y = deg_to_rad(90)
	
	terrain_data = HTerrainData.new()
	terrain_data.resize(513)
	
	terrain = HTerrain.new()
	terrain.set_data(terrain_data)
	globals = get_node("/root/Globals")
	globals.terrian_info = terrain_data
	
	terrain.position = Vector3(-50, 0,-50)
	terrain.map_scale = Vector3(0.2, 0.2, 0.2)
	terrain.name = "Ground"
	add_child(terrain)
	
	
	map_data = HTerrainData.new()
	map_data.resize(513)
	
	map_terrain = HTerrain.new()
	map_terrain.set_data(map_data)
	
	map_terrain.map_scale = Vector3(0.001, 0.001, 0.001)
	map_terrain.centered = true
	
	terrain_heightmap= terrain_data.get_image(HTerrainData.CHANNEL_HEIGHT)
	terrain_normalmap = terrain_data.get_image(HTerrainData.CHANNEL_NORMAL)
	terrain_colormap = terrain_data.get_image(HTerrainData.CHANNEL_COLOR)

	map_heightmap= map_data.get_image(HTerrainData.CHANNEL_HEIGHT)
	map_normalmap= map_data.get_image(HTerrainData.CHANNEL_NORMAL)
	map_colormap= map_data.get_image(HTerrainData.CHANNEL_COLOR)
	
	_edit(0, 513, 0, 513, 0, 0, 0, "0π", "0π")
	map_terrain.name = "Map"
	$MapRigidBody.add_child(map_terrain)
	
	$MapRigidBody/CollisionShape3D.position = map_terrain.position
	$MapRigidBody.visible = false
	map_terrain.position.x = -0.25
	
	
	arrowstem = %MiniUser/ArrowStem
	arrowhead =  %MiniUser/ArrowHead
	compass = %MiniUser/compass
	mini_user = %MiniUser
	mini_user.get_parent().remove_child(mini_user)
	$MapRigidBody/Map.add_child(mini_user)
	mini_user.rotation = Vector3(0,0,0)
	
	selection_box = $MapRigidBody/SelectionBox

	selection_box.visible = false
	selection_box.get_parent().remove_child(selection_box)
	$MapRigidBody/Map.add_child(selection_box)
	selection_box.position.y = 0.003
	selection_box.position.x = 0.26
	selection_box.position.z = 0.255
	
	%GraphRigidBody.visible = false
	%ExtraGraph.visible = false

	%GraphRigidBody/X_selector.position.x = 0.115
	%GraphRigidBody/Z_selector.position.z = -0.115
	%GraphRigidBody/Y_selector.position.y = 0.115
	
	user = %XROrigin3D
#y = a * sin(b * (x)) where b is 2pi/b

func _edit(z_start, z_end, x_start, x_end, amplitude, width, length, string_width, string_length):
	#var count = 0
	#var t = terrain
	#var color = Color(11.0/255.0, 82.0/255.0, 30/255.0, 1.0)
	#var data = terrain_data
	#print(z_start)
	#print(z_end)
	#print("\n")
	#print(x_start)
	#print(x_end)
	#print("\n")
	#while count < 2:
		#var heightmap: Image = data.get_image(HTerrainData.CHANNEL_HEIGHT)
		#var normalmap: Image = data.get_image(HTerrainData.CHANNEL_NORMAL)
		#var colormap: Image = data.get_image(HTerrainData.CHANNEL_COLOR)

	if z_start >= 0 && z_start < z_end && z_end <= map_heightmap.get_height() && x_start >= 0 && x_start < x_end && x_end <= map_heightmap.get_width():
		width *= PI
		length *= PI
		for z in range(z_start, z_end):
			
			
			for x in range(x_start, x_end):
			
				var y = amplitude * sin(width * deg_to_rad(x)) * cos(length * deg_to_rad(z))
				var dy_dx = amplitude * width * deg_to_rad(x) * cos(width * deg_to_rad(x)) * cos(length * deg_to_rad(z))
				var dy_dz = -amplitude * length * deg_to_rad(z) * sin(width * deg_to_rad(x)) * sin(length * deg_to_rad(z))
				#var y = amplitude * sin(width * deg_to_rad(temp_x)) * cos(length * deg_to_rad(temp_z));
				#var dy_dx = amplitude * width * deg_to_rad(temp_x) * cos(width * deg_to_rad(temp_x)) * cos(length * deg_to_rad(temp_z));
				#var dy_dz = -amplitude * length * deg_to_rad(temp_z) * sin(width * deg_to_rad(temp_x)) * sin(length * deg_to_rad(temp_z));
				var normal = Vector3(dy_dx, 1, dy_dz)

				terrain_heightmap.set_pixel(x, z, Color(y, 0, 0))
				terrain_normalmap.set_pixel(x, z, HTerrainData.encode_normal(normal))
				terrain_colormap.set_pixel(x, z,  Color(11.0/255.0, 82.0/255.0, 30/255.0, 1.0))

				map_heightmap.set_pixel(x, z, Color(y, 0, 0))
				map_normalmap.set_pixel(x, z, HTerrainData.encode_normal(normal))
				map_colormap.set_pixel(x, z,  Color(1,1, 1))

				globals.equations[x][z] = [amplitude, string_width, string_length]
		var map_modified_region = Rect2(Vector2(), map_heightmap.get_size())
		var terrain_modified_region = Rect2(Vector2(), terrain_heightmap.get_size())
		terrain_data.notify_region_change(terrain_modified_region, HTerrainData.CHANNEL_HEIGHT)
		terrain_data.notify_region_change(terrain_modified_region, HTerrainData.CHANNEL_NORMAL)
		terrain_data.notify_region_change(terrain_modified_region, HTerrainData.CHANNEL_COLOR)

		map_data.notify_region_change(map_modified_region, HTerrainData.CHANNEL_HEIGHT)
		map_data.notify_region_change(map_modified_region, HTerrainData.CHANNEL_NORMAL)
		map_data.notify_region_change(map_modified_region, HTerrainData.CHANNEL_COLOR)

		terrain.update_collider()
		map_terrain.update_collider()
		globals.terrian_info = terrain_data
			#var offset = 0
			#var compare = 0
			#var l_scale = 90/PI
			#var w_scale = 45/PI
			
			#if length != 0:
				#offset = x_start / l_scale
				#compare = floor(offset) + 0.75
				#if offset > compare:
					#x_start = round(floor(offset) * l_scale)
				#else:
					#x_start = round(ceil(offset) * l_scale)
				#
				#offset = x_end/l_scale
				#compare = floor(offset) + 0.75
				#if offset > compare:
					#x_end = round(ceil(offset) * l_scale)
				#else:
					#x_end = round(floor(offset) * l_scale)
			#if width != 0:
				#offset = z_start / w_scale
				#compare = floor(offset) + 0.75
				#if offset > compare:
					#z_start = round(floor(offset) * w_scale)
				#else:
					#z_start = round(ceil(offset) * w_scale)
				#
				#offset = z_end/w_scale
				#compare = floor(offset) + 0.75
				#if offset > compare:
					#z_end = round(ceil(offset) * w_scale)
				#else:
					#z_end = round(floor(offset) * w_scale)
			#width *= PI
			#length *= PI
			#for z in range(z_start, z_end):
				#for x in range(x_start, x_end):
					#var y = amplitude * sin(width * deg_to_rad(x)) * cos(length * deg_to_rad(z));
					#var dy_dx = amplitude * width * deg_to_rad(x) * cos(width * deg_to_rad(x)) * cos(length * deg_to_rad(z));
					#var dy_dz = -amplitude * length * deg_to_rad(z) * sin(width * deg_to_rad(x)) * sin(length * deg_to_rad(z));
					#var normal = Vector3(dy_dx, 1, dy_dz)
					#heightmap.set_pixel(x, z, Color(y, 0, 0))
					#normalmap.set_pixel(x, z, HTerrainData.encode_normal(normal))
					#colormap.set_pixel(x, z, color)
					#globals.equations[x][z] = [amplitude, string_width, string_length]
			#var modified_region = Rect2(Vector2(), heightmap.get_size())
			#data.notify_region_change(modified_region, HTerrainData.CHANNEL_HEIGHT)
			#data.notify_region_change(modified_region, HTerrainData.CHANNEL_NORMAL)
			#data.notify_region_change(modified_region, HTerrainData.CHANNEL_COLOR)
			#t.update_collider()
		#count += 1
		#globals.terrian_info = terrain_data
		#t.set_data(data)
		#t = map_terrain
		#color = Color(1,1, 1)
		#data = map_data
		#t.set_data(data)

func _process(_delta):
	var user_pos = %XROrigin3D.global_position
	var height = terrain_data.get_height_at((user_pos.x+50)*5.13,(user_pos.z+50)*5.13)
	mini_user.position = Vector3((user_pos.x + 50)/200, 0, (user_pos.z + 50)/200)
	mini_user.position = Vector3((user_pos.x)/200, 0, (user_pos.z)/200)
	mini_user.rotation.x = 0
	mini_user.rotation.z = 0
	if height != 0:
		%XROrigin3D.global_position.y = (height / 5.13) + 1.0
		mini_user.position.y = (%XROrigin3D.global_position.y - 1.0) / 200
	else:
		%XROrigin3D.global_position.y = 1.0
	
	
	
	var large_objects = get_tree().get_nodes_in_group("large_objects")
	if large_objects.size() > 0:
		var closest_object = large_objects[0]
		for object in large_objects:
			if user.global_position.distance_to(object.global_position) <= user.global_position.distance_to(closest_object.global_position):
				closest_object = object
				#closest_object.find_child("equation").visible = true
			elif curr_object_displaying_equation != null && object == curr_object_displaying_equation:
				object.find_child("equation").visible = false
		if user.global_position.distance_to(closest_object.global_position) < 10:
			curr_object_displaying_equation = closest_object
			closest_object.find_child("equation").visible = true
		else:
			curr_object_displaying_equation = null


func _on_left_controller_button_released(name):
	pass # Replace with function body.
