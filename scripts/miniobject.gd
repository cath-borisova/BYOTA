extends Node

var mapRigidBody = null
var map = null
var area3d = null
var ground = null
var in_map = false
var released = false

func _ready():
	mapRigidBody = get_node("../MapRigidBody")
	map = get_node("../MapRigidBody/Map")
	area3d = $Area3D
	ground = get_node("../Ground")

func _process(_delta):
	if released && !in_map:
		if area3d.overlaps_body(mapRigidBody):
			var position = self.global_position
			self.get_parent().remove_child(self)
			map.add_child(self)
			self.remove_from_group("grabbable")
			self.freeze = true
			self.global_position = position
			if self.position.x < -0.25 || self.position.x > 0.25 || self.position.z < -0.25 || self.position.z > 0.25:
				self.queue_free()
			self.position.y = 0.001
			self.rotation = Vector3(0,0,0)
			in_map = true
			
			var shape_name = self.name.substr(5, 4)
			var new_shape_scene = load("res://scenes/large_"+shape_name+".tscn")
			var new_shape = new_shape_scene.instantiate()
			new_shape.name = "Large - " + self.name
			get_node("/root/Main").add_child(new_shape)
			new_shape.add_to_group("large_objects")
			var big_position = Vector3((200 * self.position.x), 0.1, (200* self.position.z))
			var globals = get_node("/root/Globals")
			var terrain_data = globals.terrian_info
			var big_height = terrain_data.get_height_at((big_position.x+50)*5.13,(big_position.z+50)*5.13)
			
			if big_height > 0:
				new_shape.global_position = big_position
				new_shape.global_position.y = big_height / 5.13 + 0.2
			elif big_height < 0:
				new_shape.global_position = big_position
				new_shape.global_position.y = big_height / 5.13 - 0.2
			else:
				new_shape.global_position = big_position
			# y = equations[x][z][0] * sin(equations[x][z][1] * x) * cos(equations[x][z][2] * z)
			var equation = globals.get_equation((big_position.x+50)*5.13,(big_position.z+50)*5.13)
			print("y = ", equation[0], " * sin(",equation[1]," * ", new_shape.global_position.x, ") * cos(", equation[2], " * ", new_shape.global_position.z, ")") 
			get_node("/root/Main/"+new_shape.name+"/equation").text = "y = "+ str(equation[0]) + " * sin(" + str(equation[1]) + " * " + str(new_shape.global_position.x) + ") * cos("+ str(equation[2])+ " * "+ str(new_shape.global_position.z) + ")"
			#.get_child("equation").text = "y = "+ str(equation[0]) + " * sin(" + str(equation[1]) + " * " + str(new_shape.global_position.x) + ") * cos("+ str(equation[2])+ " * "+ str(new_shape.global_position.z) + ")"
		elif area3d.overlaps_body(ground):
			self.queue_free()
		
