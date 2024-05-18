extends Node3D
#class_name
#Authored by Tom. Please consult for any modifications or major feature requests.

#region Variables
#Signals

#Enums

#Constants

#Exported Variables
#@export_group("Group")
#@export_subgroup("Subgroup")

#Onready Variables

#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _ready():
	#Runs when all children have entered the tree
	pass

func _process(delta):
	#Runs per frame
	pass
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion


func _on_twitch_link_move_block(direction, amount):
	var dir : Vector3
	match direction:
		"up": dir = Vector3.UP
		"down" : dir = Vector3.DOWN
		"north" : dir = Vector3.FORWARD
		"east" : dir = Vector3.RIGHT
		"south" : dir = Vector3.BACK
		"west" : dir = Vector3.LEFT
	position += dir * amount
