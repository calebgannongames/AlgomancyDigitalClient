extends Node3D
# Called when the node enters the scene tree for the first time.
var ANIM_SPEED = 8.0
var table_height = 0.4
var screen_location = Vector2(0, -7.5)
var card_scale = 1.0
signal formation_changed()

func get_unit_index(unit):
	var units = get_children()
	# Sort the children by their x position
	units.sort_custom(func(a, b):
		return a.global_transform.origin.x < b.global_transform.origin.x
		)
	# Find the index of the target_child
	for i in range(units.size()):
		if units[i] == unit:
			return i
	return 0

func move_to_new_index(unit, new_index: int):
	move_child(unit, new_index)
	
func preprocess(unit):
	if unit.draggable:
		var mouse_pos = get_viewport().get_mouse_position()
		var cam = get_viewport().get_camera_3d()
		var origin = cam.project_ray_origin(mouse_pos)
		var normal = cam.project_ray_normal(mouse_pos)
		# Define the plane where the unit should move (constant y)
		var plane = Plane(Vector3(0, 1, 0), -2*unit.position.y)
		# Calculate the intersection point of the ray with the plane
		var intersection = plane.intersects_ray(origin, normal)
		#var ray_length = (unit.position.y-cam.position.y)/normal.y
		#var end = origin + normal * ray_length
		unit.position.x = intersection.x
		unit.position.z = intersection.z
		var index = unit.get_index()
		var new_index = get_unit_index(unit)
		if index != new_index:
			move_to_new_index(unit, new_index)
			

func _process(delta: float) -> void:

	for unit in get_children():
		preprocess(unit)
	position_units()
	for unit in get_children():
		unit.transform = unit.transform.interpolate_with(unit.target_transform, ANIM_SPEED * delta)
	
func get_units():
	var units = []
	for child in get_children():
		if !child.is_spell_token:
			units.append(child)
	return units
func get_spell_tokens():
	var spells = []
	for child in get_children():
		if child.is_spell_token:
			spells.append(child)
	return spells
			
			
			
func get_width():
	var spells =  get_spell_tokens()
	if spells.size() > 0:
		return get_child_count() + 1
	else:
		return get_child_count()
		
func position_units():
	var units = get_units()
	var spells = get_spell_tokens()
	var unit_spacing = 2.0
	var max_width = units.size()*unit_spacing  # The total space to distribute units
	var max_spell_width = spells.size()*unit_spacing
	var total_width = max_width + max_spell_width
	var shift_for_spells = 0
	if max_spell_width > 0:
		total_width += unit_spacing
		shift_for_spells = (max_spell_width + unit_spacing)/2.0
	  # Avoid division by zero if only one unit
	#print(unit_spacing)
	var index = 0
	for unit in units:
		#var index = unit.get_index()
		var offset = - shift_for_spells + index * unit_spacing - (max_width / unit_spacing) + 1  # Center units around the middle of the max_width
		unit.target_transform.origin = Vector3(offset + screen_location[0]/card_scale, table_height, screen_location[1]/card_scale)
		var rot_degrees = -90  # Rotation in degrees
		var rot_radians = deg_to_rad(rot_degrees) 
		unit.target_transform.basis = Basis(Vector3(1, 0, 0), rot_radians) # Convert degrees to radians
		unit.target_transform = unit.target_transform.scaled(Vector3(card_scale, card_scale, card_scale))
		index += 1
		
	
	
	index = 0
	for spell in spells:
		var offset = -shift_for_spells + unit_spacing + max_width/2.0 + max_spell_width/2.0 + index * unit_spacing - (max_spell_width / unit_spacing) + 1  # Center units around the middle of the max_width
		spell.target_transform.origin = Vector3(offset + screen_location[0]/card_scale, table_height, screen_location[1]/card_scale)
		var rot_degrees = -90  # Rotation in degrees
		var rot_radians = deg_to_rad(rot_degrees) 
		spell.target_transform.basis = Basis(Vector3(1, 0, 0), rot_radians) # Convert degrees to radians
		spell.target_transform = spell.target_transform.scaled(Vector3(card_scale, card_scale, card_scale))
		index += 1
	
func card_hovered(card):

	card.outline.visible = true
		

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

func card_not_hovered_anymore(card):
	card.outline.visible = false

func connect_card_signals(card):
	card.card_clicked.connect(self.card_clicked)
	card.card_released.connect(self.card_released)
	card.card_hovered.connect(self.card_hovered)
	card.card_not_hovered_anymore.connect(self.card_not_hovered_anymore)
	#print("Added Card Signal")

func remove_card_signals(card):
	
	if card.card_not_hovered_anymore.is_connected(self.card_not_hovered_anymore):
		card.card_not_hovered_anymore.disconnect(self.card_not_hovered_anymore)
	
	if card.card_hovered.is_connected(self.card_hovered):
		card.card_hovered.disconnect(self.card_hovered)
		
	if card.card_clicked.is_connected(self.card_clicked):
		card.card_clicked.disconnect(self.card_clicked)
	
	if card.card_released.is_connected(self.card_released):
		card.card_released.disconnect(self.card_released)


func _on_child_entered_tree(node):
	if not node.is_inside_tree():
		await ready
	var index = get_unit_index(node)
	if index != node.get_index():
		move_to_new_index(node, index)
	connect_card_signals(node)
	call_deferred("position_units")
	emit_signal("formation_changed")
	
func _on_child_exiting_tree(node):
	remove_card_signals(node)
	emit_signal("formation_changed")

