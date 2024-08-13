extends Area3D

#var objects_inside = []
var imported_unit = preload("res://unit.tscn")
var inported_card = preload("res://Card.tscn")
@onready var hand = $Hand

#func is_area_inside(area):
	#return objects_inside.has(area)
func is_in_hand(card):
	return card.get_parent() == hand 

func add_card_to_zone(card):
	#card.move_node_become_unit(hand)
	#print(card.get_parent().name)
	if card.get_parent() != hand:
		card.move_node(hand)
		#print("Moved Card to hand")
	#var a = 2
	
func recall_unit_from_play(unit):
	unit.move_node(hand)

func connect_card_signal(card):
	
	card.card_released.connect(self.add_card_to_zone)
	#print("Added Hand Signal")

func remove_card_signal(card):
	if card.card_released.is_connected(self.add_card_to_zone):
		card.card_released.disconnect(self.add_card_to_zone)
		#print("Removed Hand Signal")
		
		
func check_if_area_is_card(area):
	
	var parent = area.get_parent()
	if parent is Card:
		return true
	else:
		return false


func _on_area_entered(area):
	#objects_inside.append(area)
	if check_if_area_is_card(area):
		connect_card_signal(area.get_parent())
	

func _on_area_exited(area):
	#objects_inside.erase(area)
	if check_if_area_is_card(area):
		remove_card_signal(area.get_parent())

#func _on_child_entered_tree(node):
	#if not node.is_inside_tree():
		#await ready
	#call_deferred("position_units")

