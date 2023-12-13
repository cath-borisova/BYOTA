extends Node3D

const HTerrain = preload("res://addons/zylann.hterrain/hterrain.gd")
const HTerrainData = preload("res://addons/zylann.hterrain/hterrain_data.gd")
const HTerrainTextureSet = preload("res://addons/zylann.hterrain/hterrain_texture_set.gd")

# You may want to change paths to your own textures
#var grass_texture = load("res://addons/zylann.hterrain_demo/textures/ground/grass_albedo_bump.png")
#var sand_texture = load("res://addons/zylann.hterrain_demo/textures/ground/sand_albedo_bump.png")
#var leaves_texture = load("res://addons/zylann.hterrain_demo/textures/ground/leaves_albedo_bump.png")
#@onready var _terrain = %Terrain
var terrain_data = null
var map_data = null
var xr_interface: XRInterface
var terrain = null
var map_terrain = null
var is_sin = false
var map_visible = false

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
		
	terrain_data = HTerrainData.new()
	terrain_data.resize(513)

	# Create terrain node
	terrain = HTerrain.new()
	terrain.set_shader_type(HTerrain.SHADER_CLASSIC4_LITE)
	terrain.set_data(terrain_data)
#	terrain.set_texture_set(texture_set)
	terrain.position = Vector3(-50, 0,-50)
	terrain.map_scale = Vector3(0.1, 0.1, 0.1)
	_edit(1, terrain_data, 0, -1, 0)
	add_child(terrain)
	
	map_data = HTerrainData.new()
	map_data.resize(513)

	# Create terrain node
	map_terrain = HTerrain.new()
	map_terrain.set_shader_type(HTerrain.SHADER_CLASSIC4_LITE)
	map_terrain.set_data(map_data)
	map_terrain.map_scale = Vector3(0.001, 0.001, 0.001)
	#map_terrain.rotation.x = deg_to_rad(90)
	map_terrain.visible = false
	_edit(0, map_data, 0, -1, 0)
	var map_collision = CollisionShape3D.new()
	map_collision.name = "Collision"
	map_terrain.add_child(map_collision)
	map_terrain.name = "Map"
#	terrain.set_texture_set(texture_set)
	#%MapContainer.add_child(map_terrain)
	add_child(map_terrain)

	# No need to call this, but you may need to if you edit the terrain later on
	#terrain.update_collider()
#y = a * sin(b * (x)) where b is 2pi/b
var frequency_interval = 4 #aka b
var curr_frequency = 0

func _edit(node, data, z_start, z_end, amplitude):
	var heightmap: Image = data.get_image(HTerrainData.CHANNEL_HEIGHT)
	var normalmap: Image = data.get_image(HTerrainData.CHANNEL_NORMAL)
	var splatmap: Image = data.get_image(HTerrainData.CHANNEL_SPLAT)
	var colormap: Image = data.get_image(HTerrainData.CHANNEL_COLOR)
	var t = null
	var color = null
	if node == 1:
		t = terrain
		if z_end == -1:
			color = Color(0.2, 0.7, 0.6)
		else:
			color = Color(0, 0, 1)
	else:
		t = map_terrain
		color = Color(1, 1, 1)
	
	if z_end == -1:
		z_end = heightmap.get_height()
	print("height: ", heightmap.get_height())
	print("width: ", heightmap.get_width())
	for z in range(z_start, z_end):
		for x in heightmap.get_width():
			var y = amplitude * sin(frequency_interval * deg_to_rad(x)) * cos(frequency_interval * deg_to_rad(z));
			var dy_dx = amplitude * frequency_interval * cos(frequency_interval * deg_to_rad(x)) * cos(frequency_interval * deg_to_rad(z));
			var dy_dz = -amplitude * sin(frequency_interval * deg_to_rad(x)) * sin(frequency_interval * deg_to_rad(z));

			#var normal = Vector3(amplitude * cos(deg_to_rad(frequency_interval * x)), -1, 0).normalized()
			var normal = Vector3(dy_dx, 1, dy_dz)
			heightmap.set_pixel(x, z, Color(y, 0, 0))
			normalmap.set_pixel(x, z, HTerrainData.encode_normal(normal))
			colormap.set_pixel(x, z, color)
	var modified_region = Rect2(Vector2(), heightmap.get_size())
	data.notify_region_change(modified_region, HTerrainData.CHANNEL_HEIGHT)
	data.notify_region_change(modified_region, HTerrainData.CHANNEL_NORMAL)
	data.notify_region_change(modified_region, HTerrainData.CHANNEL_COLOR)
	print('done')
			
func _on_button_pressed(name):
	#print(name)
	if (name == 'trigger_click'):
		_edit(1, terrain_data, 50, 300, 20)
		_edit(0, map_data, 50, 300, 20)
	if (name == 'ax_button'):
		print(map_visible)
		map_visible = !map_visible
		map_terrain.visible = map_visible
		
func _process(delta):
	#print("here")
	if map_visible:
		var camera_pos = $XROrigin3D/XRCamera3D.global_position
#		if camera_pos.x < 0:
#			camera_pos.x -= 1
#		else:
#			camera_pos.x += 1
#		if camera_pos.z < 0:
#			camera_pos.z -= 1
#		else:
#			camera_pos.z += 1
#		camera_pos.x += 1
#		camera_pos.z += 1
		var new_position = camera_pos + -($XROrigin3D/XRCamera3D.global_transform).basis.z.normalized() * 0.3
		new_position.y = 0.3
		map_terrain.global_transform.origin = new_position
		var projected_camera_pos = camera_pos
		projected_camera_pos.y = 0.3
		map_terrain.look_at(projected_camera_pos, Vector3(0, 1, 0))
		#map_terrain.position.z += (-1 * map_terrain.position.x/map_terrain.position.x) * 3
		#map_terrain.rotation.x = deg_to_rad(0)
	
func _on_button_released(name):
	pass # Replace with function body.
