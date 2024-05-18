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
@export var rotation_speed : float = 20 #degrees per second
@export var height_speed : float = 0.5 # m per second

@export_group("Node References")
@export var gizmo_pivot : Node3D

#Onready Variables

#Other Variables (please try to separate and organise!)
var target_rotation : float = 0 
var target_height : float = 3.445

#endregion

#region Godot methods
func _ready():
	#Runs when all children have entered the tree
	pass

func _process(delta):
	if abs(rotation_degrees.y - target_rotation) < 1:
		rotation_degrees.y = target_rotation
	else:
		if(target_rotation > rotation_degrees.y):
			rotation_degrees.y += rotation_speed * delta
		else:
			rotation_degrees.y -= rotation_speed * delta
	pass
	gizmo_pivot.rotation_degrees.y = rotation_degrees.y
#endregion

#region Signal methods

func _on_twitch_link_rotate_camera(direction, amount):
	var dir
	match direction:
		"left" : dir = -1
		"right" : dir = 1
	target_rotation += dir * float(amount)

#endregion

#region Other methods (please try to separate and organise!)

#endregion


