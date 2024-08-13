extends Node3D
@onready var Turn = $Turn
@onready var Player = $Player
@onready var Opponent = $Opponent
@onready var UI = $UI
@onready var Node_Manager = $Node_Manager
@onready var Zone_Manager = $Zone_Manager
@onready var pass_button = $UI/Control/Next_Step
@onready var The_Stack = $Player/The_Stack
var live_draft = true
var turn_number = 0
var home_region = true
var split_region = false
# Called when the node enters the scene tree for the first time.
func _ready():
	Turn.step_changed.connect(self.on_step_changed)
	Node_Manager.turn_off_draft()
	#Node_Manager.turn_off_board()
	Node_Manager.turn_off_resources()
	#Node_Manager.turn_off_attack_zone()
	#Node_Manager.turn_off_defensive_zone()
	Node_Manager.hide_attack_button()
	Zone_Manager.hide_battle_zones()
	Zone_Manager.hide_draft_zone()
	Zone_Manager.hide_resource_zone()
	Zone_Manager.hide_play_zone()
	Zone_Manager.hide_the_stack_zone()
	#hide_title_and_subtitle()
	Player.player_resources_changed.connect(UI.get_node("Control/Mana").update_mana_display)
	Turn.next_step()

func _input(event: InputEvent):
	if event.is_action_pressed("pass_priority"):
		Turn.next_step()
		print("Button pressed")


func on_step_changed(phase, new_step):
	print("Moved to ", phase, ": ", new_step)
	call(new_step.to_lower())
	
func refresh():
	#'Refresh resources and move to next phase'
	if turn_number > 0:
		Player.activated_resources = 0
	Turn.next_step()
	
func draw():
	#'Draw cards and move to next phase'
	for i in Player.num_draw:
		if live_draft:
			Player.draft.deal_card()
		else:
			Player.hand.draw_card()
		
	Turn.next_step()

func darken_background():
	Player.hider.show()

func return_background():
	Player.hider.hide()

func set_title_and_subtitle(title, subtitle):
	var title_node = get_node("Title/Title")
	title_node.text = title
	title_node.show()
	var subtitle_node = title_node.get_child(0)
	subtitle_node.text = subtitle

func hide_title_and_subtitle():
	var title_node = get_node("Title/Title")
	title_node.text = ''
	title_node.show()
	var subtitle_node = title_node.get_child(0)
	subtitle_node.text = ''
	
func draft():
	print("Draft Cards")
	darken_background()
	var draft_title = "Draft"
	var draft_subtitle = "Choose Your Hand"
	set_title_and_subtitle(draft_title, draft_subtitle)
	#Node_Manager.turn_off_board()
	Node_Manager.hide_opponent_hand()
	Node_Manager.turn_on_draft()
	Node_Manager.hide_mana()
	Node_Manager.hide_life()
	Zone_Manager.hide_play_zone()
	Zone_Manager.show_draft_zone()
	Zone_Manager.hide_bin_zone()
	Zone_Manager.hide_the_stack_zone()
	

func resources():
	Node_Manager.turn_off_draft()
	Node_Manager.show_mana()
	Node_Manager.turn_on_resources()
	Zone_Manager.hide_draft_zone()
	Zone_Manager.show_resource_zone()

	var draft_title = "Resources"
	var draft_subtitle = "Create Resources"
	set_title_and_subtitle(draft_title, draft_subtitle)
	print("Create and activate Resources")
	Player.activate_dormant_resources()
	Player.resources.make_resources_visible_in_hand()

func haste():
	Player.resources.remove_resources_from_hand()
	Node_Manager.turn_off_resources()
	Node_Manager.show_life()
	Zone_Manager.hide_resource_zone()
	Zone_Manager.show_bin_zone()
	Zone_Manager.show_the_stack_zone()
	Node_Manager.show_opponent_hand()
	hide_title_and_subtitle()
	return_background()
	#Node_Manager.turn_on_board()
	#Node_Manager.turn_on_defensive_zone()
	print("Play Haste Cards")

func attack():
	#Node_Manager.move_play_zone
	#Node_Manager.turn_off_board()
	#Node_Manager.turn_on_attack_zone()
	#Node_Manager.turn_on_defensive_zone()
	split_region = true
	Player.active_board = Player.away_board
	#var attack_title = "Attack"
	#var attack_subtitle = "Send units into formation"
	#set_title_and_subtitle(attack_title, attack_subtitle)
	Zone_Manager.hide_the_stack_zone()
	Player.divider_bar.set_bar_rotation_for_battle()
	Zone_Manager.set_zones_for_attack()
	Zone_Manager.hide_play_zone()
	Node_Manager.move_zones_for_attack()
	Node_Manager.show_attack_button()
	Node_Manager.call_deferred("count_active_zone_dimensions")
	#Node_Manager.count_active_zone_dimensions()
	print("Attack Formation")
	

func offensive_battle():
	home_region = false
	split_region = false
	Player.active_board = Player.away_board

	hide_title_and_subtitle()
	Node_Manager.hide_attack_button()
	Node_Manager.move_zones_for_offense()
	Player.divider_bar.set_bar_position_for_offense()
	Zone_Manager.set_zones_for_offense_battle()
	Zone_Manager.show_the_stack_zone()
	print("Offensive Battle")
	
func defensive_battle():
	home_region = true
	Player.active_board = Player.board
	Opponent.active_board = Opponent.away_board
	Player.divider_bar.set_bar_position_for_defense()
	Zone_Manager.set_zones_for_defense_battle()
	Node_Manager.move_zones_for_defense()

func regroup():
	#Node_Manager.turn_on_board()
	Opponent.active_board = Opponent.board
	Node_Manager.move_units_home()
	Node_Manager.reset_zone_positions()
	#Node_Manager.turn_off_attack_zone()
	Zone_Manager.hide_battle_zones()
	Zone_Manager.show_play_zone()
	#Node_Manager.turn_off_defensive_zone()
	Player.divider_bar.reset_bar_rotation()
	print("Regroup")
	Turn.next_step()

func deployment():
	print("Play units and mods")
	Player.bin.make_mods_visible_in_hand()
	Player.bin.deployment = true

func end_of_turn():
	print("End turn")
	Player.bin.remove_mods_from_hand()
	
	turn_number += 1
	Turn.next_step()
	



func _on_next_step_pressed():
	if Player.priority and The_Stack.is_empty():
		Turn.next_step()
	else:
		The_Stack.resolve_top_card()


func _on_in_play_not_formation_child_entered_tree(node):
	pass # Replace with function body.
