extends Control

var right_click_menu = preload("res://Scenes/right_click_menu.tscn")

#func _ready():
	#get_viewport().gui_focus_changed.connect(_on_focus_changed)
#func _on_focus_changed(node):
	#if node:
		#print("Focus is now on: ", node.name)
	#else:
		#print("No control has focus.")

func remove_drop_down(menu):
	menu.hide()
	menu.queue_free()
	
	
func drop_down_menu(card):
	var mouse_pos = get_viewport().get_mouse_position()
	var menu = right_click_menu.instantiate()
	add_child(menu)
	
	var drop_down = menu.drop_down_menu
	drop_down.popup_hide.connect(remove_drop_down.bind(menu))
	menu.card = card
	#add_child(menu)
	var rect = Rect2i(mouse_pos, Vector2(150, 100))
	drop_down.popup(rect)
	accept_event()
	#drop_down.show()
	#drop_down.position = mouse_pos
	#drop_down.set_exclusive(false)
	#drop_down.input_passby = true 
	#drop_down.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	
func _input(event: InputEvent):
	if event.is_action_pressed("right_click") and CardInspect.hovered_card != null:
		if !CardInspect.hovered_card.is_on_the_stack():
			drop_down_menu(CardInspect.hovered_card)
	#if event.is_action_pressed("click"):
		#print("clicked")
		
