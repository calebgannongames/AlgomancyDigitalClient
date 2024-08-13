extends Node3D

@onready var hand = $Hand
@onready var hider = $Hider
@onready var draft = $Draft
@onready var bin = $Bin
@onready var the_stack = $The_Stack



@onready var attack_formation = $Enemy_Region/Attacking_Formation
@onready var block_formation = $Own_Region/Blocking_Formation

@onready var resource_selection = $Resource_Selection
@onready var resources = $Resources
@onready var board = $Own_Region/In_Play_Not_Formation
#@onready var board = $Own_Region/In_Play_Not_Formation
@onready var away_board = $Enemy_Region/In_Play_Not_Formation
@onready var divider_bar = $Floor/Divider_Bar


@onready var active_board = board
var priority = true
var num_draw = 2
var starting_hand = 6
var resource_activations = 2
var activated_resources = 2
var auto_activate_resources = true
signal player_resources_changed()

func give_player_resource(resource_name:String):
	var resource_info = GameState.resources[resource_name]
	if auto_activate_resources:
		resource_info['Status'] = "Active"
	GameState.game_state['Player']['Resources'].append(resource_info)
	activated_resources += 1
	check_for_triple_affinity_bonus(resource_name)
	emit_signal("player_resources_changed")

func activate_dormant_resources():
	for resource in GameState.game_state['Player']['Resources']:
		if resource['Status'] == "Dormant" and activated_resources < resource_activations:
			#update resource to be "Active"
			resource['Status'] = "Active"
			if activated_resources == resource_activations:
				break

func give_player_shard():
	
	var shard_info = GameState.resources['Shard']
	if activated_resources < resource_activations:
		shard_info['Status'] = "Active"
		activated_resources += 1
	GameState.game_state['Player']['Resources'].append(shard_info)
	
func check_for_triple_affinity_bonus(resource_name:String):
	if resource_name != "Prismite" and resource_name != "Shard Resource":
		var num_affinity = 0
		for resource in GameState.game_state['Player']['Resources']:
			if resource['Name'] == GameState.resources[resource_name]['Name']:
				num_affinity += 1
		if num_affinity >= 3:
			give_player_shard()
		

func remove_prismite_from_player(data):
	for i in range(len(data["Player"]["Resources"])):
		if data["Player"]["Resources"][i]["Name"] == "Prismite":
			data["Player"]["Resources"].remove_at(i)
			break  # Break after removing the first match to avoid modifying the list during iteration

func trade_prismite_for_resource(resource_name:String):
	var resource_info = GameState.resources[resource_name]
	if auto_activate_resources:
		resource_info['Status'] = "Active"
	remove_prismite_from_player(GameState.game_state)
	GameState.game_state['Player']['Resources'].append(resource_info)
	check_for_triple_affinity_bonus(resource_name)
	emit_signal("player_resources_changed")

func attack_with_all():
	for unit in board.get_children():
		unit.move_node(attack_formation)
