extends MeshInstance3D

func _ready():
	var mesh = create_mesh()
	set_mesh(mesh)

	self.scale = Vector3(0.0015, 0.0015, 0.0015)
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.RED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	#var shader_material = ShaderMaterial.new()
	#var shader_code = load("res://scripts/model.gdshader")  # Replace with the actual path to your shader file
	#if shader_code != null:
		#shader_material.shader = shader_code
		## Assign the ShaderMaterial to your MeshInstance
		#self.material_override = shader_material
	self.set_surface_override_material(0, material)

func create_mesh():
	var mesh = SurfaceTool.new()
	mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
	var vertices = []
	for x in range(-149, 150):  # Adjust loop indices
		for z in range(-149, 150):  # Adjust loop indices
			# First Triangle
			var y = 100 * sin((x) * PI/135) * cos((z) * PI/135)
			var vertex = Vector3(x, y, z)
			vertices.append(vertex)
			mesh.add_vertex(vertex)

			y = 100 * sin((x + 1) * PI/135) * cos((z) * PI/135)
			vertex = Vector3(x + 1, y, z)
			vertices.append(vertex)
			mesh.add_vertex(vertex)

			y = 100 * sin((x) * PI/135) * cos((z + 1) * PI/135)
			vertex = Vector3(x, y, z + 1)
			vertices.append(vertex)
			mesh.add_vertex(vertex)

			# Second Triangle
			y = 100 * sin((x) * PI/135) * cos((z + 1) * PI/135)
			vertex = Vector3(x, y, z + 1)
			vertices.append(vertex)
			mesh.add_vertex(vertex)

			y = 100 * sin((x + 1) * PI/135) * cos((z) * PI/135)
			vertex = Vector3(x + 1, y, z)
			vertices.append(vertex)
			mesh.add_vertex(vertex)

			y = 100 * sin((x + 1) * PI/135) * cos((z + 1) * PI/135)
			vertex = Vector3(x + 1, y, z + 1)
			vertices.append(vertex)
			mesh.add_vertex(vertex)
	mesh.generate_normals()
	#mesh.generate_tangents()

	return mesh.commit()
