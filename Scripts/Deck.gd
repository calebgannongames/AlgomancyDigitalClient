extends Node3D
@export_node_path var board
@export var is_player := true

@export var deck_path: String
@onready var json_deck =  deck_path
var deck
var card = preload("res://card.tscn")

#var deck = load("res://StartingDeck.tres").duplicate(true).deck

func _ready() -> void:
	var file = FileAccess.open(deck_path, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		var json = JSON.new()
		json.parse(json_text)
		deck = json.data
		file.close()
	#We run this 5x to get more cards in deck for now
	var counter = 0
	for card_resource in deck:
		var c = card.instantiate()
		c.setup_card(deck[card_resource][0])
		add_child(c)
		c.is_player = is_player
		counter += 1
		if counter > 30:
			break
		#c.board = board
			
		
		#c.play_card.connect(get_parent().play_card)
		
		
func top_card() -> Card:
	return get_children().back()


func card_count() -> int:
	return get_child_count()
	
	



func _on_child_entered_tree(node):
	if not node.is_inside_tree():
		await ready
	if node.token:
		node.queue_free()
	else:
		#print("Recycled Card")
		var destination := global_transform
		destination.origin += Vector3.UP * node.get_index() * 0.02
		node.global_transform = destination
		node.target_transform = destination
		#node.position = destination.origin
		node.target_rotation = deg_to_rad(randf_range(-4.0, 4.0))
