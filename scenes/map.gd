extends RigidBody3D

var left_hold_map = false
var right_hold_map = false

var left_selecting = false
var right_selecting = false

var top_left_coordinate = Vector2(0,0)
var bottom_right_coordinate = Vector2(0,0)

var plane_size = Vector2(1, 1)
var selection_box = null
var current_size = Vector3(0.1, 0, 0.1)

# Called when the node enters the scene tree for the first time.
func _ready():
	selection_box = null
	%Tree.visible = false
	%Bush.visible = false
	%Rock.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	#if left_selecting:
		#current_size = $Map/SelectionBox.size
	#if right_selecting:
		#current_size = $Map/SelectionBox.size
		

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
	if !left_hold_map && name == "trigger_click":
		left_selecting = true
		top_left_coordinate = Vector2(%LeftController.global_position.x + current_size.x, %LeftController.global_position.z - current_size.z)
		$Map/SelectionBox.global_position.x = top_left_coordinate.x
		$Map/SelectionBox.global_position.z = top_left_coordinate.y
		print("left view map")
		$Map/SelectionBox.visible = true
		

func _on_left_controller_button_released(name):
	if name == "trigger_click" && left_selecting:
		left_selecting = false
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
	if !right_hold_map && name == "trigger_click":
		right_selecting = true
		print("current map size: ", current_size)
		print("controller position: ", %RightController.global_position)
		top_left_coordinate = Vector2(%RightController.global_position.x + current_size.x, %RightController.global_position.z - current_size.z)
		$Map/SelectionBox.global_position.x = top_left_coordinate.x
		$Map/SelectionBox.global_position.z = top_left_coordinate.y
		print("top left coordinate: ", top_left_coordinate)
		print("selection position: ", $Map/SelectionBox.global_position)
		$Map/SelectionBox.visible = true
		print("right view map")
	


func _on_right_button_released(name):
	if name == "trigger_click" && right_selecting:
		right_selecting = false
		bottom_right_coordinate = Vector2(%RightController.global_position.x, %RightController.global_position.z)
