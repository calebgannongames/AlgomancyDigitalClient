extends MeshInstance3D
var draggable = false
var battle_rotation = deg_to_rad(-85)
var target_rotation = 0
var target_location = Vector3(0, 0.001, -4.0)
var base_location = Vector3(0, 0.001, -4.0)
var attack_location = Vector3(-13.0, 0.001, -4.0)
var block_location = Vector3(13.0, 0.001, -4.0)
@onready var target_transform := Transform3D()
#signal bar_position_moved()
var ANIM_SPEED = 12.0
#func _on_area_3d_mouse_entered() -> void:
	#print("Hovered on bar")
	
func _ready():
	target_transform.origin = Vector3(0, 0, -3)

func _input(event: InputEvent):
	if event.is_action_released("click") and draggable == true:
		draggable = false

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click") and not event.double_click:
		draggable = true

func preprocess():
	if draggable:
		var mouse_pos = get_viewport().get_mouse_position()
		var cam = get_viewport().get_camera_3d()
		var origin = cam.project_ray_origin(mouse_pos)
		var normal = cam.project_ray_normal(mouse_pos)
		# Define the plane where the unit should move (constant y)
		var plane = Plane(Vector3(0, 1, 0), 0)
		# Calculate the intersection point of the ray with the plane
		var intersection = plane.intersects_ray(origin, normal)
		#var ray_length = (unit.position.y-cam.position.y)/normal.y
		#var end = origin + normal * ray_length
		position.x = intersection.x
		position.z = intersection.z
		

		

func _process(delta: float) -> void:
	preprocess()
	target_transform.origin = target_location
	target_transform.basis = Basis(Vector3(0, 1, 0), target_rotation)
	transform = transform.interpolate_with(target_transform, ANIM_SPEED * delta)
	
func set_bar_rotation_for_battle():
	#rotation.y = battle_rotation
	target_rotation = battle_rotation
	#target_transform.origin
	#emit_signal("bar_position_moved", target_transform)
func reset_bar_rotation():
	#rotation.y = 0
	target_rotation = 0
	target_location = base_location
	#emit_signal("bar_position_moved", target_transform)
	
func set_bar_position_for_offense():
	target_location = attack_location
	
func set_bar_position_for_defense():
	target_location = block_location

func set_bar_position_during_attacks_by_ratio(ratio):
	var left_buffer = 0.8
	var right_buffer = 0.6
	var min_x = attack_location.x * left_buffer
	var max_x = block_location.x * right_buffer
	var location
	if ratio >= 0.5:
		location = (ratio - 0.5) * max_x*2
	else:
		location = -(ratio - 0.5) * min_x*2
		
	target_location.x = location
