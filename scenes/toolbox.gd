extends Node

var globals = null
# Called when the node enters the scene tree for the first time.
func _ready():
	globals = get_node("/root/Globals")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.visible:
		globals.position_above_user(self)
