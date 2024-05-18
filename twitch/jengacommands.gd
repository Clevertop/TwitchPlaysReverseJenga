extends Gift

signal moveBlock(direction : String, amount : float)
signal rotateBlock(direction : String, amount : float)
signal rotateCamera(direction : String, amount : float)
signal dropBlock()
signal startTurn()

@export_group("Node References")
@export var jenga_manager : Node

func _ready() -> void:
	cmd_no_permission.connect(no_permission)
	##chat_message.connect(on_chat)
	event.connect(on_event)

	# I use a file in the working directory to store auth data
	# so that I don't accidentally push it to the repository.
	# Replace this or create a auth file with 3 lines in your
	# project directory:
	# <client_id>
	# <client_secret>
	# <initial channel>
	var authfile := FileAccess.open("./twitch/auth.txt", FileAccess.READ)
	client_id = authfile.get_line()
	client_secret = authfile.get_line()
	var initial_channel = authfile.get_line()

	# When calling this method, a browser will open.
	# Log in to the account that should be used.
	await(authenticate(client_id, client_secret))
	var success = await(connect_to_irc())
	if (success):
		request_caps()
		join_channel(initial_channel)
		await(channel_data_received)
	await(connect_to_eventsub()) # Only required if you want to receive EventSub events.
	# Refer to https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/ for details on
	# what events exist, which API versions are available and which conditions are required.
	# Make sure your token has all required scopes for the event.
	subscribe_event("channel.follow", 2, {"broadcaster_user_id": user_id, "moderator_user_id": user_id})

	#region test_commands
	# Adds a command with a specified permission flag.
	# All implementations must take at least one arg for the command info.
	# Implementations that recieve args requrires two args,
	# the second arg will contain all params in a PackedStringArray
	# This command can only be executed by VIPS/MODS/SUBS/STREAMER
	add_command("test", command_test, 0, 0, PermissionFlag.NON_REGULAR)

	# These two commands can be executed by everyone
	add_command("helloworld", hello_world)
	add_command("greetme", greet_me)

	# This command can only be executed by the streamer
	add_command("streamer_only", streamer_only, 0, 0, PermissionFlag.STREAMER)

	# Command that requires exactly 1 arg.
	add_command("greet", greet, 1, 1)

	# Command that prints every arg seperated by a comma (infinite args allowed), at least 2 required
	add_command("list", list, -1, 2)
	#endregion

	## Queue Management
	add_command("join_queue", join_queue)
	add_command("leave_queue", leave_queue)
	add_command("start_turn", start_turn)
	add_command("pass_turn", pass_turn)
	add_aliases("join_queue", ["jq", "join"])
	add_aliases("start_turn", ["st", "start"])

	## Gameplay Commands 
	#camera movement command - !camera left 20 (moves camera left 20 units)
	add_command("camera", camera, 2,2)
	
	#move block commands - !move north 10
	add_command("move", move, 2,2)
	add_command("rotate", rotate, 2,2)
	
	add_command("drop", drop)



func on_event(type : String, data : Dictionary) -> void:
	match(type):
		"channel.follow":
			print("%s followed your channel!" % data["user_name"])

#func on_chat(data : SenderData, msg : String) -> void:
	#%ChatContainer.put_chat(data, msg)

# Check the CommandInfo class for the available info of the cmd_info.
func command_test(cmd_info : CommandInfo) -> void:
	print("A")

func hello_world(cmd_info : CommandInfo) -> void:
	chat("HELLO WORLD!")

func streamer_only(cmd_info : CommandInfo) -> void:
	chat("Streamer command executed")

func no_permission(cmd_info : CommandInfo) -> void:
	chat("NO PERMISSION!")

func greet(cmd_info : CommandInfo, arg_ary : PackedStringArray) -> void:
	chat("Greetings, " + arg_ary[0])

func greet_me(cmd_info : CommandInfo) -> void:
	chat("Greetings, " + cmd_info.sender_data.tags["display-name"] + "!")

func list(cmd_info : CommandInfo, arg_ary : PackedStringArray) -> void:
	var msg = ""
	for i in arg_ary.size() - 1:
		msg += arg_ary[i]
		msg += ", "
	msg += arg_ary[arg_ary.size() - 1]
	chat(msg)



func join_queue(cmd_info : CommandInfo):
	#add sender to queue array
	var player_name = cmd_info.sender_data.tags["display-name"]
	var searchResult = jenga_manager.player_queue.find(player_name)
	if (searchResult == -1):
		#not found in queue, they get added
		jenga_manager.player_queue.append(player_name)
		chat(str(player_name) + " joined the queue")
	else:
		chat("Sorry " + player_name + " you already in the queue at position: " + searchResult)
	
func leave_queue(cmd_info : CommandInfo):
	#remove sender from queue array
	var player_name = cmd_info.sender_data.tags["display-name"]
	var searchResult = jenga_manager.player_queue.find(player_name)
	if (searchResult == -1):
		chat(str(player_name) + "! you are not currently in the queue, join with !join_queue")
	else:
		jenga_manager.player_queue.erase(player_name)
		chat(searchResult + " left the queue")
	
	pass

func start_turn(cmd_info : CommandInfo):
	#give the player who turn is about to start 20(?) seconds to confirm their turn
	if(cmd_info.sender_data.tags["display-name"] == jenga_manager.current_player and not jenga_manager.turn_started):
		startTurn.emit()
		jenga_manager.turn_started=true
		jenga_manager.turn_timer = jenga_manager.turn_time_limit
	pass
	
func pass_turn(cmd_info : CommandInfo):
	#allow the player to pass their turn and leave the queue if they no longer wish to play
	if(cmd_info.sender_data.tags["display-name"] == jenga_manager.current_player and jenga_manager.turn_started):
		jenga_manager.turn_timer = 0 #might change this later depeding on how i set up penalties
	pass




func camera(cmd_info : CommandInfo, arg_ary : PackedStringArray) -> void:
	chat("moving camera " + arg_ary[0] + " by " + arg_ary[1] + " degrees")
	if(cmd_info.sender_data.tags["display-name"] == jenga_manager.current_player and jenga_manager.turn_started) :
		var chosenDirection = arg_ary[0].to_lower()
		var validDirections = ["left","right"]
		if(validDirections.has(chosenDirection)):
			rotateCamera.emit(arg_ary[0],float(arg_ary[1]))
			chat("moving camera " + arg_ary[0] + " by " + arg_ary[1] + " degrees")
		else:
			chat("invalid direction :(")
	
func move(cmd_info : CommandInfo, arg_ary : PackedStringArray) -> void:
	if(cmd_info.sender_data.tags["display-name"] == jenga_manager.current_player and jenga_manager.turn_started) :
		var chosenDirection = arg_ary[0].to_lower()
		var validDirections = ["up","down","north","south","east","west"]
		if(validDirections.has(chosenDirection)):
			moveBlock.emit(arg_ary[0],float(arg_ary[1]))
			chat("moving block " + arg_ary[0] + " by " + arg_ary[1] + " units")
		else:
			chat("invalid direction :(")

func rotate(cmd_info : CommandInfo, arg_ary : PackedStringArray) -> void:
	if(cmd_info.sender_data.tags["display-name"] == jenga_manager.current_player and jenga_manager.turn_started) :
		var chosenDirection = arg_ary[0].to_lower()
		var validDirections = ["x","y","z"]
		if(validDirections.has(chosenDirection)):
			rotateBlock.emit(arg_ary[0],float(arg_ary[1]))
			chat("rotating block " + arg_ary[0] + " by " + arg_ary[1] + " degrees")
		else:
			chat("invalid direction :(")

func drop(cmd_info : CommandInfo):
	#make block child of world and unfreeze the rb
	if(cmd_info.sender_data.tags["display-name"] == jenga_manager.current_player and jenga_manager.turn_started) :
		chat("Dropping the block!")
		dropBlock.emit()
		## TODO 5s/10s to watch for what block does and wait for it to finish moving before next player starts
		
