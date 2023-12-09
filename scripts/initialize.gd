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
var is_sin = true
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
	add_child(terrain)
	
	map_data = HTerrainData.new()
	map_data.resize(513)

	# Create terrain node
	map_terrain = HTerrain.new()
	map_terrain.set_shader_type(HTerrain.SHADER_CLASSIC4_LITE)
	map_terrain.set_data(map_data)
	map_terrain.map_scale = Vector3(0.01, 0.01, 0.01)
	map_terrain.rotation.x = deg_to_rad(90)
	map_terrain.visible = false
#	terrain.set_texture_set(texture_set)
	add_child(map_terrain)

	# No need to call this, but you may need to if you edit the terrain later on
	#terrain.update_collider()
var amplitude = 3
#y = a * sin(b * (x)) where b is 2pi/b
var frequency_interval = 4 #aka b
var curr_frequency = 0

func _edit(t, data):
	if (is_sin):
			var heightmap: Image = data.get_image(HTerrainData.CHANNEL_HEIGHT)
			var normalmap: Image = data.get_image(HTerrainData.CHANNEL_NORMAL)
			var splatmap: Image = data.get_image(HTerrainData.CHANNEL_SPLAT)
			var colormap: Image = data.get_image(HTerrainData.CHANNEL_COLOR)
			var z_start = 10
			var z_end = z_start + (amplitude * 3)
			for z in range(z_start, z_end):
				for x in heightmap.get_width():
					var h = amplitude * sin(frequency_interval * x)
					var normal = Vector3(h, 0.1, h).normalized()
					heightmap.set_pixel(x, z, Color(h, 0, 0))
					normalmap.set_pixel(x, z, HTerrainData.encode_normal(normal))
					colormap.set_pixel(x, z, Color(0, 1, 0))
			var modified_region = Rect2(Vector2(), heightmap.get_size())
			data.notify_region_change(modified_region, HTerrainData.CHANNEL_HEIGHT)
			data.notify_region_change(modified_region, HTerrainData.CHANNEL_NORMAL)
			data.notify_region_change(modified_region, HTerrainData.CHANNEL_COLOR)
			print("d")
			
func _on_button_pressed(name):
	print(name)
	if (name == 'trigger_click'):
		_edit(terrain, terrain_data)
		_edit(map_terrain, map_data)
	if (name == 'ax_button'):
		print(map_visible)
		map_visible = !map_visible
		map_terrain.visible = map_visible
		
func _process(delta):
	#print("here")
	if map_visible:
		map_terrain.position = Vector3(-2.5,3, 0) + $XROrigin3D.position - (sign($XROrigin3D/XRCamera3D.position.y) * Vector3(0, 0 ,4.5))
