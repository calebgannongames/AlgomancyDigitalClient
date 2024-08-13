extends Node3D

var draft_height = 5.5
var ANIM_SPEED = 12.0
@export_node_path var deck_path
@onready var deck := get_node(deck_path)

@export_node_path var camera_path
@onready var camera := get_node(camera_path)

var pack_size = 10
var starting_pack_size = 14
var draft_grid = Vector2(8, 2)

func is_odd(number):
	return number % 2 == 1

func position_units():
	var units = get_children()
	#print(units.size())
	draft_grid[0] = ceil(units.size()/2.0)
	var leftover = floor(units.size()/2.0)
	var counter = 0
	var max_width = Vector2(12 * draft_grid[0]/8, 12 * leftover/8)
	var max_height = 6
	var xspacing = 1.5
	var yspacing = 2.0
	var vertical_spacing = 0.001
	var max_height_space = units.size()*vertical_spacing
	var rot_degrees = -80.0  # Rotation in degrees
	var rot_radians = deg_to_rad(rot_degrees)
	#var spacing = Vector2(5.5, 8.5)
	for unit in units:
		var i = counter / int(draft_grid[0])
		var j = counter % int(draft_grid[0])
		## We flip the direction of odd rows to make cards move less when switching between rows
		if is_odd(i):
			j = leftover - j-1
		# Position each card in a grid pattern
		var target_translation = Vector3(
			j * xspacing - (max_width[i] / 2.0) + 0.75,  # Adjust for even distribution
			draft_height + counter*vertical_spacing - max_height_space/2 - yspacing*i*cos(rot_radians),
			-i * yspacing*sin(rot_radians) + 1.25 - (max_height / 2.0) 
		)
		#var camera_space_position = target_translation.rotated(Vector3.UP, rot_radians)
		units[counter].target_transform.origin = target_translation
		
		 
		units[counter].target_transform.basis = Basis(Vector3(1, 0, 0), rot_radians) # Convert degrees to radians
		counter += 1
	# Make the card face the camera
		#units[i].look_at(get_viewport().get_camera_3d().position, Vector3.UP)
			
func preprocess(unit):
	if unit.draggable:
		var mouse_pos = get_viewport().get_mouse_position()
		var cam = get_viewport().get_camera_3d()
		var origin = cam.project_ray_origin(mouse_pos)
		var normal = cam.project_ray_normal(mouse_pos)
		# Define the plane where the unit should move (constant y)
		var plane = Plane(Vector3(0, cos(deg_to_rad(10.0)), sin(deg_to_rad(10.0))), draft_height)
		#var plane = Plane(Vector3(0, 1, 0), draft_height)
		# Calculate the intersection point of the ray with the plane
		var intersection = plane.intersects_ray(origin, normal)
		#var ray_length = (unit.position.y-cam.position.y)/normal.y
		#var end = origin + normal * ray_length
		unit.position = intersection
		#unit.position.y = intersection.y
		#unit.position.z = intersection.z
		
		#print("Unit is at X:", intersection.x, "and Y:", intersection.z)
		var index = unit.get_index()
		var new_index = get_unit_index(unit)
		if index != new_index:
			move_to_new_index(unit, new_index)
			

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
	for i in starting_pack_size:
		deal_card()

func _process(delta: float) -> void:
	for unit in get_children():
		preprocess(unit)
	position_units()
	for unit in get_children():
		unit.transform = unit.transform.interpolate_with(unit.target_transform, ANIM_SPEED * delta)

func get_unit_index(unit):
	var new_y_index
	if get_children().size()>draft_grid[0]:
		new_y_index = get_unit_y_index(unit)
	else:
		new_y_index = 0
	
	var new_x_index = get_unit_x_index(unit, new_y_index)
	
	var new_index = new_x_index + new_y_index*draft_grid[0]
	return new_index
	
func get_unit_x_index(unit, row):
	var units = get_children()
	
	units.sort_custom(sort_by_z)
	
	var row_of_units
	if row == 0:
		row_of_units = units.slice(0,min(units.size(), draft_grid[0]))
	else:
		row_of_units = units.slice(draft_grid[0])
	
	if is_odd(row):
		# Sort the children by their x position backwards
		row_of_units.sort_custom(sort_by_x_desc)
	else:
		# Sort the children by their x position
		row_of_units.sort_custom(sort_by_x_asc)
	
	# Find the index of the target_child
	for i in range(row_of_units.size()):
		if row_of_units[i] == unit:
			return i
	#There is still a bug where cards sometimes can't find themselves, but it doesn't seem to case problems?
	#print("Couldn't find myself at X:", unit.position.x, " and Y:", unit.position.z)
	return 0


func sort_by_z(a, b):
	return a.global_transform.origin.z < b.global_transform.origin.z

func sort_by_x_asc(a, b):
	return a.global_transform.origin.x < b.global_transform.origin.x

func sort_by_x_desc(a, b):
	return a.global_transform.origin.x > b.global_transform.origin.x

func get_unit_y_index(unit):
	var units = get_children()
	units.sort_custom(sort_by_z)
	var first_row = units.slice(0,draft_grid[0])
	var second_row
	if units.size() > (draft_grid[0]+1):
		second_row = units.slice(draft_grid[0], -1)
	else:
		second_row = [units[draft_grid[0]]]
	
	var distance_to_first = abs(unit.position.z - first_row[0].position.z)
	var distance_to_second = abs(unit.position.z - second_row[0].position.z)
	
	if distance_to_first < distance_to_second:
		return 0
	else:
		return 1

func move_to_new_index(unit, new_index: int):
	move_child(unit, new_index)
	
	
func draft_card(card):
	if card.get_parent() == self:
		card.scale = Vector3.ONE
		card.outline.visible = false
		card.draggable = false
		card.hovered = false
		var hand = get_parent().hand
		card.move_node(hand)
		#print("Move Card to board")
	#var a=2
	
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

func card_hovered(card):

	card.outline.visible = true
		

func card_not_hovered_anymore(card):
	card.outline.visible = false

func connect_card_signals(card):
	card.card_clicked.connect(self.card_clicked)
	card.card_released.connect(self.card_released)
	card.card_selected.connect(self.draft_card)
	card.card_hovered.connect(self.card_hovered)
	card.card_not_hovered_anymore.connect(self.card_not_hovered_anymore)
	#print("Added Card Signal")

func remove_card_signals(card):
	if card.card_selected.is_connected(self.draft_card):
		card.card_selected.disconnect(self.draft_card)
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
	
	if node.phantom:
		node.queue_free()
	else:
		#print("Index: ", node.get_index())
		var index = get_unit_index(node)
		
		if index != node.get_index():
			move_to_new_index(node, index)
		connect_card_signals(node)
		var num_children = get_child_count()-1
		
		if num_children >13:
			draft_height = 5.5
		elif num_children >11:
			draft_height = 6
		elif num_children >9:
			draft_height = 6.2
		else:
			draft_height = 6.2
		
		
		call_deferred("position_units")
	


func _on_child_exiting_tree(node):
	remove_card_signals(node)
	var num_children = get_child_count()-1
	
	if num_children >14:
		draft_height = 5.5
	elif num_children >12:
		draft_height = 6
	elif num_children >10:
		draft_height = 6.2
	else:
		draft_height = 6.2

