extends Node3D
#class_name
#Authored by Tom. Please consult for any modifications or major feature requests.

#region Variables
#Signals
signal panic_drop()
signal new_player_up()
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
@export_subgroup("GameUI")
@export var current_player_label : Label
@export var next_up_label: Label
@export var timer_bar : TextureProgressBar
@export var turn_alert_label : Label

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
	if(turn_timer<0 and turn_started):
		panic_drop.emit()
		turn_started = false
	if(current_player == "" or turn_timer<0):
		current_player = ""
		#switch to the next players turn (if anyone is in the queue)
		if(player_queue.size()>0):
			current_player = player_queue[0]
			player_queue.erase(current_player)
			turn_started = false
			new_player_up.emit()
			turn_timer = accept_time_limit
	#debug_ui_label.text = "Current Player: " + current_player + "\nTurn Started?: " + str(turn_started) + "\nTime Left: " + str(round(turn_timer)) + "\nQueue Size: " + str(player_queue.size())
	
	current_player_label.text ="Current Player: " + current_player
	next_up_label.text = "Up Next: " + str(player_queue)
	
	if(turn_timer < 0 && player_queue.size() == 0):
		turn_alert_label.text = "Type !join_queue to play"
		timer_bar.value = 0
	elif(turn_timer > 0 and not turn_started):
		turn_alert_label.text = current_player+ "  you're up! Type !start_turn"
		timer_bar.value = turn_timer/ accept_time_limit
	elif(turn_timer > 0 and turn_started):
		turn_alert_label.text = "Use !move, !rotate, !camera and !drop to play your turn"
		timer_bar.value = turn_timer/ turn_time_limit

#endregion

#region Signal methods
func _on_twitch_link_drop_block():
	turn_timer = 0
#endregion

#region Other methods (please try to separate and organise!)

#endregion





