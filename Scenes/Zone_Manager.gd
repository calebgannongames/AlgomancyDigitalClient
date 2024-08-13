extends Node2D
var mouse_zone = []
@onready var attack_zone = $Player_Attack_Formation
@onready var enemy_block_zone = $Player_Attack_Formation/Enemy_Block_Formation
@onready var player_board = $Player_Board
@onready var block_zone = $Player_Board/Player_Block_Formation
@onready var enemy_attack_zone = $Player_Board/Enemy_Attack_Formation
@onready var play_zone = $Play_Zone
@onready var bin_zone = $Bin_Zone
@onready var hand_zone = $Hand_Zone
@onready var draft_zone = $Draft_Zone
@onready var resource_selection_zone = $Resource_Selection_Zone
@onready var the_stack_zone = $The_Stack_Zone

@export_node_path var attack_zone_path
@export_node_path var enemy_block_zone_path
@export_node_path var player_board_zone_path
@export_node_path var player_away_board_zone_path
@export_node_path var block_zone_path
@export_node_path var enemy_attack_zone_path
@export_node_path var enemy_board_zone_path
@export_node_path var enemy_away_board_zone_path
@export_node_path var play_zone_path
@export_node_path var bin_zone_path
@export_node_path var hand_zone_path
@export_node_path var draft_zone_path
@export_node_path var resource_selection_zone_path
@export_node_path var the_stack_zone_path
@onready var attack_card_zone := get_node(attack_zone_path)
@onready var enemy_block_card_zone := get_node(enemy_block_zone_path)
@onready var player_board_card_zone := get_node(player_board_zone_path)
@onready var player_away_board_card_zone := get_node(player_away_board_zone_path)
@onready var enemy_board_card_zone := get_node(enemy_board_zone_path)
@onready var enemy_away_board_card_zone := get_node(enemy_away_board_zone_path)
@onready var block_card_zone := get_node(block_zone_path)
@onready var enemy_attack_card_zone := get_node(enemy_attack_zone_path)
@onready var play_card_zone := get_node(play_zone_path)
@onready var bin_card_zone := get_node(bin_zone_path)
@onready var hand_card_zone := get_node(hand_zone_path)
@onready var draft_card_zone := get_node(draft_zone_path)
@onready var resource_selection_card_zone := get_node(resource_selection_zone_path)
@onready var the_stack_card_zone := get_node(the_stack_zone_path)
var attack_positions = [Vector2(0, 0), Vector2(1920, 0)]
var offense_positions = [Vector2(-960, 0), Vector2(960, 0)]
var defense_positions = [Vector2(960, 0), Vector2(2880, 0)]

var mouse_zone_lookup = {}

func _ready():
	for area in get_children():
		if area is Area2D:
			area.mouse_entered.connect(mouse_entered_zone.bind(area))
			area.mouse_exited.connect(mouse_left_zone.bind(area))
		for sub_area in area.get_children():
			if sub_area is Area2D:
				sub_area.mouse_entered.connect(mouse_entered_zone.bind(sub_area))
				sub_area.mouse_exited.connect(mouse_left_zone.bind(sub_area))
			
	mouse_zone_lookup = {
	"Play_Zone": play_card_zone,
	"Hand_Zone": hand_card_zone,
	"Player_Attack_Formation": attack_card_zone,
	"Player_Block_Formation": block_card_zone,
	"Enemy_Block_Formation": enemy_block_card_zone,
	"Enemy_Attack_Formation": enemy_attack_card_zone,
	"Player_Board": player_board_card_zone,
	"Player_Away_Board": player_away_board_card_zone,
	"Enemy_Board": enemy_board_card_zone,
	"Enemy_Away_Board": enemy_away_board_card_zone,
	"Bin_Zone": bin_card_zone,
	"Draft_Zone": draft_card_zone,
	"Resource_Selection_Zone": resource_selection_card_zone,
	"The_Stack_Zone": the_stack_card_zone,
}

func card_released(card):
	if mouse_zone != []:
		#print("Mouse zone is: ", mouse_zone.name)
		var released_zone = mouse_zone_lookup[mouse_zone[-1].name]
		#print("Card released in: ", released_zone.name)
		if card.get_parent() != released_zone:
			released_zone.card_played(card)
			
	

func mouse_entered_zone(area):
	mouse_zone.append(area)
	print(mouse_zone[-1].name)
	#Debug print
	

func mouse_left_zone(area):
	mouse_zone.erase(area)
	#print(area.name)
	#if !mouse_zone.is_empty():
		#print(mouse_zone[-1].name)


func set_zones_for_attack():
	player_board.show()
	attack_zone.show()
	enemy_block_zone.show()
	player_board.position = attack_positions[0]
	attack_zone.position = attack_positions[1]
	

func set_zones_for_offense_battle():
	enemy_block_zone.show()
	player_board.position = offense_positions[0]
	attack_zone.position = offense_positions[1]
func set_zones_for_defense_battle():
	player_board.position = defense_positions[0]
	attack_zone.position = defense_positions[1]

func set_zones_for_attack_by_ratio(ratio):
	var buffer
	if ratio >= 0.5:
		buffer = 0.6
	else:
		buffer = 0.8
	
	var offset_x = (ratio - 0.5)*1920*buffer
	player_board.position = Vector2(attack_positions[0].x + offset_x, attack_positions[0].y)
	attack_zone.position = Vector2(attack_positions[1].x + offset_x, attack_positions[1].y)

func hide_battle_zones():
	player_board.hide()
	attack_zone.hide()

func hide_draft_zone():
	draft_zone.hide()

func show_draft_zone():
	draft_zone.show()

func hide_play_zone():
	play_zone.hide()
func show_play_zone():
	play_zone.show()
	
func hide_bin_zone():
	bin_zone.hide()
func show_bin_zone():
	bin_zone.show()
	
func hide_the_stack_zone():
	the_stack_zone.hide()
func show_the_stack_zone():
	the_stack_zone.show()

func hide_resource_zone():
	resource_selection_zone.hide()
	
func show_resource_zone():
	resource_selection_zone.show()
