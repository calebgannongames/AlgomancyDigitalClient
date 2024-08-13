extends Node3D
# Called when the node enters the scene tree for the first time.
var ANIM_SPEED = 8.0
var table_height = 0.4
var screen_location = Vector2(0, -3.5)
var card_scale = 1.0
# The plan for formation is to have one formation shared between attacking and blocking units
# so that there are no "empty" columns, and we can propagate combat damage easily.
var formation = []
var old_formation = []
signal formation_changed()
#var column_pos = []

func check_if_formation_changed():
	
	if formation != old_formation:
			emit_signal("formation_changed")
			old_formation = formation.duplicate(true)

func remove_node_recursively(array, node):
	var i = 0
	while i < array.size():
		if array[i] is Array:
			remove_node_recursively(array[i], node)
		elif array[i] == node:
			array.remove_at(i)
			return  # Exit after removal to prevent further indexing issues
		i += 1

func remove_empty_elements(array):
	var i = 0
	for element in array:
		if element.is_empty():
			array.remove_at(i)
		i+= 1

func calculate_distance(a,b):
	return Vector2(a.global_transform.origin.x-b.global_transform.origin.x, a.global_transform.origin.z - b.global_transform.origin.z)
func calculate_sq_distance(a, b):
	var distance = calculate_distance(a, b)
	return (distance.x)**2 + (distance.y)**2

func find_nearest_column(card):
	remove_node_recursively(formation, card)
	remove_empty_elements(formation)
	if formation.size() ==0:
		formation.append([card])
		check_if_formation_changed()
		return
	var distance = 99999
	var closest = formation[0][0]
	var closest_index = 0
	var counter = 0
	for column in formation:
		var new_distance = calculate_sq_distance(card, column[0])		
		if new_distance < distance:
			distance = new_distance
			closest = column
			closest_index = counter
		counter += 1
	
	add_unit_relative_to_closest_column(card, closest, closest_index)
	#print(formation)


func add_unit_relative_to_closest_column(unit, column, column_pos):
	var distance = calculate_distance(unit, column[0])
	if (abs(distance.y) > abs(distance.x)) and column.size()<2:
		#unit will be appended to an existing column
		if distance.y > 0:
			# append unit to the front row
			column.insert(0, unit)
		else:
			#append unit to the back row
			column.append(unit)
	else:
		#unit will be inserted into a new column
		if distance.x > 0:
			# append unit to the right
			formation.insert(column_pos+1, [unit])
		else:
			#append unit to the left
			formation.insert(column_pos, [unit])
	check_if_formation_changed()

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
		var plane = Plane(Vector3(0, 1, 0), -unit.position.y)
		# Calculate the intersection point of the ray with the plane
		var intersection = plane.intersects_ray(origin, normal)
		#var ray_length = (unit.position.y-cam.position.y)/normal.y
		#var end = origin + normal * ray_length
		unit.position.x = intersection.x
		unit.position.z = intersection.z
		find_nearest_column(unit)
		#var index = unit.get_index()
		#var new_index = get_unit_index(unit)
		#if index != new_index:
			#move_to_new_index(unit, new_index)
			

func _process(delta: float) -> void:

	for unit in get_children():
		preprocess(unit)
	position_units()
	for unit in get_children():
		unit.transform = unit.transform.interpolate_with(unit.target_transform, ANIM_SPEED * delta)
	
		
func position_units():
	
	#var units = get_children()
	var max_width = formation.size()*2.2  # The total space to distribute units
	var unit_spacing = 2.2  # Avoid division by zero if only one unit
	#print(unit_spacing)
	var index = 0
	for column in formation:
		var xoffset = index * unit_spacing - (max_width / 2.0) + 1  # Center units around the middle of the max_width
		var i = 0
		for unit in column:
			var yoffset = -i * unit_spacing*0.95
			unit.target_transform.origin = Vector3(xoffset + screen_location[0], table_height, screen_location[1] + yoffset)
			var rot_degrees = -90  # Rotation in degrees
			var rot_radians = deg_to_rad(rot_degrees) 
			unit.target_transform.basis = Basis(Vector3(1, 0, 0), rot_radians) # Convert degrees to radians
			unit.target_transform = unit.target_transform.scaled(Vector3(card_scale, card_scale, card_scale))
			i += 1
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
	if node.is_spell_token:
		var target_node = node.get_parent().get_parent().get_parent().active_board
		node.call_deferred("move_node", target_node)
	else:
		find_nearest_column(node)
		#var index = get_unit_index(node)
		#if index != node.get_index():
			#move_to_new_index(node, index)
		connect_card_signals(node)
		call_deferred("position_units")
	
func _on_child_exiting_tree(node):
	
	remove_card_signals(node)
	remove_node_recursively(formation, node)
	remove_empty_elements(formation)
	check_if_formation_changed()
	#formation.erase(node)
	#print(formation)
