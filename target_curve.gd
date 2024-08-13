extends Line2D

@onready var curve := $Curve

#func _ready():
	##pass
	#var card = get_parent()
	#card.card_not_hovered_anymore.connect(self.card_not_hovered_anymore)
	#card.card_hover_timer.connect(self.card_not_hovered_anymore)

func draw_curve(start_pos, end_pos):
	var control_pos = get_control_point(start_pos, end_pos)

	# Clear previous points and prepare the curve
	var curve = Curve2D.new()
	
	curve.add_point(start_pos, control_pos[0])
	curve.add_point(end_pos, control_pos[1])

	# Set the curve to the path
	points = curve.get_baked_points()
	#update_line(line, curve)

func get_distance(start, end):
	return sqrt((start.x - end.x)**2 + (start.y - end.y)**2)

func get_control_point(start_pos, end_pos):
	# Calculates a control point for the arc
	var midpoint = (start_pos + end_pos) / 2
	var direction = (end_pos - start_pos).normalized()
	var perpendicular = Vector2(-direction.y, direction.x)
	var distance = get_distance(start_pos, end_pos)
	var arc_height = -400  # Adjust the height of the arc here
	# if the line is short and pretty flat, we reduce the arc height
	if distance < 600 and (abs(end_pos.x - start_pos.x) > distance/2.0):
		arc_height = -50
	var final_pos = midpoint + perpendicular * arc_height
	
	var relative_start_pos = final_pos - start_pos
	var relative_end_pos = final_pos - end_pos
	return [relative_start_pos, relative_end_pos]
	

