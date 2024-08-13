extends Node3D
class_name Card

#signal inspect(card_resource)
@onready var target_transform := Transform3D()

@onready var hover_timer := $Hover_Timer
@onready var bottom_arrow_connector := $Bottom_Arrow_Connector
@onready var left_arrow_connector := $Left_Arrow_Connector
@onready var right_arrow_connector := $Right_Arrow_Connector

@onready var card_name := $Title_Box/CardName
@onready var card_type := $Type_Box/Sprite3D/SubViewport/Control/CardType

@onready var type_box := $Type_Box/Sprite3D/SubViewport/Control/Type_Box
@onready var ability_box := $Type_Box

@onready var card_art := $CardFront
@onready var card_power := $Power_Box/CardPower
@onready var card_power_box := $Power_Box

@onready var card_toughness := $Toughness_Box/CardToughness
@onready var card_toughness_box := $Toughness_Box
@onready var card_cost_box := $Title_Box/Cost
@onready var card_cost := $Title_Box/Cost/Cost_Value
@onready var card_ability_viewport := $Type_Box/Sprite3D/SubViewport
@onready var card_ability := $Type_Box/Sprite3D/SubViewport/CardAbility
@onready var card_ability_positioner := $Type_Box/Sprite3D


@onready var Timing := $Timing_Box/Timing
@onready var Timing_box := $Timing_Box

@onready var Counters:= $Counters
@onready var Counters_Amount:= $Counters/Label3D

@onready var Mod_Timing := $Mod_Timing_Box/Mod_Timing
@onready var Mod_Timing_box := $Mod_Timing_Box

@onready var Title_box := $Title_Box
@onready var Title_sprite := $Title_Box/Title_Sprite
@onready var Type_sprite := $Type_Box/Sprite3D/SubViewport/Control/Type_Box
@onready var Affinity1 := $Title_Box/Cost/Affinity
@onready var Affinity2 := $Title_Box/Cost/Affinity2
@onready var Affinity3 := $Title_Box/Cost/Affinity3
@onready var outline := $Outline
@onready var phantom_outline := $Phantom_Outline
@onready var sleepy_outline := $SleepyOutline
@onready var card_back := $CardBack
@onready var card_front := $CardFront
@onready var collision_shape := $Area3D/CollisionShape3D


@onready var play_audio := $PlayAudio
@onready var draw_audio := $DrawAudio
@onready var move_audio := $MoveAudio
@onready var area := $Area3D

@onready var zone_manager = get_node("/root/Main/Zone_Manager")

@export var dork_resource: Resource
@onready var trigger_arrow_spot = $Trigger_Arrows
@onready var target_arrow_spot = $Target_Arrows
#@onready var right_click_menu = $RightClickMenu

var affinity_requirement = ''
var created_tokens = []
var right_click_menu = preload("res://Scenes/right_click_menu.tscn")
var trigger_curve = preload("res://trigger_curve.tscn")
var target_curve = preload("res://target_curve.tscn")
var card = preload("res://card.tscn")
var counters_total = 0

var is_spell_token = false
var trigger_source = null
var triggers = []
var targets = []
var target_curve_select = null
var is_player = true
var active = true
var phantom = false
var token = false
var timing = null
var ability = null
var cardtype = null
var is_unit = false
var is_inspect = false

var mod_timing = null

var inspect_hovered = false
var textbox_width = 1
#@onready var outline := $Outline
var target_rotation := 0.0
const ANIM_SPEED := 12.0

signal play_card()
signal card_selected()
signal card_released()
signal card_hovered()
signal card_not_hovered_anymore()

signal card_hover_timer()
signal card_trigger()

signal card_dropped()
signal card_clicked()
signal card_double_clicked()
signal card_right_clicked()
signal card_right_click_released()
var hovered = false
var draggable = false
var target_select = false
var played = false

var card_scale = Vector3(0.88, 0.88, 0.01)
var unit_scale = Vector3(1.33, 0.88, 0.01)
var stack_scale = Vector3(0.88, 0.63, 0.01)
var outline_card_scale = Vector3(0.663, 0.87, 0.01)
var outline_unit_scale = Vector3(1.0, 0.88, 0.01)
var outline_stack_scale = Vector3(0.663, 0.663, 0.01)

var unit_stats_location = Vector3(0.8, -0.9, 0.015)
var card_stats_location = Vector3(-0.4, -0.7, 0.015)


#func _ready():
	#var card_mesh = card_art.mesh as ArrayMesh
	#
	## Example usage
#
	#save_mesh_as_obj(card_mesh, "res://your_mesh.obj")
	##var arrays = card_mesh.surface_get_arrays(0)
	##
	###print("Arrays", arrays)
	### Access the vertex array (which is the first array, index 0)
	##var vertices = arrays[Mesh.ARRAY_VERTEX]
	##print("Num Vertices:", vertices.size())
	##print("Vertices", vertices)

#func save_mesh_as_obj(mesh, file_path):
	#var file = FileAccess.open(file_path, FileAccess.WRITE)
	#
#
	## OBJ files start with the name of the object
	#file.store_string("o Mesh\n")
#
	## Store all vertices
	#if mesh is ArrayMesh:
		#for surface in range(mesh.get_surface_count()):
			#var arrays = mesh.surface_get_arrays(surface)
			#var vertices = arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
			#for vertex in vertices:
				#file.store_string("v %f %f %f\n" % [vertex.x, vertex.y, vertex.z])
#
	## Store all faces (assuming triangles)
	#var index_offset = 1
	#for surface in range(mesh.get_surface_count()):
		#var arrays = mesh.surface_get_arrays(surface)
		#var indices = arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
		#for i in range(0, indices.size(), 3):
			#var idx1 = indices[i] + index_offset
			#var idx2 = indices[i+1] + index_offset
			#var idx3 = indices[i+2] + index_offset
			#file.store_string("f %d %d %d\n" % [idx1, idx2, idx3])
		#index_offset += indices.size()
#
	#file.close()
	#print("Mesh saved as OBJ: %s" % file_path)


	

func release_card():
	scale = Vector3.ONE
	outline.visible = false
	draggable = false
	hovered = false
	zone_manager.card_released(self)

func _notification(what):
	if what == NOTIFICATION_WM_MOUSE_EXIT:
		if is_in_hand():
			outline.visible = false
			draggable = false
			hovered = false
		CardInspect.card_not_hovered(self)
		emit_signal("card_not_hovered_anymore", self)
		hover_timer.stop()
		if inspect_hovered:
			end_hover_effect()

func _on_area_3d_mouse_entered() -> void:
	emit_signal("card_hovered", self)
	CardInspect.card_hovered(self)
	if not draggable:
		hover_timer.start()

func _on_area_3d_mouse_exited() -> void:
	emit_signal("card_not_hovered_anymore", self)
	CardInspect.card_not_hovered(self)
	hover_timer.stop()
	if inspect_hovered:
		end_hover_effect()
	

func find_camera_pos() -> Vector3:
	var camera = get_viewport().get_camera_3d()
	var unprojected = camera.unproject_position(target_transform.origin)
	# I fiddled with the y coordinate and distance here so the full card is visible
	return camera.project_position(Vector2(unprojected.x, 880), 3.0)


func is_in_hand() -> bool:
	return get_parent().name == 'Hand'

func is_in_draft() -> bool:
	return get_parent().name == 'Draft'

func is_on_the_stack() -> bool:
	return get_parent().name == 'The_Stack'

func draw_sound() -> void:
	draw_audio.play()
	
func play_this_card():
	#played = true
	if !played:
		scale = Vector3.ONE
		outline.visible = false
		draggable = false
		hovered = false
		#active = false
		#print("Card Played Card Trigger")
		release_card()
		#emit_signal("card_released", self)

func was_played():
	played = true

func _input(event: InputEvent):
	if event.is_action_released("click") and draggable == true:
		#emit_signal("card_released", self)
		release_card()
		#hover_timer.stop()
		#play_this_card()
	elif event.is_action_released("right_click") and target_select == true:
		emit_signal("card_right_click_released", self)	

#func _on_HoverTimer_timeout():
	#print("Hovered over for 1 second")

func erase_self():
	hide()
	queue_free()

func create_trigger():
	#emit_signal("card_triggered", self)
	#GameState.create_trigger(self)
	var player = get_tree().root.get_node('Main/Player')
	var cloned_card = self.duplicate()
	cloned_card.position = self.position
	#print(cloned_card.rotation)
	cloned_card.rotation = self.rotation
	cloned_card.token = true
	cloned_card.trigger_source = self
	player.the_stack.add_child(cloned_card)
	cloned_card.transform_card("Trigger")
	triggers.append(cloned_card)


	

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click") and is_player and not event.double_click:
		emit_signal("card_clicked", self)
		hover_timer.stop()
		if inspect_hovered:
			end_hover_effect()
	if event.is_action_pressed("right_click"):
		##create_trigger()
		#if !is_on_the_stack():
			#create_trigger()
		emit_signal("card_right_clicked", self)
	#if event.is_action_pressed("middle_click"):
		##add_plus_counter()
		#drop_down_menu()
		#emit_signal("card_middle_clicked", self)
		#target_select = true
	if event.is_action_pressed("click") and is_player and event.double_click:
		emit_signal("card_selected", self)
		hover_timer.stop()
		if inspect_hovered:
			end_hover_effect()

func move_node(new_node:Node):
	var unit_nodes = ['In_Play_Not_Formation', 'Attacking_Formation', 'Blocking_Formation']
	was_played()
	var become_unit = false
	var become_stack = false
	if new_node.name in unit_nodes:
		become_unit = true
	elif new_node.name == "The_Stack":
		become_stack = true
	var parent = get_parent()
	if become_unit:
		transform_card("Unit")
	elif become_stack:
		transform_card("Stack")
	else:
		transform_card("Card")
	var cache_transform = self.transform
	parent.remove_child(self)
	new_node.add_child(self)
	self.transform = cache_transform
	self.played = false

func transform_to_unit():
	#type_box.hide()
	#card_type.hide()
	ability_box.hide()
	Timing_box.hide()
	card_cost_box.show()
	Title_sprite.show()
	Counters.scale = Vector3(2.0, 2.0, 1.0)
	Counters.position.x = 0.7
	if counters_total !=0:
		Counters.show()
	card_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	card_name.position.x = -0.38
	Title_box.position.y = 0.79
	ability_box.position.y = -0.4
	card_toughness_box.position.y = -0.8
	card_power_box.position.y = -0.8
	bottom_arrow_connector.position.y = -0.85
	
	card_power.font_size = 300
	card_power_box.position.x =-0.8
	card_toughness.font_size = 300
	card_toughness_box.position.x = 0.8
	Title_box.scale = Vector3(1.8, 1.8, 1.8)
	
func transform_to_card():
	if timing != null:
		Timing_box.show()
	if ability != null:
		ability_box.show()
	#if cardtype != null:
	type_box.show()
	card_type.show()
	card_cost_box.show()
	Title_sprite.show()
	Counters.scale = Vector3(1.0, 1.0, 1.0)
	Counters.position.x = 0.55
	#Counters.show()
	card_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	card_name.position.x = -0.38
	#if mod_timing != null:
		#Mod_Timing_box.show()
		#Timing_box.hide()
	Title_box.position.y = 0.79
	ability_box.position.y = -0.4
	card_toughness_box.position.y = -0.8
	card_power_box.position.y = -0.8
	bottom_arrow_connector.position.y = -0.88
	
	card_power.font_size = 150
	card_power_box.position.x =-0.55
	card_toughness.font_size = 150
	card_toughness_box.position.x = 0.55
	Title_box.scale = Vector3(1.0, 1.0, 1.0)
	
func transform_to_stack():
	if timing != null:
		Timing_box.hide()
	if ability != null:
		ability_box.show()
	if cardtype != null:
		type_box.show()
		card_type.show()
	outline.hide()
	card_cost_box.show()
	Title_sprite.show()
	Counters.hide()
	card_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	card_name.position.x = -0.38
	#if mod_timing != null:
		#Mod_Timing_box.show()
		#Timing_box.hide()
	Title_box.position.y = 0.59
	ability_box.position.y = -0.154
	card_toughness_box.position.y = -0.5
	card_power_box.position.y = -0.5
	bottom_arrow_connector.position.y = -0.55
	
	card_power.font_size = 150
	card_power_box.position.x =-0.55
	card_toughness.font_size = 150
	card_toughness_box.position.x = 0.55
	Title_box.scale = Vector3(1.0, 1.0, 1.0)
	

func transform_to_trigger():
	
	Timing_box.hide()
	if ability != null:
		ability_box.show()
	if cardtype != null:
		type_box.show()
		card_type.show()
	outline.hide()
	#Title_sprite.hide()
	card_cost_box.hide()
	card_power_box.hide()
	card_toughness_box.hide()
	#sleepy_outline.show()
	Title_box.hide()
	Counters.hide()
	sleepy_outline.scale = outline_stack_scale
	card_art.mesh = load("res://cut_card_mesh.obj")
	#card_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	#card_name.position.x = 0
	#if mod_timing != null:
		#Mod_Timing_box.show()
		#Timing_box.hide()
	Title_sprite.modulate = Color(0, 0, 0)
	Title_box.position.y = 0.59
	ability_box.position.y = -0.154
	card_toughness_box.position.y = -0.5
	card_power_box.position.y = -0.5
	Title_sprite.scale = Vector3(0.7, 1.0, 1.0)
	card_power.font_size = 150
	card_power_box.position.x =-0.55
	
	bottom_arrow_connector.position.y = -0.55
	
	card_toughness.font_size = 150
	card_toughness_box.position.x = 0.55
	Title_box.scale = Vector3(1, 1.0, 1.0)

func transform_card(type: String):
	var new_scale
	var new_outline_scale
	var new_stats_location
	if type == "Unit":
		new_scale = unit_scale
		new_outline_scale = outline_unit_scale
		transform_to_unit()
		#new_stats_location = unit_stats_location
	elif type == "Stack":
		new_scale = stack_scale
		new_outline_scale = outline_stack_scale
		transform_to_stack()
	elif type == "Trigger":
		new_scale = stack_scale
		new_outline_scale = outline_stack_scale
		transform_to_trigger()
	else:
		transform_to_card()
		new_scale =  card_scale
		new_outline_scale = outline_card_scale
		#new_stats_location = card_stats_location
	#card_power.position = new_stats_location
	card_back.scale = new_scale
	card_front.scale = new_scale
	collision_shape.scale = new_outline_scale
	outline.scale = new_outline_scale


func delete_trigger_lines():
	#print(trigger_arrow_spot.get_child_count())
	for line in trigger_arrow_spot.get_children():
		line.hide()
		line.queue_free()
		
func delete_target_lines():
	for line in target_arrow_spot.get_children():
		line.hide()
		line.queue_free()
	
func remove_trigger_outlines():
	for trigger in triggers:
		if trigger == null:
			triggers.erase(trigger)
		else:
			trigger.outline.hide()
	
	

func remove_trigger_source_outlines():
	if trigger_source != null:
		trigger_source.outline.hide()
		
		
func remove_target_outlines():
	for target in targets:
		target.outline.hide()

func initialize_target_line():
	target_curve_select = target_curve.instantiate()
	target_arrow_spot.add_child(target_curve_select)
	
func remove_target_line():
	target_curve_select.queue_free()
	target_curve_select = null
	print("DEEEEEE")

func draw_target_line_to_mouse():
	var camera = get_viewport().get_camera_3d()
	var current_screen_position = camera.unproject_position(left_arrow_connector.global_transform.origin)
	var mouse_pos = get_viewport().get_mouse_position()
	#target_curve_select = target_curve.instantiate()
	#target_arrow_spot.add_child(target_curve_select)
	if target_curve_select == null:
		initialize_target_line()
	target_curve_select.draw_curve(mouse_pos, current_screen_position)
#	line.points = curve.curve.get_baked_points()
	target_curve_select.show()

func draw_line_to_targets():
	var camera = get_viewport().get_camera_3d()
	var current_screen_position = camera.unproject_position(left_arrow_connector.global_transform.origin)
	
	for target in targets:
		if target == null:
			target.erase(target)
		else:
			target.outline.show()
			var target_pos = target.right_arrow_connector.global_transform.origin
			var target_screen_position = camera.unproject_position(target_pos)
			var this_curve = target_curve.instantiate()
			target_arrow_spot.add_child(this_curve)
			var line = this_curve
			line.draw_curve(target_screen_position, current_screen_position)
		#	line.points = curve.curve.get_baked_points()
			line.show()


func draw_line_to_triggers():
	var camera = get_viewport().get_camera_3d()
	var current_screen_position = camera.unproject_position(right_arrow_connector.global_transform.origin)

	for trigger in triggers:
		if trigger == null:
			triggers.erase(trigger)
		else:
			trigger.outline.show()
			var target = trigger.left_arrow_connector.global_transform.origin
			var target_screen_position = camera.unproject_position(target)
			var this_curve = trigger_curve.instantiate()
			trigger_arrow_spot.add_child(this_curve)
			var line = this_curve
			line.draw_curve(target_screen_position, current_screen_position)
		#	line.points = curve.curve.get_baked_points()
			line.show()
			

func draw_line_to_trigger_source():
	if trigger_source != null:
		trigger_source.outline.show()
		var camera = get_viewport().get_camera_3d()
		var target = trigger_source.bottom_arrow_connector.global_transform.origin
		var current_screen_position
		if is_inspect:
			current_screen_position = camera.unproject_position(bottom_arrow_connector.global_transform.origin)
		else:
			current_screen_position = camera.unproject_position(left_arrow_connector.global_transform.origin)
		var target_screen_position = camera.unproject_position(target)
		print("Showing curve")
		var this_curve = trigger_curve.instantiate()
		trigger_arrow_spot.add_child(this_curve)
		var line = this_curve
		#var curve = trigger_origin_curve
		#var line = trigger_origin_show_curve
		line.draw_curve(current_screen_position, target_screen_position)
		#line.points = curve.curve.get_baked_points()
		line.show()

func setup_resource(card_resource) -> void:
	if not is_inside_tree():
		await ready
	#resource = card_resource
	#berry_cost = card_resource.berry_cost
	#stomp_cost = card_resource.stomp
	#print()
	Title_box.hide()
	type_box.hide()
	card_type.hide()
	ability_box.hide()
	Timing_box.hide()
	Mod_Timing_box.hide()
	card_name.text = card_resource.card_name
	#card_power.text = str(card_resource.card_power)
	#card_power.text = str(card_resource['power']) + '/' + str(card_resource['defense'])
	#card_toughness.text = str(card_resource.card_toughness)
	#card_abilities = card_resource.abilities
	card_art.material_override.set("albedo_texture", card_resource.card_art)

func get_timing_from_type(type):
	var timing_options = {
		"{Battle}": "Images/Icons/Battle.png",
		"{Haste}": "Images/Icons/Haste.png",
		"{Virus}": "Images/Icons/Virus.png",
	}
	
	for key in timing_options.keys():
		if key in type:
			type = type.replace(key, '')
			timing = timing_options[key]
	
	type = type.replace('{', '[color=#fae632]')
	type = type.replace('}', '[/color]')
	type = type.replace('[Augment]', "[img]res://Images/Icons/Augment_Small.png[/img]")
	
	return type

func get_mod_timing():
	var timing_options = {
		"Augment_Small.png": "Images/Icons/Augment_Small.png",
		"Graft.png": "Images/Icons/Graft.png",
		"Graft_Once.png": "Images/Icons/Graft_Once.png",
	}
	
	var total_text = card_type.text + card_ability.text
	
	for key in timing_options.keys():
		if key in total_text:
			mod_timing = timing_options[key]
			
func get_letter_size():
	return 1
func resize_title_to_fit():			
	var title_width = get_letter_size()*len(card_name.text)
	var timing_width = 0
	var stats_width = 0
	if is_unit:
		stats_width = get_letter_size()*len(card_power.text)
	if timing != null:
		timing_width = 0.0
	var available_width = title_width + timing_width
	#print(available_width)
	var max_characters = 19.0
	if available_width > max_characters:
		card_name.font_size = max_characters/available_width*100.0

func resize_type_to_fit():			
	var type_width = get_letter_size()*len(card_type.text)
	#print(available_width)
	var max_characters = 25.0
	if type_width > max_characters:
		card_type.font_size = max_characters/type_width*80.0
	
func check_if_unit(card_resource):
	if "Unit" in card_resource['type']:
		is_unit = true
		card_power_box.show()
		card_toughness_box.show()


func get_words(text):
	return text.split(' ')

func get_word_lengths(words, font_size):
	var letter_width = card_ability.font.get_string_size('a', HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var word_lengths = []
	for word in words:
		word_lengths.append(len(word)*letter_width)
	return word_lengths
	
#func typesetting_cost_matrix(word_lengths):
	#var num_words = len(word_lengths)
	#var costs = Vector2(num_words, num_words)
	

func get_num_text_lines(text, box_width, font_size):
	var words = get_words(text)
	var word_lengths = get_word_lengths(words, font_size)
	var letter_width = card_ability.font.get_string_size('a', HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var line_width = 0
	var num_lines = 1
	for word_length in word_lengths:
		line_width += word_length
		if line_width > box_width:
			#newline
			num_lines += 1
			line_width = word_length + letter_width
		else:
			line_width += letter_width
	return num_lines



func resize_ability_box():
	#var num_lines = get_num_text_lines(ability_text, card_ability.width, card_ability.font_size)
	#var height = num_lines * card_ability.font_size
	await get_tree().process_frame
	var text_size = card_ability.size
	var type_height = card_ability.position.y
	card_ability_viewport.size = text_size + Vector2(0, type_height)
	#var string_size = card_ability.size
	#var string_size = card_ability.font.get_multiline_string_size(ability_text, HORIZONTAL_ALIGNMENT_LEFT, 1050, card_ability.text.font_size)
	#var num_lines = string_size.y/70.0
	#print(num_lines)
	#card_ability_viewport.size = string_size
	#var mesh = ability_box.mesh
	
	#ability_box.scale.y = text_size.y/300.0
	#print(text_size)
	#card_ability_positioner.position.y -=  (0.3 - num_lines * 0.3/4.0)/2.0
	#ability_box.position.y = 
	#type_box.position.y =  300*(1-ability_box.scale.y)
	#print(ability_box.mesh.size)
	#if "Harbinger of" in card_name.text:
		#print(ability_box.mesh.size.y)
		#print(ability_box.position.y)
		
func set_affinity(affinity: String):
	var timing_options = {
		"r": "res://Images/Icons/Fire.png",
		"g": "res://Images/Icons/Wood.png",
		"b": "res://Images/Icons/Water.png",
		"m": "res://Images/Icons/Metal.png",
		"e": "res://Images/Icons/Earth.png"
	}
	
	var counter = 0
	for symbol in affinity:
		var new_texture = load(timing_options[symbol])
		if counter == 0:
			Affinity1.show()
			Affinity1.texture = new_texture
		elif counter == 1:
			
			Affinity2.show()
			Affinity2.texture = new_texture
		else:
			Affinity3.show()
			Affinity3.texture = new_texture
		counter += 1
		

func get_colors_from_affinity(s: String):
	# Ensure the string has enough length to perform the operation
	if s.length() == 0:
		return []  # Return an empty array if the string is empty
	elif s.length() == 1:
		return s[0]  # Return the single character if the string has only one character

	# Get the first and last characters
	var first_char = s[0]
	var last_char = s[s.length() - 1]
	
	# Check if the first and last characters are the same
	if first_char == last_char:
		
		return first_char  # Return one character as an array
	else:
		return first_char + last_char  # Return both characters as an array

func set_box_colors(card_resource, title):
	var pre_path = "res://Images/Cropped_Card_Borders/"
	var end_path = "_rectangle_1.png"
	var box_set
	if title:
		end_path = "_rectangle_1.png"
		box_set = Title_sprite
	else: 
		end_path = "_rectangle_2.png"
		box_set = Type_sprite
	var affinity = card_resource['affinity_requirement']
	var colors = get_colors_from_affinity(affinity)
	var path_string = pre_path + colors + end_path
	var box_image = load(path_string)
	box_set.texture = box_image


func set_card_text(card_resource):
	var icon_replacements = {
		"[Battle]": "[img]res://Images/Icons/Battle_Small.png[/img]",
		"[Augment]": "[img]res://Images/Icons/Augment_Small.png[/img]",
		"[Graft]": "[img]res://Images/Icons/Graft.png[/img]",
		"[Graft1]": "[img]res://Images/Icons/Graft_Once.png[/img]",
		"[x]": "[img]res://Images/Icons/X_circle.png[/img]",
		"[once]": "[img]res://Images/Icons/Once.png[/img]",
		"[2be]": "[img]res://Images/Icons/2be.png[/img]",
		"[three_blue]": "[img]res://Images/Icons/3b.png[/img]",
		"[3bb]": "[img]res://Images/Icons/3bb.png[/img]",
		"[4bb]": "[img]res://Images/Icons/4bb.png[/img]",
		"[r]": "[img]res://Images/Icons/Fire.png[/img]",
		"[g]": "[img]res://Images/Icons/Wood.png[/img]",
		"[b]": "[img]res://Images/Icons/Water_Small.png[/img]",
		"[m]": "[img]res://Images/Icons/Metal.png[/img]",
		"[e]": "[img]res://Images/Icons/Earth.png[/img]",
		"- {/n}": "",
		"{/n}": "[p]",
		"- ": "",
		"  ": " ",
		"/[": "["
	
	}
	
	var card_text = card_resource['abilities']
	
	# Loop through each key-value pair in the dictionary
	for key in icon_replacements.keys():
		# Replace all occurrences of the key in the string with its value
		card_text = card_text.replace(key, icon_replacements[key])
	
	card_text = remove_reminder_text(card_text)
	ability = card_text
	card_ability.text = card_text

func remove_reminder_text(text):
	var regex = RegEx.new()
	# Pattern to match content starting with {i} until {/i} or end of the string
	var pattern = "\\{i\\}.*?(\\{/i\\}|$)"
	# Compile the pattern
	regex.compile(pattern)
	# Replace matches with an empty string
	return regex.sub(text, "", true)


func get_created_quantity(creation_info):
	if "three" in creation_info:
		return 3
	elif "two" in creation_info:
		return 2
	else:
		return 1

func get_created_location(creation_info):
	return "Board"

func get_created_stats(creation_info):
	var statline = creation_info.split(' unit')[0].split(' ')[-1]
	var stats = statline.split('/')
	return stats
	
func get_created_xval(creation_info):
	var options = ['fireball', 'crystal', 'poison', 'robot']
	var token_info = []
	for option in options:
		if option in creation_info:
			var xval = creation_info.split(option + ' ')[1].split(' ')[0]
			token_info.append({"Name": option, "Value": xval})
	return token_info

func get_created_unit_token_type():
	var token_images = {
		"Fireball": "res://Images/Special Tokens/Fireball.png",
		"Poison": "res://Images/Special Tokens/Poison.png",
		"Crystal": "res://Images/Special Tokens/Crystal.png",
		"Robot": "res://Images/Special Tokens/Robot.png",
		"Wisp": "res://Images/Special Tokens/Wisp.png",
		"Shard": "res://Images/Shard_Resource.jpg",
		"Hooba": "res://Images/Unit Tokens/Hooba.png",
		"Structure": "res://Images/Unit Tokens/Structure.png",
		#"Banana": "",
		"Apple": "res://Images/Unit Tokens/Apple.png",
		"Alien": "res://Images/Unit Tokens/Alien.png",
		"Arcane": "res://Images/Unit Tokens/Arcane.png",
		"Axolotl": "res://Images/Unit Tokens/Axolotl.png",
		"Cloud": "res://Images/Unit Tokens/Cloud.png",
		"Cosmic": "res://Images/Unit Tokens/Cosmic.png",
		"Flower": "res://Images/Unit Tokens/Flower.png",
		"Plant": "res://Images/Unit Tokens/Plant.png",
		"Fungus": "res://Images/Unit Tokens/Fungus.png",
		"Horror": "res://Images/Unit Tokens/Horror.png",
		"Luminary": "res://Images/Unit Tokens/Luminary.png",
		"Primordial": "res://Images/Unit Tokens/Primordial.png",
		"Rock": "res://Images/Unit Tokens/Rock.png",
		"Tree": "res://Images/Unit Tokens/Tree.png",
		"Generic": "res://Images/Unit Tokens/Generic.png",
	}
	
	for token_image in token_images.keys():
		if token_image.to_lower() in cardtype.to_lower():
			return {"Image": token_images[token_image], "Name": token_image.to_lower()}
	return {"Image": token_images["Generic"], "Name": "Generic".to_lower()}
	

func get_created_special_token_type(name):
	var token_images = {
		"fireball": "res://Images/Special Tokens/Fireball.png",
		"poison": "res://Images/Special Tokens/Poison.png",
		"crystal": "res://Images/Special Tokens/Crystal.png",
		"robot": "res://Images/Special Tokens/Robot.png",
		"wisp": "res://Images/Special Tokens/Wisp.png",
		"shard": "res://Images/Shard_Resource.jpg",
	}
	
	return token_images[name.to_lower()]

func get_created_token_params(thing_to_create, creation_info):
	var quantity = get_created_quantity(creation_info)
	
	if thing_to_create == "unit":
		var location = get_created_location(creation_info)
		var stats = get_created_stats(creation_info)
		var info = get_created_unit_token_type()
		return {"Power": stats[0], "Toughness": stats[1], 'Quantity': quantity, 'Type': info['Image'], 'location': location, "Name": info['Name']}
	elif thing_to_create in ['copy']:
		pass
	elif thing_to_create == 'wisp':
		var type = get_created_special_token_type(thing_to_create)
		return {"Quantity": quantity, "Type": type, "Name": "wisp"}
	elif thing_to_create == 'shard':
		var type = get_created_special_token_type(thing_to_create)
		return {"Quantity": quantity, "Type": type, "Name": 'shard'}
	elif thing_to_create in ['fireball', 'crystal', 'poison', 'robot']:
		var token_info = get_created_xval(creation_info)
		var type = get_created_special_token_type(token_info[0]['Name'])
		return {"Xval": token_info[0]['Value'], "Type": type, "Quantity": quantity, "Name": token_info[0]['Name']}
	

func get_created_tokens():
	var things_to_create = {
		"fireball": {},
		"crystal": {},
		"poison": {},
		"unit": {},
		"copy": {},
		"robot": {},
		"wisp": {},
		"shard": {},
	}
	
	var ability = card_ability.text.to_lower()
	var created_token_list = []
	if "create" in ability:
		#something is created
		
		var creation_info = ability.split('create')[1].split('.')[0]
		for thing_to_create in things_to_create.keys():
			if thing_to_create in creation_info:
				
				created_token_list.append(thing_to_create)
		#print(creation_info)
		if len(created_token_list) > 0:
			var token_params = get_created_token_params(created_token_list[0], creation_info)
			created_tokens.append(token_params)
		
func create_my_token():
	if created_tokens != []:
		var target_node = get_parent()
		spawn_token(created_tokens[0], target_node)

func spawn_token(token, target_node):

	for i in range(token['Quantity']):
		var c = card.instantiate()
		
		target_node.add_child(c)
		c.affinity_requirement = affinity_requirement
		c.setup_token(token)
		c.position = position
		c.position.y = -2
		c.rotation = rotation
		c.token = true
		
		c.move_node(target_node)
		#target_node.add_child(c)
		

func setup_token(token_info):
	var spell_tokens = ['fireball', 'crystal', 'poison']
	if not is_inside_tree():
		await ready
	card_name.text = token_info['Name'].capitalize()
	card_art.material_override.set("albedo_texture", load(token_info['Type']))
	card_cost.text = str(0)
	card_cost_box.hide()
	card_art.mesh = load("res://cut_card_mesh.obj")
	Title_sprite.hide()
	token_info['affinity_requirement'] = affinity_requirement
	if "Power" in token_info:
		card_power.text = str(token_info['Power'])
		card_toughness.text = str(token_info['Toughness'])
		ability_box.hide()
		card_power_box.show()
		card_toughness_box.show()
		is_unit = true
	else:
		card_power_box.hide()
		card_toughness_box.hide()
		if token_info['Name'].to_lower() in spell_tokens:
			is_spell_token = true
			#print("Made spell tokens")
	
	if "Xval" in token_info:
		update_counters_on_card(int(token_info["Xval"]))
	
	set_box_colors(token_info, true)
	
func setup_card(card_resource) -> void:
	if not is_inside_tree():
		await ready
	#resource = card_resource
	#berry_cost = card_resource.berry_cost
	#stomp_cost = card_resource.stomp
	#print()
	card_name.text = card_resource['name']
	check_if_unit(card_resource)
	var typetext = get_timing_from_type(card_resource['type'])
	cardtype  = typetext
	
	card_type.text = typetext
	if timing != null:
		var timing_image = load(timing)
		#print(timing)
		Timing.texture = timing_image
		Timing_box.show()
		#card_power.position.x = 0.4
	#card_power.text = str(card_resource.card_power)
	
	card_power.text = str(card_resource['power']) 
	set_card_text(card_resource)
	
	resize_ability_box()
	card_toughness.text = str(card_resource['defense'])
	#card_power.text = str(card_resource['power']) + '/' + str(card_resource['defense'])
	card_cost.text = str(card_resource['mana cost'])
	
	get_mod_timing()
	if mod_timing != null:
		var mod_timing_image = load(mod_timing)
		#print(timing)
		Mod_Timing.texture = mod_timing_image
		#Mod_Timing_box.show()
	#card_toughness.text = str(card_resource.card_toughness)
	#card_abilities = card_resource.abilities
	#print(card_resource['image'])
	resize_title_to_fit()
	#resize_type_to_fit()
	set_box_colors(card_resource, false)
	set_box_colors(card_resource, true)
	set_affinity(card_resource['affinity_requirement'])
	affinity_requirement = card_resource['affinity_requirement']
	get_created_tokens()
	card_art.material_override.set("albedo_texture", load(card_resource['image']))
	
func update_counters_on_card(new_counter):
	
	var textures = {
		"Plus": "res://Images/Icons/Plus_Counter.png",
		"Minus": "res://Images/Icons/Minus_Counter.png",
	}
	
	if new_counter == 0: #no counters
		Counters_Amount.text = str(new_counter)
		Counters.hide()
	elif new_counter > 0: #show +1/+1 counter
		Counters.show()
		var new_texture = load(textures['Plus'])
		Counters.texture = new_texture
		Counters_Amount.text = "+" + str(new_counter)

	else: # show -1/-1 counter
		Counters.show()
		var new_texture = load(textures['Minus'])
		Counters.texture = new_texture
		Counters_Amount.text = str(new_counter)
	counters_total = new_counter
		
func add_plus_counter():
	var current_counter = int(Counters_Amount.text.replace('+', ''))
	var updated_counter = current_counter + 1
	update_counters_on_card(updated_counter)
	
func add_minus_counter():
	var current_counter = int(Counters_Amount.text.replace('+', ''))
	var updated_counter = current_counter - 1
	update_counters_on_card(updated_counter)

func _on_hover_timer_timeout():
	#emit_signal("card_hover_timer", self)
	

	if !is_in_hand():
	#if !is_in_hand() and !is_on_the_stack():
		#remove_trigger_outlines()
		#remove_trigger_source_outlines()
		
		inspect_hovered = true
		CardInspect.show_hover_detail(self)

func end_hover_effect():
	
	inspect_hovered = false
	CardInspect.remove_hover_detail()
	#draw_line_to_trigger_source()
	
