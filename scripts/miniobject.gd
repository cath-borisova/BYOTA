extends RigidBody3D

var mapRigidBody = null
var map = null
var area3d = null
var ground = null
var in_map = false
var released = false
var right_hand_grabbed = false
var left_hand_grabbed = false
var offset_distance = 0.05
var right_controller = null
var left_controller = null
var copy = null
var first = true
var globals = null

func _ready():
	mapRigidBody = get_node("../MapRigidBody")
	map = get_node("../MapRigidBody/Map")
	area3d = $Area3D
	ground = get_node("../Ground")
	right_controller = get_node("../XROrigin3D/RightController")
	left_controller = get_node("../XROrigin3D/LeftController")
	self.can_sleep = false
	globals = get_node("/root/Globals")
func _process(_delta):
	if released && !in_map:
		if area3d.overlaps_body(mapRigidBody):
			print("here")
			if first:
				var position = self.global_position
				self.get_parent().remove_child(self)
				self.remove_from_group("grabbable")
				self.add_to_group("mini")
				first = false
				map.add_child(self)
				self.global_position = position
			self.freeze = true

			if self.position.x < -0.25 || self.position.x > 0.25 || self.position.z < -0.25 || self.position.z > 0.25:
				print("did i get deleted?")
				self.queue_free()
			self.position.y = 0.001
			self.rotation = Vector3(0,0,0)
			in_map = true
			
			var shape_name = self.name.substr(5, 4)
			var new_shape_scene = load("res://scenes/large_"+shape_name+".tscn")
			copy = new_shape_scene.instantiate()
			copy.name = "Large - " + self.name
			get_node("/root/Main").add_child(copy)
			copy.add_to_group("large_objects")
			var big_position = Vector3((200 * self.position.x), 0.1, (200* self.position.z))
			copy.scale = Vector3($Object.scale.x * 100, $Object.scale.y * 100, $Object.scale.z * 100)
			copy.rotation = $Object.rotation
			var globals = get_node("/root/Globals")
			var terrain_data = globals.terrian_info
			var big_height = terrain_data.get_height_at((big_position.x+50)*5.13,(big_position.z+50)*5.13)
			
			if big_height > 0:
				copy.global_position = big_position
				copy.global_position.y = big_height / 5.13 + 0.2
			elif big_height < 0:
				copy.global_position = big_position
				copy.global_position.y = big_height / 5.13 - 0.2
			else:
				copy.global_position = big_position
				
	if area3d.overlaps_body(ground):
		print("ground")
		if copy != null:
			copy.queue_free()
			copy = null
		self.queue_free()
	if right_hand_grabbed && left_hand_grabbed:
		self.global_position = (left_controller.global_position + right_controller.global_position) / 2;
		var difference = abs(left_controller.global_position.distance_to(right_controller.global_position)) * 0.25 ;
		$Object.scale = Vector3(difference, difference, difference)
		$CollisionShape3D.scale = Vector3(difference, difference, difference)
		self.look_at(left_controller.global_position);
	elif right_hand_grabbed:
		globals.transform(self, right_controller)
	elif left_hand_grabbed:
		globals.transform(self, left_controller)
		
