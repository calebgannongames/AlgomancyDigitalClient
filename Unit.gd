extends Node3D

var draggable = false
var hovered = false
var resource = null
var played = false
@onready var target_transform := Transform3D()
@onready var card_name := $CardName
@onready var card_art := $CardFront
@onready var card_power := $CardPower
@onready var card_toughness := $CardToughness
@onready var cost := $BerryCost
@onready var outline := $Outline
var card = preload("res://card.tscn")
signal card_released()

const ANIM_SPEED := 12.0
func _on_area_3d_mouse_entered() -> void:
	#move_audio.play()
	hovered = true
	outline.visible = true

func _on_area_3d_mouse_exited() -> void:
	outline.visible = false
	hovered = false

func find_camera_pos() -> Vector3:
	var camera = get_viewport().get_camera_3d()
	var unprojected = camera.unproject_position(target_transform.origin)
	# I fiddled with the y coordinate and distance here so the full card is visible
	return camera.project_position(Vector2(unprojected.x, 880), 3.0)


func play_this_card():
	#played = true
	if !played:
		scale = Vector3.ONE
		outline.visible = false
		draggable = false
		hovered = false
		#print("Card Played Card Trigger")
		emit_signal("card_released", self)


func _input(event: InputEvent):
	if event.is_action_released("click"):
		draggable = false
		play_this_card()
		#print('released')

func _notification(what):
	if what == NOTIFICATION_WM_MOUSE_EXIT:
		draggable = false
		hovered = false
		


func _on_area_3d_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		draggable = true
		#print('clicked')
			
	
				

#func _process(delta: float) -> void:
		#transform = transform.interpolate_with(target_transform, ANIM_SPEED * delta)
		#print(position.x)
		#print(target_transform.origin.x)
	#if hovered:
		## card hovered
		#rotation.z = lerp(rotation.z, 0.0, ANIM_SPEED * delta)
		#var view_spot = target_transform 
		#view_spot.origin = find_camera_pos()
		#transform = transform.interpolate_with(view_spot, ANIM_SPEED * delta)
	#else :
	#rotation.x = -90.0

	#print(position)
	#rotation.x = lerp(rotation.x, -180.0, ANIM_SPEED * delta)	

func was_played():
	played = true

func move_node(new_node:Node):
	was_played()
	var become_card = false
	if new_node.name != "Board":
		become_card = true
	var parent = get_parent()
	if become_card:
		#print("Became Card")
		var c = card.instantiate()
		c.setup_card2(self)
		c.position = position
		c.rotation = rotation
		parent.remove_child(self)
		new_node.add_child(c)
	else:
		parent.remove_child(self)
		new_node.add_child(self)


func setup_unit(card_resource) -> void:
	if not is_inside_tree():
		await ready
	#berry_cost = card_resource.berry_cost
	#stomp_cost = card_resource.stomp
	
	card_name.text = card_resource.card_name.text
	card_power.text = card_resource.card_power.text
	#card_toughness.text = str(card_resource.card_toughness.text)
	#card_abilities = card_resource.abilities
	card_art.material_override.set("albedo_texture", card_resource.card_art.material_override.albedo_texture)
	#rotation.x = 0
	
	
