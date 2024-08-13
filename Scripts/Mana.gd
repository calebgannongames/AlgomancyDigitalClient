extends Node

var player_mana
var opponent_mana
var icon_spacing = 5
var affinity_lookup = {
	"Fire Resource": "Images/fire_icon.png",
	"Water Resource": "Images/water_icon.png",
	"Wood Resource": "Images/wood_icon.png",
	"Earth Resource": "Images/earth_icon.png",
	"Metal Resource": "Images/metal_icon.png"
}



@export var affinity_font: FontFile
# Called when the node enters the scene tree for the first time.
func _ready():
	player_mana = get_node("Player_Mana_Box/Mana_Count")
	opponent_mana = get_node("Opponent_Mana_Box/Mana_Count")
	update_mana_display()

func get_mana_and_dormant_values(resource:Dictionary):
	var dormant = 0
	var mana = 0
	var total_mana = 0
	var status = resource['Status']
	if status == "Dormant":
		dormant = 1
	else:
		total_mana = 1
		if resource['Usage'] == "Available":
			mana = 1
	return {'Dormant': dormant, 'Available Mana': mana, "Total Mana": total_mana}
	
func get_affinity_from_resource(resource:Dictionary):
	var affinity = ''
	var status = resource['Status']
	if status == "Active":
		var resource_name = resource['Name']
		if resource_name in affinity_lookup:
			affinity = affinity_lookup[resource_name]
	return affinity

func get_mana_and_affinity_from_resource(resource:Dictionary):
	var values = get_mana_and_dormant_values(resource)
	var affinity = get_affinity_from_resource(resource)
	values['Affinity'] = affinity
	return values
	

func get_text_from_mana_quantity(mana, total_mana):
	var mana_text = '%d/%d' % ([mana, total_mana])
	return mana_text

func get_mana_and_total_from_resources(resources:Array):
	var available_mana = 0
	var total_mana = 0
	var dormant_mana = 0
	var affinity_dict = {}
	for resource:Dictionary in resources:
		var values = get_mana_and_affinity_from_resource(resource)
		available_mana += values["Available Mana"]
		var affinity = values['Affinity']
		if affinity != '':
			if affinity not in affinity_dict:
				affinity_dict[affinity] = 1
			else:
				affinity_dict[affinity] += 1
		total_mana += values["Total Mana"]
		dormant_mana += values["Dormant"]
	var mana_text = get_text_from_mana_quantity(available_mana, total_mana)

	return {"Affinity": affinity_dict, "Mana_Text": mana_text, "Dormant": dormant_mana}

	

func sort_affinities(affinities):
	var affinity_list = []
	for key in affinities.keys():
		affinity_list.append({"affinity": key, "value": affinities[key]})
	# Sort the array of dictionaries based on the value
	affinity_list.sort_custom(func(a, b):
		return b["value"] < a["value"]
		)
	# Rebuild the sorted affinities dictionary
	var sorted_affinities = {}
	for item in affinity_list:
		sorted_affinities[item["affinity"]] = item["value"]

	return sorted_affinities
 

func draw_specific_affinity(affinities, affinity_box, affinity_label):
	var offset_x = 20
	var icon_width = affinity_box.size.y-10
	if affinities.size() == 0:
		affinity_box.visible = false
		affinity_label.visible = false
	else:
		affinity_box.visible = true
		affinity_label.visible = true
		
		affinities = sort_affinities(affinities)
		
		for affinity in affinities:
			# Create the icon
			var icon = TextureRect.new()
			icon.texture = load("res://%s" % str(affinity))
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.size = Vector2(icon_width, icon_width)  # Set the desired size
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED  # Maintain aspect ratio
			icon.position = Vector2(offset_x, 5)
			affinity_box.add_child(icon)

			# Create the value label
			var label = Label.new()
			label.text = str(affinities[affinity])
			label.size = Vector2(icon_width, icon_width)  # Adjust size as needed
			label.position = Vector2(offset_x, 0)
			label.add_theme_font_override("font", affinity_font)
			label.add_theme_font_size_override("font_size", 18)

			if affinities[affinity]>=3:
				label.add_theme_color_override("font_color", "Gold")
			else:
				label.add_theme_color_override("font_color", "White")
			affinity_label.add_child(label)

			# Update the offset for the next icon and label
			offset_x += icon_spacing + icon_width  # Adjust spacing as needed

		# Adjust the width of the affinity boxes
		affinity_box.size.x = offset_x
		affinity_label.size.x = offset_x
	
func draw_all_affinity(affinities):
	
	var affinity_box = $Affinity/Player_Affinity_Box
	var affinity_label = $Affinity/Player_Affinity_Values
	draw_specific_affinity(affinities[0], affinity_box, affinity_label)
	
	affinity_box = $Affinity/Opponent_Affinity_Box
	affinity_label = $Affinity/Opponent_Affinity_Values
	draw_specific_affinity(affinities[1], affinity_box, affinity_label)
	
func draw_specific_dormant(dormant, box, label):
	if dormant == 0:
		box.visible = false
		label.visible = false
	else:
		box.visible = true
		label.visible = true
		label.text = "+%d" % dormant

func draw_all_dormant(player_dormant, opponent_dormant):
	var dormant_box = $Player_Mana_Box/Player_Dormant_Box
	var dormant_label = $Player_Mana_Box/Player_Dormant_Box/Dormant_Count
	draw_specific_dormant(player_dormant, dormant_box, dormant_label)
	
	dormant_box = $Opponent_Mana_Box/Opponent_Dormant_Box
	dormant_label = $Opponent_Mana_Box/Opponent_Dormant_Box/Opponent_Dormant_Count
	draw_specific_dormant(opponent_dormant, dormant_box, dormant_label)

func update_mana_display():
	var player_resources = GameState.game_state['Player']['Resources']
	var player_mana_info = get_mana_and_total_from_resources(player_resources)
	player_mana.text = player_mana_info['Mana_Text']
	
	
	var opponent_resources = GameState.game_state['Opponent']['Resources']
	var opponent_mana_info = get_mana_and_total_from_resources(opponent_resources)
	opponent_mana.text = opponent_mana_info['Mana_Text']
	
	draw_all_affinity([player_mana_info['Affinity'], opponent_mana_info['Affinity']])
	draw_all_dormant(player_mana_info['Dormant'], opponent_mana_info['Dormant'])
	
