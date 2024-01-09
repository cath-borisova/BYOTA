extends MeshInstance3D

# Define the parameters
var a : float = 1.0  # amplitude
var l : float = 1.0  # wavelength along x-axis
var w : float = 1.0  # wavelength along z-axis

# Number of points on the mesh
var num_points_x : int = 100
var num_points_z : int = 100

func _ready():
	# Create a mesh
	var mesh = ArrayMesh.new()

	# Create an array to hold the vertices
	var vertices = PackedVector3Array()

	# Generate points for x and z
	for i in range(num_points_x):
		for j in range(num_points_z):
			var x = i - num_points_x / 2
			var z = j - num_points_z / 2
			
			# Calculate y using the given equation
			var y = a * sin(l * x) * cos(w * z)

			# Add the vertex to the array
			vertices.append(Vector3(x, y, z))

	# Add the array of vertices to the mesh
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_POINTS, [vertices])

	# Ensure the array is cleared for further use
	vertices.clear()

	# IMPORTANT: Reinitialize the array to avoid errors
	vertices = PackedVector3Array()

	# Generate points for x and z again
	for i in range(num_points_x):
		for j in range(num_points_z):
			var x = i - num_points_x / 2
			var z = j - num_points_z / 2
			
			# Calculate y using the given equation
			var y = a * sin(l * x) * cos(w * z)

			# Add the vertex to the array
			vertices.append(Vector3(x, y, z))

	# Add the second set of vertices to the mesh
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_POINTS, [vertices])
	
	self.mesh = mesh
	
	var material = ShaderMaterial.new()
	material.shader = preload("res://scripts/model.gdshader")  # Use a custom shader if needed
	self.material_override = material

