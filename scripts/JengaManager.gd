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
@export var turn_time_limit : float = 60
@export var accept_time_limit : float = 20
@export_group("Node References")
@export var debug_ui_label : Label

#Onready Variables

#Other Variables (please try to separate and organise!)
var player_queue : Array[String]
var current_player : String = ""
var turn_timer : float
var turn_started : bool #cant do stuff unless this is true

#endregion

#region Godot methods
func _ready():
	#Runs when all children have entered the tree
	pass

func _process(delta):
	turn_timer -= delta
	if(current_player == "" or turn_timer<0):
		current_player = ""
		#switch to the next players turn (if anyone is in the queue)
		if(player_queue.size()>0):
			current_player = player_queue[0]
			player_queue.erase(current_player)
			turn_started = false
			turn_timer = accept_time_limit
	debug_ui_label.text = "Current Player: " + current_player + "\nTurn Started?: " + str(turn_started) + "\nTime Left: " + str(round(turn_timer)) + "\nQueue Size: " + str(player_queue.size())

#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion


