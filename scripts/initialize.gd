extends Node3D

const HTerrain = preload("res://addons/zylann.hterrain/hterrain.gd")
const HTerrainData = preload("res://addons/zylann.hterrain/hterrain_data.gd")
#const HTerrainTextureSet = preload("res://addons/zylann.hterrain/hterrain_texture_set.gd")

var terrain_data = null
var map_data = null
var xr_interface: XRInterface
var terrain = null
var map_terrain = null
var is_sin = false
var mini_user = null
var selection_box = null

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
	terrain.position = Vector3(-50, 0,-50)
	terrain.map_scale = Vector3(0.2, 0.2, 0.2)
	terrain.name = "Ground"
	add_child(terrain)
	map_data = HTerrainData.new()
	map_data.resize(513)

	map_terrain = HTerrain.new()
	map_terrain.set_data(map_data)
	map_terrain.map_scale = Vector3(0.001, 0.001, 0.001)
	_edit(0, 513, 0, 513, 0, 0, 0)
	map_terrain.name = "Map"
	$MapRigidBody.add_child(map_terrain)
	$MapRigidBody.visible = false
	map_terrain.position.x = -0.25
	mini_user = %MiniUser
	mini_user.get_parent().remove_child(mini_user)
	$MapRigidBody/Map.add_child(mini_user)
	selection_box = $MapRigidBody/SelectionBox
	
	selection_box.visible = false
	selection_box.get_parent().remove_child(selection_box)
	$MapRigidBody/Map.add_child(selection_box)
	selection_box.position.y = 0.003
	selection_box.position.x = 0.26
	selection_box.position.z = 0.255

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
			var modified_region = Rect2(Vector2(), heightmap.get_size())
			data.notify_region_change(modified_region, HTerrainData.CHANNEL_HEIGHT)
			data.notify_region_change(modified_region, HTerrainData.CHANNEL_NORMAL)
			data.notify_region_change(modified_region, HTerrainData.CHANNEL_COLOR)
			t.update_collider()
		count += 1
		t = map_terrain
		color = Color(1,1, 1)
		data = map_data
		
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
