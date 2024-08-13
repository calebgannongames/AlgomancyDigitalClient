extends Area3D

#var objects_inside = []
@onready var board = $In_Play_Not_Formation

#func is_area_inside(area):
	#return objects_inside.has(area)

func add_card_to_zone(card):
	if card.get_parent() != board:
		card.move_node(board)
		#print("Move Card to board")
	#var a=2

func connect_card_signal(card):
	card.card_released.connect(self.add_card_to_zone)
	#print("Added Card Signal")

func remove_card_signal(card):
	if card.card_released.is_connected(self.add_card_to_zone):
		card.card_released.disconnect(self.add_card_to_zone)
		#print("Removed Card Signal")
		
		
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
