extends Node3D

const HTerrainData = preload("res://addons/zylann.hterrain/hterrain_data.gd")
@onready var _terrain = %Terrain
var xr_interface: XRInterface


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

func _on_button_pressed(name):
	if (name == 'trigger_click'):
		# Get the image
		var data : HTerrainData = _terrain.get_data()
		print(data);
		print(data._maps)
		print(data._maps[HTerrainData.CHANNEL_COLOR][0].image)
		var colormap : Image = data.get_image(HTerrainData.CHANNEL_COLOR)
		print(colormap)

	# Modify the image
		#var position = Vector2(42, 36)
		for x in range(30, 230):
			for y in range(30, 230):
				#colormap.set_pixel(x, y, Color(1, 0, 0))
				pass
	# Notify the terrain of our change
		#data.notify_region_changed(Rect2(position.x, position.y, 1, 1), HTerrainData.CHANNEL_COLOR)
