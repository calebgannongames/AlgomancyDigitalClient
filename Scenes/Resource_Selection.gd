extends Node3D

var draft_height = 6
var ANIM_SPEED = 12.0

var pack_size = 10
var starting_pack_size = 14
var draft_grid = Vector2(6, 2)

@export_node_path var deck_path
@onready var deck := get_node(deck_path)

@export_node_path var player_path
@onready var Player := get_node(player_path)
var Card = preload("res://card.tscn")
var resource_deck = load("res://ResourceDeck.tres").duplicate(true).deck
var num_deal = 6
func is_odd(number):
	return number % 2 == 1

func get_resources():
	for i in num_deal:
		var card_resource = resource_deck[i]
		deal_card(card_resource)
	position_units()

func position_units():
	var units = get_children()
	#print(units.size())
	draft_grid[0] = 6
	var leftover = 0
	var counter = 0
	var max_width = Vector2(12 * draft_grid[0]/8, 12 * leftover/8)
	var max_height = 6
	var xspacing = 1.5
	var yspacing = 2.0
	#var spacing = Vector2(5.5, 8.5)
	for unit in units:
		var i = counter / int(draft_grid[0])
		var j = counter % int(draft_grid[0])
		## We flip the direction of odd rows to make cards move less when switching between rows
		if is_odd(i):
			j = leftover - j-1
		# Position each card in a grid pattern
		var target_translation = Vector3(
			j * xspacing - (max_width[i] / 2.0) + 0.75,  # Adjust for even distribution
			draft_height,
			i * yspacing - (max_height / 2.0) + 1 + yspacing/2   # Adjust for even distribution
		)
		
		units[counter].target_transform.origin = target_translation

		var rot_degrees = -90  # Rotation in degrees
		var rot_radians = deg_to_rad(rot_degrees) 
		units[counter].target_transform.basis = Basis(Vector3(1, 0, 0), rot_radians) # Convert degrees to radians
		counter += 1

func _process(delta):
	position_units()
	for unit in get_children():
		unit.transform = unit.transform.interpolate_with(unit.target_transform, ANIM_SPEED * delta)

func deal_card(card_resource) -> void:
	var c = Card.instantiate()
	c.setup_resource(card_resource)
	add_child(c)

# Called when the node enters the scene tree for the first time.
func _ready():
	get_resources()

func draft_card(card):
	if card.get_parent() == self:
		card.scale = Vector3.ONE
		card.outline.visible = false
		card.draggable = false
		card.hovered = false
		var hand = get_parent().get_parent().hand
		card.move_node(hand)
		#print("Move Card to board")
	#var a=2

func calculate_sq_distance(a, b):
	return (a.position.x-b.position.x)**2 + (a.position.z + b.position.z)**2

func find_nearest_resource(card):
	var distance = 99999
	var resources = get_children()
	var closest = resources[0]
	for resource in resources:
		var new_distance = calculate_sq_distance(card, resource)
		
		if new_distance < distance:
			distance = new_distance
			closest = resource
	#if closest == -1:
		#print("Could not find a resource")
	return closest

func get_selected_resource(card):
	var nearest_resource = find_nearest_resource(card)
	var resource_type = nearest_resource.card_name.text
	
	if Player.activated_resources < Player.resource_activations:
		Player.resources.add_resource(nearest_resource)
		if !card.phantom:
			Player.give_player_resource(resource_type)
			card.position.x = -20
			card.move_node(deck)
		elif card.phantom:
			Player.trade_prismite_for_resource(resource_type)
			card.queue_free()
	elif card.phantom:
		Player.trade_prismite_for_resource(resource_type)
		card.queue_free()
	else:
		print("You have used your resource activations this turn")


func move_to_new_index(unit, new_index: int):
	move_child(unit, new_index)

#func card_released(card):
	#card.scale = Vector3.ONE
	#card.outline.visible = false
	#card.draggable = false
	#card.hovered = false

func card_played(card):
	get_selected_resource(card)

func card_clicked(card):
	card.outline.visible = true
	card.draggable = true

func card_hovered(card):
	#print("Resource Hovered")
	card.outline.visible = true

func card_not_hovered_anymore(card):
	card.outline.visible = false

func connect_card_signals(card):
	#card.card_clicked.connect(self.card_clicked)
	card.card_released.connect(self.get_selected_resource)
	#card.card_selected.connect(self.draft_card)
	card.card_hovered.connect(self.card_hovered)
	card.card_not_hovered_anymore.connect(self.card_not_hovered_anymore)
	#print("Added Card Signal")

func remove_card_signals(card):
	if card.card_selected.is_connected(self.draft_card):
		card.card_selected.disconnect(self.draft_card)
	if card.card_not_hovered_anymore.is_connected(self.card_not_hovered_anymore):
		card.card_not_hovered_anymore.disconnect(self.card_not_hovered_anymore)
	
	if card.card_hovered.is_connected(self.card_hovered):
		card.card_hovered.disconnect(self.card_hovered)
		
	if card.card_clicked.is_connected(self.card_clicked):
		card.card_clicked.disconnect(self.card_clicked)
	
	if card.card_released.is_connected(self.get_selected_resource):
		card.card_released.disconnect(self.get_selected_resource)

func _on_child_entered_tree(node):
	if not node.is_inside_tree():
		await ready
	#print("Index: ", node.get_index())
	#var index = get_unit_index(node)
	#
	#if index != node.get_index():
		#move_to_new_index(node, index)
	#print("Card entered")
	connect_card_signals(node)
	call_deferred("position_units")
	

func _on_child_exiting_tree(node):
	remove_card_signals(node)
