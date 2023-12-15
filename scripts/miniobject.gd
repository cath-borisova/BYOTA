extends Node

var map = null
var area3d = null
var ground = null
var in_map = false
var released = false

# Called when the node enters the scene tree for the first time.
func _ready():
	map = get_node("../MapRigidBody")
	area3d = $Area3D
	ground = get_node("../Ground")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if released && !in_map:
		if area3d.overlaps_body(map):
			var position = self.global_position
			self.get_parent().remove_child(self)
			map.add_child(self)
			self.remove_from_group("grabbable")
			self.freeze = true
			self.global_position = position
			self.position.y = 0.001
			self.rotation = Vector3(0,0,0)
			in_map = true
			
			var new_shape_scene = load("res://scenes/large_tree.tscn")
			var new_shape = new_shape_scene.instantiate()
			get_node("/root/Main").add_child(new_shape)
			new_shape.global_position = Vector3((200 * self.position.x) - 50, 0.1, (200* self.position.z) - 50)

			#set position?
	#if collision.overlaps_body
		
