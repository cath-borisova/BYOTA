extends MeshInstance3D

func _ready():
	set_mesh(create_mesh())

	self.scale = Vector3(0.0015, 0.0015, 0.0015)
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0,1,0, 0.5)
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
	material.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
	
	self.set_surface_override_material(0, material)

func create_mesh():
	var model_mesh = SurfaceTool.new()
	model_mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
	var vertices = []
	for x in range(-149, 150): 
		for z in range(-149, 150):
			var y = 100 * sin((x) * PI/135) * cos((z) * PI/135)
			var vertex = Vector3(x, y, z)
			vertices.append(vertex)
			model_mesh.add_vertex(vertex)

			y = 100 * sin((x + 1) * PI/135) * cos((z) * PI/135)
			vertex = Vector3(x + 1, y, z)
			vertices.append(vertex)
			model_mesh.add_vertex(vertex)

			y = 100 * sin((x) * PI/135) * cos((z + 1) * PI/135)
			vertex = Vector3(x, y, z + 1)
			vertices.append(vertex)
			model_mesh.add_vertex(vertex)

			y = 100 * sin((x) * PI/135) * cos((z + 1) * PI/135)
			vertex = Vector3(x, y, z + 1)
			vertices.append(vertex)
			model_mesh.add_vertex(vertex)

			y = 100 * sin((x + 1) * PI/135) * cos((z) * PI/135)
			vertex = Vector3(x + 1, y, z)
			vertices.append(vertex)
			model_mesh.add_vertex(vertex)

			y = 100 * sin((x + 1) * PI/135) * cos((z + 1) * PI/135)
			vertex = Vector3(x + 1, y, z + 1)
			vertices.append(vertex)
			model_mesh.add_vertex(vertex)
	model_mesh.generate_normals()
	return model_mesh.commit()
