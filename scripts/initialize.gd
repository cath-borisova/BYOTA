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
var xr_interface: XRInterface
var terrain = null
var is_sin = true

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

	# Create texture set
	# NOTE: usually this is not made from script, it can be built with editor tools
#	var texture_set = HTerrainTextureSet.new()
#	texture_set.set_mode(HTerrainTextureSet.MODE_TEXTURES)
#	texture_set.insert_slot(-1)
#	texture_set.set_texture(0, HTerrainTextureSet.TYPE_ALBEDO_BUMP, grass_texture)
#	texture_set.insert_slot(-1)
#	texture_set.set_texture(1, HTerrainTextureSet.TYPE_ALBEDO_BUMP, sand_texture)
#	texture_set.insert_slot(-1)
#	texture_set.set_texture(2, HTerrainTextureSet.TYPE_ALBEDO_BUMP, leaves_texture)

	# Create terrain node
	terrain = HTerrain.new()
	terrain.set_shader_type(HTerrain.SHADER_CLASSIC4_LITE)
	terrain.set_data(terrain_data)
#	terrain.set_texture_set(texture_set)
	terrain.position = Vector3(-200, -20, -200)
	add_child(terrain)

	# No need to call this, but you may need to if you edit the terrain later on
	#terrain.update_collider()

func _on_button_pressed(name):
	if (name == 'trigger_click'):
		if (is_sin):
			var noise = FastNoiseLite.new()
			var noise_multiplier = 50.0
			# Get access to terrain maps
			var heightmap: Image = terrain_data.get_image(HTerrainData.CHANNEL_HEIGHT)
			var normalmap: Image = terrain_data.get_image(HTerrainData.CHANNEL_NORMAL)
			var splatmap: Image = terrain_data.get_image(HTerrainData.CHANNEL_SPLAT)
			var colormap: Image = terrain_data.get_image(HTerrainData.CHANNEL_COLOR)

			# Generate terrain maps
			# Note: this is an example with some arbitrary formulas,
			# you may want to come up with your owns
			for z in heightmap.get_height():
				for x in heightmap.get_width():
					# Generate height
					var h = noise_multiplier * noise.get_noise_2d(x, z)

					# Getting normal by generating extra heights directly from noise,
					# so map borders won't have seams in case you stitch them
					var h_right = noise_multiplier * noise.get_noise_2d(x + 0.1, z)
					var h_forward = noise_multiplier * noise.get_noise_2d(x, z + 0.1)
					var normal = Vector3(h - h_right, 0.1, h_forward - h).normalized()

					heightmap.set_pixel(x, z, Color(h, 0, 0))
					normalmap.set_pixel(x, z, HTerrainData.encode_normal(normal))
					colormap.set_pixel(x, z, Color(0, 1, 0))

			# Commit modifications so they get uploaded to the graphics card
			var modified_region = Rect2(Vector2(), heightmap.get_size())
			terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_HEIGHT)
			terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_NORMAL)
			terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_COLOR)
			print("d")

