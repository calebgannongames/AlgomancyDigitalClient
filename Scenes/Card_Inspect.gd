extends Node3D
#@export_node_path var the_stack_path
#@onready var the_stack := get_node('Player/The_Stack')
var zoom = false
var hovered_card = null
func check_mouse_side_of_screen(card):
	var viewport = get_viewport()
	var mouse_pos = viewport.get_mouse_position()
	var viewport_size = viewport.size
	var mouse_location = "Right"
	var side_direction = -1
	#Get left/right position
	if mouse_pos.x <= viewport_size.x/2:
		mouse_location = "Left"
		side_direction = 1
	
	if mouse_pos.y <= viewport_size.y/2:
		mouse_location += "Top"
	elif mouse_pos.y > viewport_size.y/2:
		mouse_location += "Bottom"
	
	return mouse_location

func screen_to_world(viewport, screen_position, depth):
	var cam = viewport.get_camera_3d()
	var origin = cam.project_ray_origin(screen_position)
	var normal = cam.project_ray_normal(screen_position)
	var ray_length = (depth-cam.position.y)/normal.y
	var end = origin + normal * ray_length
	return end

func show_hover_detail(card):
	if zoom:
		var mouse_location = check_mouse_side_of_screen(card)
		var display_height = 8
		
		
		var viewport = get_viewport()
		var side_direction = 1
		if "Right" in mouse_location:
			side_direction = -1
		var top_offset = 0
		if "Top" in mouse_location:
			top_offset = 1
		elif "Bottom" in mouse_location:
			top_offset = -1
		#print(top_offset)
		var aabb = card.get_node("CardFront").get_aabb()
		var point_3d = card.position + Vector3(aabb.size.x/2*side_direction, 0, aabb.size.y*top_offset/2.5)  # Adjust for front/right/middle edge
		var camera = viewport.get_camera_3d()
		var screen_position = camera.unproject_position(point_3d)
		var world_position = screen_to_world(viewport, screen_position, display_height)
		
		card.delete_trigger_lines()
		card.delete_target_lines()
		var cloned_card = card.duplicate()
		var offset = Vector3(cloned_card.get_node("CardFront").get_aabb().size.x/2.33,0,0)
		
		if "Right" in mouse_location:
			# Set the position of the cloned card
			offset.x *= -1 
				# Set the position of the cloned card
		#print("WP:", world_position, "Offset:", offset)
		cloned_card.position = world_position + offset
		#print(cloned_card.rotation)
		cloned_card.rotation = Vector3(deg_to_rad(-80.0), 0, 0)
		cloned_card.trigger_source = card.trigger_source
		cloned_card.triggers = card.triggers
		cloned_card.targets = card.targets
		add_child(cloned_card)
		if not cloned_card.is_inside_tree():
			await ready
		cloned_card.outline.visible = false
		cloned_card.timing = card.timing
		cloned_card.cardtype = card.cardtype
		cloned_card.ability = card.ability
		cloned_card.mod_timing = null
		cloned_card.is_inspect = true
		cloned_card.transform_card("Card")
		cloned_card.draw_line_to_trigger_source()
		
		if "Right" in mouse_location:
			card.draw_line_to_triggers()
			cloned_card.draw_line_to_targets()
			
		else:
			cloned_card.draw_line_to_triggers()
			card.draw_line_to_targets()
	
	
	
func remove_hover_detail():
	for child in get_children():
		child.queue_free()


func card_hovered(card):
	hovered_card = card

func card_not_hovered(card):
	if hovered_card == card:
		hovered_card = null

func _input(event: InputEvent):
	if event.is_action_pressed("q"):
		#emit_signal("card_released", self)
		zoom = true
	elif event.is_action_released("q"):
		zoom = false

	
