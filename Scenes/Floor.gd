extends MeshInstance3D
var divider_max = 9.0
var divider_min = -15.0

var divider_x_max = 25.0
var divider_x_min = -25.0
@onready var divider_bar := $Divider_Bar
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func normalize(value, max, min):
	return (value - min)/ (max-min)
	
func update_shader_material():
	var material = get_active_material(0) as ShaderMaterial
	var shader_position = Vector2(normalize(divider_bar.position.x, divider_x_max, divider_x_min), 
	normalize(divider_bar.position.z, divider_max, divider_min)
	)
	var shader_angle = divider_bar.rotation.y 
	#var window_size = DisplayServer.window_get_size()
	var mesh_size = get_aabb().size
	var aspect_ratio = mesh_size[0]/mesh_size[2]
	var direction = Vector2(sin(shader_angle)*aspect_ratio, cos(shader_angle))
	material.set_shader_parameter("divider_position", shader_position)
	material.set_shader_parameter("divider_direction", direction)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_shader_material()
