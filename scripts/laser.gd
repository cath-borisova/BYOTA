extends Node3D

func _ready():
	self.visible = false

func _process(delta):
	if %GraphRigidBody.visible
		self.scale.z = 100
		self.position.z = -50

		var start_point = get_parent().global_position
		var end_point = get_parent().global_transform * Vector3(0, 0, -100)

		var query = PhysicsRayQueryParameters3D.create(start_point, end_point)
		query.collide_with_areas = true

		var result = get_world_3d().direct_space_state.intersect_ray(query)

		var is_visible = false
		if !result.is_empty():
			var collision_distance = result["position"].distance_to(start_point)
			self.scale.z = collision_distance
			self.position.z = -collision_distance / 2
			var buttons = get_tree().get_nodes_in_group("button")
			for button in buttons:
				if result["collider_id"] == button.get_instance_id():
					is_visible = true
			self.visible = is_visible

func _on_controller_button_pressed(button_name):
	if button_name == "trigger_click" && %GraphRigidBody.visible:
		var start_point = get_parent().global_position
		var end_point = get_parent().global_transform * Vector3(0, 0, -100)

		var query = PhysicsRayQueryParameters3D.create(start_point, end_point)
		query.collide_with_areas = true

		var result = get_world_3d().direct_space_state.intersect_ray(query)

		if !result.is_empty():
			var collision_distance = result["position"].distance_to(start_point)
			self.scale.z = collision_distance
			self.position.z = -collision_distance / 2

			var buttons = get_tree().get_nodes_in_group("button")
			for button in buttons:
				if result["collider_id"] == button.get_instance_id():
					if button.name == "Create":
						%GraphRigidBody.create()
					elif button.name == "Cancel":
						%GraphRigidBody.cancel()

