extends Node3D

var starting_prismites = 2
var start_active = true
var prismite_card_number = 5
var Card = preload("res://card.tscn")
var resource_deck = load("res://ResourceDeck.tres").duplicate(true).deck

func _ready():
	var card_resource = resource_deck[prismite_card_number]
	for i in starting_prismites:
		deal_card(card_resource)
	
# Called when the node enters the scene tree for the first time.

func add_resource(new_resource):
	var clone = new_resource.duplicate()
	# Now add the clone to the scene tree
	clone.position.x = -40
	clone.phantom = true
	add_child(clone)

func deal_card(card_resource) -> void:
	var c = Card.instantiate()
	c.setup_resource(card_resource)
	c.is_player = true
	add_child(c)
	c.position.x = 20

func make_resources_visible_in_hand():
	for card in get_children():
		if card.card_name.text == "Prismite":
			card.scale = Vector3.ONE
			card.outline.visible = false
			card.draggable = false
			card.hovered = false
			card.phantom = true
			card.phantom_outline.visible = true
			var hand = get_parent().hand
			card.move_node(hand)
			card.Title_box.hide()
			card.type_box.hide()
			card.card_type.hide()
			card.ability_box.hide()
			card.Timing_box.hide()


func remove_resources_from_hand():
	var hand = get_parent().hand
	for card in hand.get_children():
		#print(card.phantom)
		if card.phantom:
			card.scale = Vector3.ONE
			card.outline.visible = false
			card.draggable = false
			card.hovered = false
			card.phantom = false
			card.phantom_outline.visible = false
			card.position.x = 20
			card.move_node(self)
