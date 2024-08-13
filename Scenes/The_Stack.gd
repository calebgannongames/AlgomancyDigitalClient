extends Node3D

signal inspect_card(card_resource)
signal card_released_from_hand(card)
@export var is_player := true

@export var spread_curve: Curve
@export var height_curve: Curve
@export var rotation_curve: Curve
@export var width_curve: Curve
@export var width_array: Array[float]
@export_node_path var camera_path
@onready var camera := get_node(camera_path)
@onready var player = get_parent()
@onready var rest_position = position
var tuck_position := Vector3(0, 0.5, 1.8)


func resolve_top_card():
	var top_card = get_children()[-1]
	resolve_card(top_card)

func resolve_unit(card):
	var active_board = player.active_board
	card.move_node(active_board)

func resolve_effect(card):
	var bin = player.bin
	card.move_node(bin)
	
func resolve_card(card):
	if card.is_unit and !card.phantom:
		resolve_unit(card)
	else:
		resolve_effect(card)

func is_empty():
	return get_child_count() == 0

# Called when the node enters the scene tree for the first time.
	
func get_hand_index(card):

			
	var cards = get_children()
	# Sort the children by their Z position
	cards.sort_custom(func(a, b):
		return a.global_transform.origin.x < b.global_transform.origin.x
		)
	# Find the index of the target_child
	for i in range(cards.size()):
		if cards[i] == card:
			return i

func move_to_new_index(card, new_index: int):
	move_child(card, new_index)
	#move_child(card, 1)
	

func _process(delta):
	
	for card in get_children():
		if card.hovered and !card.target_select:
			# card hovered
			#card.rotation.z = lerp(rotation.z, card.target_rotation, card.ANIM_SPEED * delta)
			var view_spot = card.target_transform 
			#view_spot.origin.x -= 0.7
			##view_spot.origin.y += 0.5
			card.transform = card.transform.interpolate_with(view_spot, card.ANIM_SPEED * delta)
		
			#if card.trigger_source != null:
				#card.draw_line_to_trigger_source()
		elif !card.target_select and !card.played:
			card.transform = card.transform.interpolate_with(card.target_transform, card.ANIM_SPEED * delta)
			#card.rotation.z = lerp(rotation.z, card.target_rotation, card.ANIM_SPEED * delta)
		elif card.target_select:
			card.draw_target_line_to_mouse()
			
		#elif card.is_in_hand() and card.draggable:
			#var mouse_pos = get_viewport().get_mouse_position()
			#var cam = get_viewport().get_camera_3d()
			#var origin = cam.project_ray_origin(mouse_pos)
			#var normal = cam.project_ray_normal(mouse_pos)
			#var ray_length = (card.position.y-cam.position.y)/normal.y
			#var end = origin + normal * ray_length
			#card.position = end
			#var index = card.get_index()
			#var new_index = get_hand_index(card)
			##print("Idex", index)
			##print("New Idex", new_index)
			#if index != new_index:
				#card.draw_audio.play()
				#move_to_new_index(card, new_index)
				#reorder_hand()
	#sort_hand()
func play_card(card):
	card.played = true
	card.scale = Vector3.ONE
	card.outline.visible = false
	card.draggable = false
	card.hovered = false
	#print("Hand Played Card Trigger")
	emit_signal("card_released_from_hand", card)

func distribute_points(weights: Array) -> Array:
	var total_weight = 0.0
	var positions = [0]
	var cumulative_weight = []

	# Step 1: Calculate total weight
	for weight in weights:
		total_weight += weight
	#total_weight -= float(weights[0])/2.0
	total_weight -= float(weights[-1])
	
	
	for weight in weights:
		cumulative_weight.append(weight/(total_weight))
	
	
	# Step 2: Calculate normalized cumulative weights
	var normalized_position = 0.0
	for i in range(weights.size()-1):
		var distance = (cumulative_weight[i])
		normalized_position += distance
		
		
		positions.append(normalized_position)
	

	# Adjusting positions to start from 0 and end at 1
	var offset = positions[0]
	for i in range(positions.size()):
		positions[i] = (positions[i] - offset) / (1 - offset)

	return [positions, total_weight]


func get_hand_ratios(cards):
	if cards.size() <= 1:
		return {'hand_ratio':[0.5], 'max_width': 0}
	
		
	var weight = []
	
	weight.resize(cards.size())
	weight.fill(1)
	var hovered_weight = 1.5
	#var neighbor_weight = 0.5
	var card_is_hovered = false
	var i = 0
	for card in get_children():
		if card.hovered == true or card.draggable:
			weight[i] += hovered_weight
			card_is_hovered = true
			#if i>0:
				#weight[i-1] += neighbor_weight
			#if i+1<cards.size():
				#weight[i+1] += neighbor_weight
		i += 1
	
	var returned = distribute_points(weight)
	var hand_ratio = returned[0]
	#var total_weight = returned[1]
	#print(total_weight)
	var max_width 
	if get_child_count() >= width_array.size():
		max_width = width_array.back()
	else:
		max_width = width_array[get_child_count()]
	if card_is_hovered:
		max_width*=1.5
	#var max_width = width_curve.sample(float(cards.size())/7.0)
	return {'hand_ratio':hand_ratio, 'max_width': max_width}

func get_hand_ratio(card):
	var hand_ratio = 0.5
	if get_child_count()>1:
		hand_ratio = float(card.get_index())/float(get_child_count()-1)
	return hand_ratio
	


func inspection(card_resource) -> void:
	inspect_card.emit(card_resource)
	
	
func sort_hand() -> void:
	var cards = get_children()
	var result = get_hand_ratios(cards)
	var hand_ratios = result['hand_ratio']
	var max_width = result['max_width']
	var i=0
	for card in cards:
		var destination = global_transform
		if is_player:
			destination.basis = camera.global_transform.basis
			destination.origin += camera.basis * Vector3.UP* (1-2*hand_ratios[i]) * max_width/2 
			#destination.origin.y += height_curve.sample(hand_ratio) * 2
			
			#card.target_rotation = rotation_curve.sample(hand_ratios[i]) * 0.3
			#destination.origin -= camera.basis * Vector3.LEFT * height_curve.sample(hand_ratios[i]) * 0.25 * max_width/2
			destination.origin.x -= hand_ratios[i] * 0.05
			destination.origin += camera.basis * Vector3.BACK * hand_ratios[i] * 0.05
			
		else:
			# enemy hand orientation
			destination.basis = global_transform.basis
			destination.origin.x += spread_curve.sample(hand_ratios[i]) * max_width
			destination.origin += global_transform.basis * Vector3.UP * height_curve.sample(hand_ratios[i]) * 0.5

		card.target_transform.origin = destination.origin
		card.target_transform.basis = destination.basis
		i+=1
		
		

#func connect_card_double_click(card):
	#card.card_selected.connect(self.clicked_card)
	##print("Added Card Signal")



#func update_line(line, curve):
	#line.points.clear()
	#var segments = 20
	#var length = curve.get_baked_length()
	#var spacing = length / segments
	#
	## Generate points along the curve
	#for i in range(segments + 1):
		#var t = i * spacing
		#var point = curve.interpolate_baked(t)
		#line.points.append(point)

#func remove_card_double_click(card):
	#if card.card_selected.is_connected(self.play_card):
		#card.card_selected.disconnect(self.play_card)
func assign_targets(card):
	card.target_select = false
	
	if CardInspect.hovered_card != null:
		print("Assign Targets to: ", CardInspect.hovered_card)
		card.targets.append(CardInspect.hovered_card)
	else:
		print("No target chosen")
	card.remove_target_line()
func card_played(card):
	card.move_node(self)

func card_released(card):
	card.scale = Vector3.ONE
	card.outline.visible = false
	card.draggable = false
	card.hovered = false


func card_right_click_released(card):
	if card.target_select:
		assign_targets(card)

func card_right_clicked(card):
	print("Card Right Clicked")
	card.outline.visible = true
	card.target_select = true
	#card.initialize_target_line()
		
func card_clicked(card):
	card.outline.visible = true
	card.draggable = true

func card_hovered(card):
	if !card.played :
		card.hovered = true
		sort_hand()
		card.outline.show()
		card.draw_line_to_trigger_source()
		card.draw_line_to_targets()
		#card.scale = Vector3.ONE * 1.01
		

func card_not_hovered_anymore(card):
	if !card.draggable and !card.played:
		card.outline.visible = false
		card.hovered = false
		sort_hand()
		scale = Vector3.ONE
	card.remove_trigger_source_outlines()
	card.remove_target_outlines()
	card.delete_trigger_lines()
	if !card.target_select:
		card.delete_target_lines()
	
		#var line = card.trigger_origin_show_curve
		#line.hide()

func connect_card_signals(card):
	card.card_clicked.connect(self.card_clicked)
	card.card_released.connect(self.card_released)
	card.card_hovered.connect(self.card_hovered)
	card.card_not_hovered_anymore.connect(self.card_not_hovered_anymore)
	card.card_right_clicked.connect(self.card_right_clicked)
	card.card_right_click_released.connect(self.card_right_click_released)

func remove_card_signals(card):
	if card.card_not_hovered_anymore.is_connected(self.card_not_hovered_anymore):
		card.card_not_hovered_anymore.disconnect(self.card_not_hovered_anymore)
	
	if card.card_hovered.is_connected(self.card_hovered):
		card.card_hovered.disconnect(self.card_hovered)
	
	if card.card_clicked.is_connected(self.card_clicked):
		card.card_clicked.disconnect(self.card_clicked)
	
	if card.card_released.is_connected(self.card_released):
		card.card_released.disconnect(self.card_released)
	
	if card.card_right_clicked.is_connected(self.card_right_clicked):
		card.card_right_clicked.disconnect(self.card_right_clicked)
	
	if card.card_right_click_released.is_connected(self.card_right_click_released):
		card.card_right_click_released.disconnect(self.card_right_click_released)

func remove_triggers_and_targets(card):
	card.triggers = []
	card.targets = []
	card.trigger_source = null

func _on_child_order_changed():
	sort_hand()

func _on_child_exiting_tree(node):
	remove_card_signals(node)
	remove_triggers_and_targets(node)
	sort_hand()
	
func _on_child_entered_tree(node):
	if not node.is_inside_tree():
		await ready
	#var index = get_hand_index(node)
	#if index != node.get_index():
		#move_to_new_index(node, index)
	
	connect_card_signals(node)
	call_deferred("sort_hand")
