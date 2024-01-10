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
var model = null

var model_heightmap = null
var model_normalmap = null
var model_colormap = null

var model2 = null

var model_heightmap2 = null
var model_normalmap2 = null
var model_colormap2 = null

var mini_user = null

var selection_box = null

var arrowstem = null
var arrowhead = null

# Called when the node enters the scene tree for the first time.
func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully!")

		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Change our main viewport to output to the HMD
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized. Please check if your headset is connected.")
		
	$XROrigin3D.rotate_y(deg_to_rad(90))
	terrain_data = HTerrainData.new()
	terrain_data.resize(513)
	
	terrain = HTerrain.new()
	terrain.set_data(terrain_data)
	var globals = get_node("/root/Globals")
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
	_edit(0, 513, 0, 513, 0, 0, 0)
	map_terrain.name = "Map"
	$MapRigidBody.add_child(map_terrain)
	$MapRigidBody/CollisionShape3D.position = map_terrain.position
	$MapRigidBody.visible = false
	map_terrain.position.x = -0.25
	
	arrowstem = %MiniUser/ArrowStem
	arrowhead =  %MiniUser/ArrowHead
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
	
	model_data = HTerrainData.new()
	model_data.resize(513)
	model = HTerrain.new()
	model.set_data(model_data)
	model.map_scale = Vector3(0.001, 0.001, 0.001)
	model.name = "Model"
	map_terrain.centered = true
	model_heightmap = model_data.get_image(HTerrainData.CHANNEL_HEIGHT)
	model_normalmap = model_data.get_image(HTerrainData.CHANNEL_NORMAL)
	model_colormap = model_data.get_image(HTerrainData.CHANNEL_COLOR)
	add_child(model)
	model.global_position.y = 1
	
	model_data2 = HTerrainData.new()
	model_data2.resize(513)
	model2 = HTerrain.new()
	model2.set_data(model_data)
	model2.map_scale = Vector3(0.001, 0.001, 0.001)
	model2.name = "Model2"
	map_terrain.centered = true
	model_heightmap2 = model_data2.get_image(HTerrainData.CHANNEL_HEIGHT)
	model_normalmap2 = model_data2.get_image(HTerrainData.CHANNEL_NORMAL)
	model_colormap2 = model_data2.get_image(HTerrainData.CHANNEL_COLOR)
	_create_model()
	add_child(model2)
	model2.global_position.y = 1
	#model2.rotation.x = deg_to_rad(180)
	#model2.rotation.y = deg_to_rad(180)
	#model2.rotation.z = deg_to_rad(180)
#y = a * sin(b * (x)) where b is 2pi/b

func _edit(z_start, z_end, x_start, x_end, amplitude, width, length):
	var count = 0
	var t = terrain
	var color = Color(11.0/255.0, 82.0/255.0, 30/255.0, 1.0)
	var data = terrain_data
	while count < 2:
		var heightmap: Image = data.get_image(HTerrainData.CHANNEL_HEIGHT)
		var normalmap: Image = data.get_image(HTerrainData.CHANNEL_NORMAL)
		var colormap: Image = data.get_image(HTerrainData.CHANNEL_COLOR)

		if z_start >= 0 && z_start < z_end && z_end <= heightmap.get_height() && x_start >= 0 && x_start < x_end && x_end <= heightmap.get_width():
			var offset = 0
			var compare = 0
			var l_scale = 90/PI
			var w_scale = 45/PI
			
			if length != 0:
				offset = x_start / l_scale
				compare = floor(offset) + 0.75
				if offset > compare:
					x_start = round(floor(offset) * l_scale)
				else:
					x_start = round(ceil(offset) * l_scale)
				
				offset = x_end/l_scale
				compare = floor(offset) + 0.75
				if offset > compare:
					x_end = round(ceil(offset) * l_scale)
				else:
					x_end = round(floor(offset) * l_scale)
			if width != 0:
				offset = z_start / w_scale
				compare = floor(offset) + 0.75
				if offset > compare:
					z_start = round(floor(offset) * w_scale)
				else:
					z_start = round(ceil(offset) * w_scale)
				
				offset = z_end/w_scale
				compare = floor(offset) + 0.75
				if offset > compare:
					z_end = round(ceil(offset) * w_scale)
				else:
					z_end = round(floor(offset) * w_scale)
			width *= PI
			length *= PI
			for z in range(z_start, z_end):
				for x in range(x_start, x_end):
					var y = amplitude * sin(length * x * (PI/90)) * cos(width * z * (PI/90));
					var dy_dx = amplitude * length * cos(length * x * (PI/90)) * cos(width * z * (PI/90));
					var dy_dz = -amplitude * sin(length *x * (PI/90)) * sin(width * z * (PI/90));
					var normal = Vector3(dy_dx, 1, dy_dz)
					heightmap.set_pixel(x, z, Color(y, 0, 0))
					normalmap.set_pixel(x, z, HTerrainData.encode_normal(normal))
					colormap.set_pixel(x, z, color)
					#print("HERE ", data.get_height_at(x,z), " X: ", x, " Z: ", z)
			var modified_region = Rect2(Vector2(), heightmap.get_size())
			data.notify_region_change(modified_region, HTerrainData.CHANNEL_HEIGHT)
			data.notify_region_change(modified_region, HTerrainData.CHANNEL_NORMAL)
			data.notify_region_change(modified_region, HTerrainData.CHANNEL_COLOR)
			t.update_collider()
		count += 1
		var globals = get_node("/root/Globals")
		globals.terrian_info = terrain_data
		#reset the data again now that it is changed
		t.set_data(data)
		t = map_terrain
		color = Color(1,1, 1)
		data = map_data
		#reset data again now that it is changed
		t.set_data(data)

var model_amplitude = 513/2
var model_length = 0.005
var model_width = model_length

var extra = PI

func _create_model():
	for z in range(0, 513):
		for x in range(0, 513):
			var y = model_amplitude * sin(model_length * x * extra) * cos(model_width * z * extra);
			var dy_dx = model_amplitude * model_length * cos(model_length * x * extra) * cos(model_width * z * extra);
			var dy_dz = -model_amplitude * sin(model_length *x * extra) * sin(model_width * z * extra);
			
			var normal = Vector3(dy_dx, 1, dy_dz)
			model_heightmap.set_pixel(x, z, Color(y, 0, 0))
			model_normalmap.set_pixel(x, z, HTerrainData.encode_normal(normal))
			model_colormap.set_pixel(x, z, Color.DARK_RED)
			
			var x2 = 512 - x
			var z2 = 512 -z 
			var y2 = model_amplitude * sin(model_length * x2 * extra) * cos(model_width * z2 * extra);
			var dy_dx2 = model_amplitude * model_length * cos(model_length * x2 * extra) * cos(model_width * z2 * extra);
			var dy_dz2 = -model_amplitude * sin(model_length *x2 * extra) * sin(model_width * z2 * extra);
			
			
			var normal2 = Vector3(-dy_dz2, -1, -dy_dx2)
			model_heightmap2.set_pixel(512-x, 512 - z, Color(-y, 0, 0))
			model_normalmap2.set_pixel(512-x, 512 -z, HTerrainData.encode_normal(normal2))
			model_colormap2.set_pixel(512-x, 512 - z, Color.DARK_RED)
			
	var modified_region = Rect2(Vector2(), model_heightmap.get_size())
	model_data.notify_region_change(modified_region, HTerrainData.CHANNEL_HEIGHT)
	model_data.notify_region_change(modified_region, HTerrainData.CHANNEL_NORMAL)
	model_data.notify_region_change(modified_region, HTerrainData.CHANNEL_COLOR)
	model.update_collider()
	
	model_data2.notify_region_change(modified_region, HTerrainData.CHANNEL_HEIGHT)
	model_data2.notify_region_change(modified_region, HTerrainData.CHANNEL_NORMAL)
	model_data2.notify_region_change(modified_region, HTerrainData.CHANNEL_COLOR)
	model2.update_collider()

func _process(_delta):
	var user_pos = %XROrigin3D.global_position
	var height = terrain_data.get_height_at((user_pos.x+50)*5.13,(user_pos.z+50)*5.13)
	#var terrain_scale = terrain.global_transform.basis.get_scale()
	#var meters_per_unit = Vector3(1/terrain_scale.x, 1/terrain_scale.y, 1/terrain_scale.z) 
	#var height_scaled = height * meters_per_unit
	#print("HEIGHT: ", height_scaled)
	if height != 0:
		%XROrigin3D.global_position.y = height / 5.13 + 0.5
	else:
		%XROrigin3D.global_position.y = 0.5
	#print("HEIGHT: ", height)
	
	mini_user.position = Vector3((user_pos.x + 50)/200, 0, (user_pos.z + 50)/200)
	mini_user.position = Vector3((user_pos.x)/200, 0, (user_pos.z)/200)
	mini_user.rotation.x = 0
	mini_user.rotation.z = 0
