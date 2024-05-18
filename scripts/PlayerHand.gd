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
@export var gizmo_node : Node3D

#Onready Variables

#Other Variables (please try to separate and organise!)
var current_block : RigidBody3D
var tar_rotation : Vector3
var tar_position : Vector3

#endregion

#region Godot methods
func _ready():
	#Runs when all children have entered the tree
	pass
	
func _process(delta):
	
	#var target_vector = global_position.direction_to(player_position)
	#var target_basis= Basis.looking_at(target_vector)
	#basis = basis.slerp(target_basis, 0.5)
	rotation_degrees = lerp(rotation_degrees, tar_rotation, 0.1)
	position = lerp(position, tar_position, 0.1)
	gizmo_node.rotation_degrees = rotation_degrees
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
	tar_position = position
	tar_position += dir * amount * moveScale
	#position += dir * amount * moveScale


func _on_twitch_link_rotate_block(direction, amount):
	var dir : Vector3
	match direction:
		"x": dir.x = 1 
		"y" : dir.y = 1
		"z" : dir.z = 1
	#rotation_degrees += dir * amount
	tar_rotation = rotation_degrees
	tar_rotation += dir * amount

func _on_twitch_link_drop_block():
	current_block.freeze = false
	current_block.reparent(blocks_node)


func _on_twitch_link_start_turn():
	position = Vector3(0,2.28,0)
	rotation_degrees =  Vector3(0,0,0)
	current_block = block_scene.instantiate()
	current_block.freeze = true
	add_child(current_block)

func _on_jenga_panic_drop():
	_on_twitch_link_drop_block()


#endregion

#region Other methods (please try to separate and organise!)

#endregion









