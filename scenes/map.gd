extends RigidBody3D

var left_hold_map = false
var right_hold_map = false
var top_left_coordinate = Vector2(0,0)
var bottom_right_coordinate = Vector2(0,0)
var selecting = false
var plane_size = Vector2(1, 1)
var selection_box = null

# Called when the node enters the scene tree for the first time.
func _ready():
	selection_box = null
	%Tree.visible = false
	%Bush.visible = false
	%Rock.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print("MAP: ", $Map)
	self.global_position.y = 1.5
	if left_hold_map:
		var controller_position = %LeftController.global_position
		var position_adjustment = %LeftController.global_transform.origin + Vector3(-plane_size.x / 2, 0, -plane_size.y / 2)
		$Map.global_transform.origin = position_adjustment
		$Map.global_position.y = controller_position.y
		$CollisionShape3D.global_position = $Map.global_position
		self.rotation = Vector3(0,0,0)
	if right_hold_map:
		var controller_position = %RightController.global_position
		var position_adjustment = %RightController.global_transform.origin - Vector3(plane_size.x / 2, -plane_size.y / 2, 0)	
		$Map.global_transform.origin = position_adjustment
		$Map.global_position.y = controller_position.y
		$CollisionShape3D.global_position = $Map.global_position
		self.rotation = Vector3(0,0,0)
		


func _on_left_button_pressed(name):
	if name == "ax_button":
		if left_hold_map:
			left_hold_map = false
			self.visible = false
			%Tree.visible = false
			%Bush.visible = false
			%Rock.visible = false
			print("left stop holding")
		elif !right_hold_map:
			left_hold_map = true
			self.visible = true
			%Tree.visible = true
			%Bush.visible = true
			%Rock.visible = true
			print("left start holding")
	if !left_hold_map && name == "trigger":
		selecting = true
		top_left_coordinate = Vector2(%LeftController.global_position.x, %LeftController.global_position.z)


func _on_left_controller_button_released(name):
	if name == "trigger" && selecting:
		selecting = false
		bottom_right_coordinate = Vector2(%LeftController.global_position.x, %LeftController.global_position.z)


func _on_right_button_pressed(name):
	if name == "ax_button":
		if right_hold_map:
			right_hold_map = false
			self.visible = false
			%Tree.visible = false
			%Bush.visible = false
			%Rock.visible = false
			
			print("right stop holding")
		elif !left_hold_map:
			right_hold_map = true
			self.visible = true
			%Tree.visible = true
			%Bush.visible = true
			%Rock.visible = true
			$Map.position.z += 1
			print("right start holding")
	if !right_hold_map && name == "trigger":
		selecting = true
		top_left_coordinate = Vector2(%RightController.global_position.x, %RightController.global_position.z)
	


func _on_right_button_released(name):
	if name == "trigger" && selecting:
		selecting = false
		bottom_right_coordinate = Vector2(%RightController.global_position.x, %RightController.global_position.z)
