extends Node3D

signal inspect_card(card_resource)
signal card_released_from_hand(card)
@export var is_player := true
@export_node_path var deck_path
@onready var deck := get_node(deck_path)

@export_node_path var camera_path
@onready var camera := get_node(camera_path)

@export var spread_curve: Curve
@export var height_curve: Curve
@export var rotation_curve: Curve
@export var width_curve: Curve
@export var width_array: Array[float]

@onready var rest_position = position
var tuck_position := Vector3(0, 0.5, 1.8)


func _ready():
	if get_parent().name == "Opponent":
		is_player = false
		draw_hand()

# Called when the node enters the scene tree for the first time.
func get_cards_in_hand():
	var cards_in_hand = []
	for child in get_children():
		# Check if the child has the 'phantom' property and it's not true
		if not child.phantom:
			cards_in_hand.append(child)
	return cards_in_hand
	
func phantom_cards_in_hand():
	for child in get_children():
		# Check if the child has the 'phantom' property and it's not true
		if child.phantom:
			return true
	return false

func get_extra_cards_displayed_in_hand():
	var extra_cards = []
	for child in get_children():
		# Check if the child has the 'phantom' property and it's not true
		if child.phantom:
			extra_cards.append(child)
	return extra_cards
	
func get_hand_index(card):
	if card.phantom:
		var cards = get_extra_cards_displayed_in_hand()
		# Sort the children by their Z position
		cards.sort_custom(func(a, b):
			return a.global_transform.origin.x < b.global_transform.origin.x
			)
		# Find the index of the target_child
		for i in range(cards.size()):
			if cards[i] == card:
				return i + get_cards_in_hand().size()
	else:
			
		var cards = get_cards_in_hand()
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
		if card.is_in_hand() and card.hovered and !card.draggable:
			# card hovered
			card.rotation.z = lerp(card.rotation.z, 0.0, card.ANIM_SPEED * delta)
			var view_spot = card.target_transform 
			view_spot.origin = card.find_camera_pos()
			view_spot.origin.z -= 0.05
			card.transform = card.transform.interpolate_with(view_spot, card.ANIM_SPEED * delta)
		elif !card.draggable and !card.played:
			card.transform = card.transform.interpolate_with(card.target_transform, card.ANIM_SPEED * delta)
			card.rotation.z = lerp(rotation.z, card.target_rotation, card.ANIM_SPEED * delta)
		elif card.is_in_hand() and card.draggable:
			var mouse_pos = get_viewport().get_mouse_position()
			var cam = get_viewport().get_camera_3d()
			var origin = cam.project_ray_origin(mouse_pos)
			var normal = cam.project_ray_normal(mouse_pos)
			var ray_length = (card.position.y-cam.position.y)/normal.y
			var end = origin + normal * ray_length
			card.position = end
			var index = card.get_index()
			var new_index = get_hand_index(card)
			#print("Idex", index)
			#print("New Idex", new_index)
			if index != new_index:
				card.draw_audio.play()
				move_to_new_index(card, new_index)
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
	total_weight -= float(weights[0])/2.0
	total_weight -= float(weights[-1])/2.0
	
	
	for weight in weights:
		cumulative_weight.append(weight/(total_weight))
	
	
	# Step 2: Calculate normalized cumulative weights
	var normalized_position = 0
	for i in range(weights.size()-1):
		var distance = (cumulative_weight[i] + cumulative_weight[i+1])/2.0
		normalized_position += distance
		
		# Leave an empty position between the cards and the phantom cards
		if phantom_cards_in_hand():
			if i != get_cards_in_hand().size() -1:
				positions.append(normalized_position)
		else:
			positions.append(normalized_position)
	
		
	# Adjusting positions to start from 0 and end at 1
	#var offset = positions[0]
	#for i in range(positions.size()):
		#positions[i] = (positions[i] - offset) / (1 - offset)

	return [positions, total_weight]


func get_hand_ratios(cards):
	if cards.size() <= 1:
		return {'hand_ratio':[0.5], 'max_width': 0}
	
		
	var weight = []
	if phantom_cards_in_hand():
		# There are phantom cards and we need a gap
		weight.resize(cards.size()+1)
	else:
		weight.resize(cards.size())
	weight.fill(1)
	var hovered_weight = 0.5
	#var neighbor_weight = 0.5
	var i = 0
	for card in get_cards_in_hand():
		if card.hovered == true or card.draggable:
			weight[i] += hovered_weight
			#if i>0:
				#weight[i-1] += neighbor_weight
			#if i+1<cards.size():
				#weight[i+1] += neighbor_weight
		i += 1
	if phantom_cards_in_hand():
		i += 1
		for card in get_extra_cards_displayed_in_hand():
			if card.hovered == true or card.draggable:
				weight[i] += hovered_weight
			# There are phantom cards and we need a gap
			
	var returned = distribute_points(weight)
	var hand_ratio = returned[0]
	#var total_weight = returned[1]
	#print(total_weight)
	var max_width 
	if get_child_count() >= width_array.size():
		max_width = width_array.back()
	else:
		max_width = width_array[get_child_count()]
	if phantom_cards_in_hand():
		max_width *= 1.5
	#var max_width = width_curve.sample(float(cards.size())/7.0)
	return {'hand_ratio':hand_ratio, 'max_width': max_width}

func get_hand_ratio(card):
	var hand_ratio = 0.5
	if get_child_count()>1:
		hand_ratio = float(card.get_index())/float(get_child_count()-1)
	return hand_ratio
	
	
func draw_card() -> Node:
	if deck.card_count() == 0:
		return null
	var top_card = deck.top_card()
	var cache_transform = top_card.transform
	top_card.get_parent().remove_child(top_card)
	add_child(top_card)
	#print(get_child_count())
	top_card.transform = cache_transform
	top_card.draw_sound()
	top_card.active = true
	
	return top_card	

func inspection(card_resource) -> void:
	inspect_card.emit(card_resource)
	
	
func sort_hand() -> void:
	var cards = get_children()
	var result = get_hand_ratios(cards)
	var hand_ratios = result['hand_ratio']
	var max_width = result['max_width']
	var i=0
	for card in cards:
		var destination := global_transform
		if is_player:
			destination.basis = camera.global_transform.basis
			destination.origin.x += spread_curve.sample(hand_ratios[i]) * max_width
			#destination.origin.y += height_curve.sample(hand_ratio) * 2
			
			card.target_rotation = rotation_curve.sample(hand_ratios[i]) * 0.3
			destination.origin += camera.basis * Vector3.UP * height_curve.sample(hand_ratios[i]) * 0.5
			destination.origin += camera.basis * Vector3.BACK * hand_ratios[i] * 0.1

		else:
			# enemy hand orientation
			destination.basis = global_transform.basis
			
			var rot_degrees = 90  # Rotation in degrees
			var rot_radians = deg_to_rad(rot_degrees) 
			destination.basis = Basis(Vector3(1, 0, 0), rot_radians) # Convert degrees to radians
			
			destination.origin.x += spread_curve.sample(hand_ratios[i]) * max_width
			#destination.origin.y = 5.5
			destination.origin.z = -5.0
			destination.origin += camera.basis * Vector3.UP * height_curve.sample(hand_ratios[i]) * 0.5
			destination.origin.y += hand_ratios[i] * 0.01
			print(hand_ratios[i])
			#print(destination.origin)
		card.target_transform.origin = destination.origin
		card.target_transform.basis = destination.basis
		i+=1
		
func draw_hand():
	var tween = create_tween()
	for x in 5:
		tween.tween_callback(draw_card)
		tween.tween_interval(0.2)
		


#func connect_card_double_click(card):
	#card.card_selected.connect(self.clicked_card)
	##print("Added Card Signal")
#
#func remove_card_double_click(card):
	#if card.card_selected.is_connected(self.play_card):
		#card.card_selected.disconnect(self.play_card)
func card_played(card):
	card.move_node(self)

func card_released(card):
	card.scale = Vector3.ONE
	card.outline.visible = false
	card.draggable = false
	card.hovered = false

func card_clicked(card):
	card.outline.visible = true
	card.draggable = true

func card_hovered(card):
	if is_player:
		card.hovered = true
		sort_hand()
		card.scale = Vector3.ONE * 1.1
		

func card_not_hovered_anymore(card):
	if !card.draggable and !card.played:
		card.outline.visible = false
		card.hovered = false
		sort_hand()
		scale = Vector3.ONE 

func connect_card_signals(card):
	card.card_clicked.connect(self.card_clicked)
	card.card_released.connect(self.card_released)
	card.card_hovered.connect(self.card_hovered)
	card.card_not_hovered_anymore.connect(self.card_not_hovered_anymore)


func remove_card_signals(card):
	if card.card_not_hovered_anymore.is_connected(self.card_not_hovered_anymore):
		card.card_not_hovered_anymore.disconnect(self.card_not_hovered_anymore)
	
	if card.card_hovered.is_connected(self.card_hovered):
		card.card_hovered.disconnect(self.card_hovered)
	
	if card.card_clicked.is_connected(self.card_clicked):
		card.card_clicked.disconnect(self.card_clicked)
	
	if card.card_released.is_connected(self.card_released):
		card.card_released.disconnect(self.card_released)

func _on_child_order_changed():
	sort_hand()

func _on_child_exiting_tree(node):
	if is_player:
		remove_card_signals(node)
	sort_hand()
	
func _on_child_entered_tree(node):
	if not node.is_inside_tree():
		await ready
	if node.token:
		node.queue_free()
	else:
		var index = get_hand_index(node)
		if index != node.get_index():
			move_to_new_index(node, index)
		if is_player:
			connect_card_signals(node)
		node.update_counters_on_card(0)
		call_deferred("sort_hand")
