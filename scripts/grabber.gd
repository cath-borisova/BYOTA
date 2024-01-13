extends Node3D

var grabbed_object: RigidBody3D = null
var previous_transform: Transform3D
var released = false
var released_object = null
var map_collision = null
var is_mini = false

func _ready():
	pass

func _process(_delta):
	if self.grabbed_object :
		self.grabbed_object.transform = self.global_transform * self.previous_transform.affine_inverse() * self.grabbed_object.transform
	self.previous_transform = self.global_transform

func _on_button_pressed(button_name: String) -> void:
	if button_name != "grip_click" || self.grabbed_object != null:
		return
	
	var grabbables = get_tree().get_nodes_in_group("grabbable")
	var collision_area = $Area3D as Area3D

	for grabbable in grabbables:
		var grabbable_body = grabbable as RigidBody3D
		if collision_area.overlaps_body(grabbable_body):
			var globals = get_node("/root/Globals")
			for grabber in globals.active_grabbers:
				if grabber.grabbed_object == grabbable_body:
					grabber.grabbed_object = null
					globals.active_grabbers.remove_at(globals.active_grabbers.find(self))
					break

			grabbable_body.freeze = true
			self.grabbed_object = grabbable_body
			globals.active_grabbers.push_back(self)
	
func _on_button_released(button_name: String) -> void:
	if button_name != "grip_click" || self.grabbed_object == null:
		return

	if self.is_mini:
		self.grabbed_object.released = true
		self.is_mini = false

	self.grabbed_object.freeze = false
	self.grabbed_object.linear_velocity = Vector3(0, -0.1, 0)
	self.grabbed_object.angular_velocity = Vector3.ZERO
	self.grabbed_object = null

	var globals = get_node("/root/Globals")
	globals.active_grabbers.remove_at(globals.active_grabbers.find(self))
