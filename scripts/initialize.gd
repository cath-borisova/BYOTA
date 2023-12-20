extends Node3D

const HTerrain = preload("res://addons/zylann.hterrain/hterrain.gd")
const HTerrainData = preload("res://addons/zylann.hterrain/hterrain_data.gd")
const HTerrainTextureSet = preload("res://addons/zylann.hterrain/hterrain_texture_set.gd")

var terrain_data = null
var map_data = null
var xr_interface: XRInterface
var terrain = null
var map_terrain = null
var is_sin = false
var map_visible = false
var mini_user = null

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
	terrain.set_shader_type(HTerrain.SHADER_CLASSIC4_LITE)
	terrain.set_data(terrain_data)
	terrain.position = Vector3(-50, 0,-50)
	terrain.map_scale = Vector3(0.2, 0.2, 0.2)
	terrain.name = "Ground"
	_edit(1, terrain_data, 0, -1, 0)
	add_child(terrain)
	
	map_data = HTerrainData.new()
	map_data.resize(513)

	map_terrain = HTerrain.new()
	map_terrain.set_shader_type(HTerrain.SHADER_CLASSIC4_LITE)
	map_terrain.set_data(map_data)
	map_terrain.map_scale = Vector3(0.001, 0.001, 0.001)
	_edit(0, map_data, 0, -1, 0)
	map_terrain.name = "Map"
	$MapRigidBody.add_child(map_terrain)
	$MapRigidBody.visible = false
	map_terrain.position.x = -0.25
	mini_user = %MiniUser
	mini_user.get_parent().remove_child(mini_user)
	$MapRigidBody/Map.add_child(mini_user)
	
	$Tree.visible = map_visible
	$Bush.visible = map_visible
	$Rock.visible = map_visible

#y = a * sin(b * (x)) where b is 2pi/b
var frequency_interval = 4 #aka b

func _edit(node, data, z_start, z_end, amplitude):
	var heightmap: Image = data.get_image(HTerrainData.CHANNEL_HEIGHT)
	var normalmap: Image = data.get_image(HTerrainData.CHANNEL_NORMAL)
	var colormap: Image = data.get_image(HTerrainData.CHANNEL_COLOR)
	var t = null
	var color = null
	if node == 1:
		t = terrain
		if z_end == -1:
			color = Color(11.0/255.0, 82.0/255.0, 30/255.0, 1.0)
		else:
			color = Color(0, 0, 1)
	else:
		t = map_terrain
		color = Color(1, 1, 1)
	
	if z_end == -1:
		z_end = heightmap.get_height()

	for z in range(z_start, z_end):
		for x in heightmap.get_width():
			var y = amplitude * sin(frequency_interval * deg_to_rad(x)) * cos(frequency_interval * deg_to_rad(z));
			var dy_dx = amplitude * frequency_interval * cos(frequency_interval * deg_to_rad(x)) * cos(frequency_interval * deg_to_rad(z));
			var dy_dz = -amplitude * sin(frequency_interval * deg_to_rad(x)) * sin(frequency_interval * deg_to_rad(z));

			var normal = Vector3(dy_dx, 1, dy_dz)

			heightmap.set_pixel(x, z, Color(y, 0, 0))
			normalmap.set_pixel(x, z, HTerrainData.encode_normal(normal))
			colormap.set_pixel(x, z, color)
	var modified_region = Rect2(Vector2(), heightmap.get_size())
	data.notify_region_change(modified_region, HTerrainData.CHANNEL_HEIGHT)
	data.notify_region_change(modified_region, HTerrainData.CHANNEL_NORMAL)
	data.notify_region_change(modified_region, HTerrainData.CHANNEL_COLOR)
	t.update_collider()
			
func _on_button_pressed(button_name):
	if (button_name == 'trigger_click'):
		_edit(1, terrain_data, 50, 300, 20)
		_edit(0, map_data, 50, 300, 20)
	if (button_name == 'ax_button'):
		map_visible = !map_visible
		$MapRigidBody.visible = map_visible
		$Tree.visible = map_visible
		$Bush.visible = map_visible
		$Rock.visible = map_visible
		
func _process(_delta):
	if map_visible:
		var new_position = $XROrigin3D/XRCamera3D.global_position + -($XROrigin3D/XRCamera3D.global_transform).basis.z.normalized() * 0.05
		new_position.y = 0.9
		$MapRigidBody.global_transform.origin = new_position
		var projected_camera_pos = $XROrigin3D/XRCamera3D.global_position
		projected_camera_pos.y = 0.9
		$MapRigidBody.look_at(projected_camera_pos, Vector3(0, 1, 0))
		var user_pos = %XROrigin3D.global_position
		mini_user.position = Vector3((user_pos.x + 50)/200, 0, (user_pos.z + 50)/200)
