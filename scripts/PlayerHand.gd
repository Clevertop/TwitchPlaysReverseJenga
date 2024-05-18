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
@export_group("Config")
@export var moveScale : float = 1
@export_group("Prefabs")
@export var block_scene : PackedScene
@export_group("Node References")
@export var blocks_node : Node3D

#Onready Variables

#Other Variables (please try to separate and organise!)
var current_block : RigidBody3D

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
func _on_twitch_link_move_block(direction, amount):
	var dir : Vector3
	match direction:
		"up": dir = Vector3.UP
		"down" : dir = Vector3.DOWN
		"north" : dir = Vector3.FORWARD
		"east" : dir = Vector3.RIGHT
		"south" : dir = Vector3.BACK
		"west" : dir = Vector3.LEFT
	position += dir * amount * moveScale


func _on_twitch_link_drop_block():
	current_block.freeze = false
	current_block.reparent(blocks_node)


func _on_twitch_link_start_turn():
	position = Vector3(0,3,0)
	current_block = block_scene.instantiate()
	current_block.freeze = true
	add_child(current_block)
	


#endregion

#region Other methods (please try to separate and organise!)

#endregion



