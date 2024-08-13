extends Node3D

@onready var main = get_parent()
var unit_zones = {}

var max_width = 8
func _ready():
	call_deferred("connect_unit_location_triggers")
	
func get_unit_zones():
	var player = main.Player
	var opponent = main.Opponent
	unit_zones['Player_Region'] = {}
	unit_zones['Opponent_Region'] = {}
	unit_zones['Player_Region']['Attack'] = opponent.attack_formation
	unit_zones['Player_Region']['Block'] = player.block_formation
	unit_zones['Player_Region']['Board'] = player.board
	unit_zones['Player_Region']['Away_Board'] = opponent.away_board
	
	unit_zones['Opponent_Region']['Attack'] = player.attack_formation
	unit_zones['Opponent_Region']['Away_Board'] = player.away_board
	unit_zones['Opponent_Region']['Block'] = opponent.block_formation
	unit_zones['Opponent_Region']['Board'] = opponent.board
	
	
func connect_unit_location_triggers():
	get_unit_zones()
	var player_region_zones = unit_zones['Player_Region']
	var opponent_region_zones = unit_zones['Opponent_Region']
	
	for zone in player_region_zones.keys():
		player_region_zones[zone].formation_changed.connect(count_active_zone_dimensions)
	
	for zone in opponent_region_zones.keys():
		opponent_region_zones[zone].formation_changed.connect(count_active_zone_dimensions)
	
	
	#player.attack_formation.formation_changed.connect(count_active_zone_dimensions)
	#player.block_formation.formation_changed.connect(count_active_zone_dimensions)
	#player.board.formation_changed.connect(count_active_zone_dimensions)
	#
	#opponent.attack_formation.formation_changed.connect(count_active_zone_dimensions)
	#opponent.block_formation.formation_changed.connect(count_active_zone_dimensions)
	#opponent.board.formation_changed.connect(count_active_zone_dimensions)
	
	
		
func hide_attack_button():
	disable_and_hide_node(main.UI.get_node("Control/Attack_All"), true)

func show_attack_button():
	enable_and_show_node(main.UI.get_node("Control/Attack_All"))

func move_units_home():
	var attackers = main.Player.attack_formation.get_children()
	for attacker in attackers:
		attacker.move_node(main.Player.board)
	var blockers = main.Player.block_formation.get_children()
	for blocker in blockers:
		blocker.move_node(main.Player.board)
	var away_boards = main.Player.away_board.get_children()
	for away_unit in away_boards:
		away_unit.move_node(main.Player.board)
		
	var opponents_attackers = main.Opponent.attack_formation.get_children()
	for attacker in opponents_attackers:
		attacker.move_node(main.Opponent.board)
		
	var opponents_blockers = main.Opponent.block_formation.get_children()
	for blocker in opponents_blockers:
		blocker.move_node(main.Opponent.board)

	var opponent_away_boards = main.Opponent.away_board.get_children()
	for away_unit in opponent_away_boards:
		away_unit.move_node(main.Opponent.board)

func move_zones_for_attack():
	
	main.Player.attack_formation.screen_location = Vector2(5, -2.5)
	main.Player.block_formation.screen_location = Vector2(-5, -2.5)
	main.Player.board.screen_location = Vector2(-5, 1.5)
	main.Player.away_board.screen_location = Vector2(5, 1.5)
	
	main.Opponent.attack_formation.screen_location = Vector2(-5, -4.5)
	main.Opponent.block_formation.screen_location = Vector2(20, -4.5)
	main.Opponent.board.screen_location = Vector2(5, -9)
	main.Opponent.away_board.screen_location = Vector2(-5, -9)
	
func move_zones_for_offense():
	main.Player.attack_formation.screen_location = Vector2(0, -2.5)
	main.Player.away_board.screen_location = Vector2(0, 1.5)
	main.Player.board.screen_location = Vector2(-20, 0)
	main.Player.block_formation.screen_location = Vector2(-20, 0)
	
	main.Opponent.attack_formation.screen_location = Vector2(-20, -3.5)
	main.Opponent.block_formation.screen_location = Vector2(0, -4.5)
	main.Opponent.board.screen_location = Vector2(0, -9)
	main.Opponent.away_board.screen_location = Vector2(-20, -9)

func move_zones_for_defense():
	main.Player.attack_formation.screen_location = Vector2(20, -3)
	main.Player.away_board.screen_location = Vector2(20, 1.5)
	main.Player.board.screen_location = Vector2(0, 1.5)
	main.Player.block_formation.screen_location = Vector2(0, -2.5)
	
	main.Opponent.attack_formation.screen_location = Vector2(0, -4.5)
	main.Opponent.block_formation.screen_location = Vector2(20, -3.5)
	main.Opponent.board.screen_location = Vector2(20, -5.5)
	main.Opponent.away_board.screen_location = Vector2(0, -5.5)

func reset_zone_positions():
	main.Player.attack_formation.screen_location = Vector2(20, -3)
	main.Player.board.screen_location = Vector2(0, 0)
	main.Player.block_formation.screen_location = Vector2(-20, 0)
	main.Player.away_board.screen_location = Vector2(20, 1.5)
	
	main.Opponent.attack_formation.screen_location = Vector2(-20, -3.5)
	main.Opponent.block_formation.screen_location = Vector2(20, -5.5)
	main.Opponent.board.screen_location = Vector2(0, -6.5)
	main.Opponent.away_board.screen_location = Vector2(20, -6.5)

func count_enemy_zone_dimensions():
	var enemy_zone_nodes = {
		"Formations": [main.Player.attack_formation,
		main.Opponent.block_formation,
		],
		"Out of Formations": [
			main.Opponent.board,
			main.Player.away_board,
		]
	}
	
	var dimensions = calculate_zone_dimensions(enemy_zone_nodes['Formations'], enemy_zone_nodes['Out of Formations'])
	return dimensions

func formation_has_back_row(arr: Array) -> bool:
	for element in arr:
		if element.size() > 1:
			return true  # Found a nested array
	return false  # No nested arrays found

func replace_width_if_larger(width, value):
	if value > width:
		return value
	return width
	
func calculate_zone_dimensions(formations, out_of_formations):
	# Count the height and width in terms of number of units
	# Width is the maximum value across all the formations
	var height = 0
	var width = 0
	for formation_node in formations:
		if !formation_node.formation.is_empty():
			var formation_width = formation_node.formation.size()
			width = replace_width_if_larger(width, formation_width)
			if formation_has_back_row(formation_node.formation):
				height += 2
			else:
				height += 1

	for non_formation_node in out_of_formations:
		var num_units_in_board = non_formation_node.get_width()
		if num_units_in_board > 0:
			height += 1
			width = replace_width_if_larger(width, num_units_in_board)
	
	return Vector2(width, height)
	
func count_home_zone_dimensions():
	var home_zone_nodes = {
		"Formations": [main.Player.block_formation,
		main.Opponent.attack_formation,
		],
		"Out of Formations": [
			main.Player.board,
			main.Opponent.away_board
		]
	}
	
	var dimensions = calculate_zone_dimensions(home_zone_nodes['Formations'], home_zone_nodes['Out of Formations'])
	return dimensions
	
func set_unit_scale(scale):
	var player_zones = unit_zones['Player_Region']
	var opponent_zones = unit_zones['Opponent_Region']
	
	for zone in player_zones.keys():
		player_zones[zone].card_scale = scale
	
	for zone in opponent_zones.keys():
		opponent_zones[zone].card_scale = scale


func resize_regions(total_width):
	
	var new_scale
	if total_width > max_width:
		new_scale = max_width/total_width
	else:
		new_scale = 1
	#print("Units scaled to: ", new_scale)
	set_unit_scale(new_scale)


func resize_regions_during_declare_attacks(left, right):
	var total_width = left.x + right.x
	if total_width > 0:
		var left_ratio = left.x/total_width
		main.Player.divider_bar.set_bar_position_during_attacks_by_ratio(left_ratio)
		
		var player_region_zones = unit_zones['Player_Region']
		var opponent_region_zones = unit_zones['Opponent_Region']
		
		for zone in player_region_zones.keys():
			player_region_zones[zone].screen_location.x = -10 + left_ratio/2*20
		
		for zone in opponent_region_zones.keys():
			opponent_region_zones[zone].screen_location.x = -10 + (0.5+left_ratio/2)*20
		
		
		resize_regions(total_width)
		main.Zone_Manager.set_zones_for_attack_by_ratio(left_ratio)

	
	
func count_active_zone_dimensions():
	var dimensions
	if main.split_region:
		var left_dimensions = count_home_zone_dimensions()
		var right_dimensions = count_enemy_zone_dimensions()
		resize_regions_during_declare_attacks(left_dimensions, right_dimensions)
		
	elif main.home_region:
		dimensions = count_home_zone_dimensions()
		resize_regions(dimensions.x)

	else:
		dimensions = count_enemy_zone_dimensions()
		resize_regions(dimensions.x)
		#print("The formation is ", dimensions.x, " units wide and ", dimensions.y, " units tall.")
	

	#return dimensions

func turn_off_resources():
	disable_and_hide_node(main.Player.resources, true)
	disable_and_hide_node(main.Player.resource_selection, true)
	
func turn_on_resources():
	enable_and_show_node(main.Player.resources)
	enable_and_show_node(main.Player.resource_selection)

func turn_off_attack_zone():
	disable_and_hide_node(main.Player.attack_zone, true)
	
func turn_on_attack_zone():
	enable_and_show_node(main.Player.attack_zone)
	
func turn_off_defensive_zone():
	disable_and_hide_node(main.Player.defensive_zone, true)
	
func turn_on_defensive_zone():
	enable_and_show_node(main.Player.defensive_zone)

func turn_off_draft():
	disable_and_hide_node(main.Player.draft, true)
	
func turn_on_draft():
	enable_and_show_node(main.Player.draft)
	
func turn_off_board():
	disable_and_hide_node(main.Player.play_zone, false)
	
func turn_on_board():
	enable_and_show_node(main.Player.play_zone)

func hide_mana():
	disable_and_hide_node(main.UI.get_node("Control/Mana"), true)
	
func hide_life():
	disable_and_hide_node(main.get_node("Player/Life"), true)
	
func hide_opponent_hand():
	disable_and_hide_node(main.Opponent.hand, true)
	
func show_opponent_hand():
	enable_and_show_node(main.Opponent.hand)
	
func show_mana():
	enable_and_show_node(main.UI.get_node("Control/Mana"))
	
func show_life():
	enable_and_show_node(main.get_node("Player/Life"))

func disable_and_hide_node(node:Node, hide:bool) -> void:
	node.process_mode = 4 # = Mode: Disabled
	if hide:
		node.hide()

func enable_and_show_node(node:Node) -> void:
	node.process_mode = 0 # = Mode: Inherit
	node.show()

func deactivate_game_elements_for_special_action():
	var a=2
