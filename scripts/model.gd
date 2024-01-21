extends MeshInstance3D
var globals = null
var amplitude = 13
var width = 1
var length = 1
var curr = 0

func _ready():
	globals = get_node("/root/Globals")
	create_mesh(13, PI, PI)

	self.scale = Vector3(0.0015, 0.0015, 0.0015)
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0,1,0, 0.5)
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
	material.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
	
	self.set_surface_override_material(0, material)

func create_mesh(amplitude, width, length):
	#print("width: ", width)
	#print("length: ", length)
	amplitude *= 5
	var model_mesh = SurfaceTool.new()
	model_mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
	var vertices = []
	for x in range(-149, 150): 
		for z in range(-149, 150):
			var y = amplitude * sin(deg_to_rad(x)*width) * cos(deg_to_rad(z) * length)
			var vertex = Vector3(x, y, z)
			vertices.append(vertex)
			model_mesh.add_vertex(vertex)

			y = amplitude * sin(deg_to_rad(x + 1) * width) * cos(deg_to_rad(z) * length)
			vertex = Vector3(x + 1, y, z)
			vertices.append(vertex)
			model_mesh.add_vertex(vertex)

			y = amplitude * sin(deg_to_rad(x) * width) * cos(deg_to_rad(z + 1) * length)
			vertex = Vector3(x, y, z + 1)
			vertices.append(vertex)
			model_mesh.add_vertex(vertex)

			y = amplitude * sin(deg_to_rad(x) * width) * cos(deg_to_rad(z + 1) * length)
			vertex = Vector3(x, y, z + 1)
			vertices.append(vertex)
			model_mesh.add_vertex(vertex)

			y = amplitude * sin(deg_to_rad(x + 1) * width) * cos(deg_to_rad(z) * length)
			vertex = Vector3(x + 1, y, z)
			vertices.append(vertex)
			model_mesh.add_vertex(vertex)

			y = amplitude * sin(deg_to_rad(x + 1) * width) * cos(deg_to_rad(z + 1) * length)
			vertex = Vector3(x + 1, y, z + 1)

			vertices.append(vertex)
			model_mesh.add_vertex(vertex)
	model_mesh.generate_normals()
	set_mesh(model_mesh.commit())

func _process(_delta):
	curr += _delta
	if curr >  2 && %GraphRigidBody.visible:
		if globals.y_axis_number[0] != amplitude || width != globals.x_axis_number_symbol[1] || length != globals.z_axis_number_symbol[1]:
			curr = 0
			amplitude = globals.y_axis_number[0]
			width = globals.x_axis_number_symbol[1]
			length = globals.z_axis_number_symbol[1] 
			create_mesh(amplitude, width * PI, length * PI)
