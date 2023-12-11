extends RigidBody3D

var camera
var right_hand

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = %XRCamera3D
	right_hand = %RightController
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#code to follow users view
	#self.global_position =  camera.global_position
	#self.global_position.z = camera.global_position.z - 0.5
	#self.global_position.x = camera.global_position.x + 0.4
	
	#code to detect if right hand is close to object
	#print(right_hand.global_position.distance_to(self.global_position))
	#if right_hand.global_position.distance_to(self.global_position) < 1.2:
		#self.mesh.material.albedo_color = Color(0.784, 0.592, 0.004)
	
	pass
