extends Node3D
@export_node_path var deck_path
@onready var deck := get_node(deck_path)

var pack_size = 10

func deal_card() -> Node:
	if deck.card_count() == 0:
		return null
	var top_card = deck.top_card()
	var cache_transform = top_card.transform
	top_card.get_parent().remove_child(top_card)
	add_child(top_card)
	#print(get_child_count())
	top_card.transform = cache_transform
	top_card.active = true
	return top_card	

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in pack_size:
		deal_card()

