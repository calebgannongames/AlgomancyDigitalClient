extends Node3D

var deployment = false

func _on_child_entered_tree(node):
	if not node.is_inside_tree():
		await ready
	if node.token:
		node.queue_free()
	else:	
		node.update_counters_on_card(0)
		call_deferred("put_in_bin")
		
		

func card_played(card):
	card.move_node(self)
	
func put_in_bin():
	var units = get_children()
	for unit in units:
		var index = unit.get_index()
		unit.position = Vector3(self.position.x, 0.02*(index+1), self.position.z)
		unit.rotation = self.rotation
	
	if deployment:
			make_mods_visible_in_hand()

func show_mod_timing(card):
	card.Mod_Timing_box.show()
	#
	card.Timing_box.hide()
	
func hide_mod_timing(card):
	card.Mod_Timing_box.hide()
	if card.timing != null:
		card.Timing_box.show()
	
func make_mods_visible_in_hand():
	for card in get_children():
		if card.mod_timing != null:
			card.scale = Vector3.ONE
			card.outline.visible = false
			card.draggable = false
			card.hovered = false
			show_mod_timing(card)
			card.phantom = true
			card.phantom_outline.visible = true
			var hand = get_parent().hand
			card.move_node(hand)
			#card.Title_box.hide()
			#card.type_box.hide()
			#card.card_type.hide()
			#card.ability_box.hide()
			card.Timing_box.hide()


func remove_mods_from_hand():
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
			hide_mod_timing(card)
			card.move_node(self)
	deployment = false
