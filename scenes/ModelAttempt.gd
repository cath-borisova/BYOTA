extends MeshInstance3D

func _ready():
	var mesh = create_mesh()
	set_mesh(mesh)
	self.global_position.y = 0.5
	self.scale = Vector3(0.001, 0.001, 0.001)
	#var material = mesh.surface_get_material(0)
	var material = StandardMaterial3D.new()
	material.alpha_scissor_threshold = 0
	self.set_surface_override_material(0, material)
	

func create_mesh():
	var mesh = SurfaceTool.new()
	mesh.begin(Mesh.PRIMITIVE_POINTS)

	for x in range(-150, 150):
		for z in range(-150, 150):
			var y = 10 * sin(deg_to_rad(x)) * cos(deg_to_rad(z))  # Corrected deg_to_rad to deg2rad

			var vertex = Vector3(x, y, z)
			mesh.add_vertex(vertex)

	return mesh.commit()
