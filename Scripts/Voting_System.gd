extends Control
var max_votes = 3
var vote_text_labels = {}
var vote_history = []

func _ready():
	# Iterate through the children of "Element_Voting", which are "WoodBanner" and "FireBanner"
	for element in get_children():
		if element is Button:
			if element.name=="Confirm_Vote":
					element.pressed.connect(self._on_Confirm_Vote_pressed)
		# Now iterate through the children of each banner to find the buttons
		for item in element.get_children():
			if item is Button:
				item.pressed.connect(self._on_pressed.bind(item))
			elif item.name == "VoteValue":
				vote_text_labels[element.name] = item
				
				


				

func get_category_from_button_name(button_name:String):
	var category = button_name.split("_")[0]
	return category
func get_vote_from_button_name(button_name:String):
	var vote_value: int
	var category = get_category_from_button_name(button_name)
	if "Upvote" in button_name:
		vote_value = 1
	elif "Downvote" in button_name:
		vote_value = -1
	return [category, vote_value]

func find_cancelling_votes(vote_button_name:String):
	var vote_info = get_vote_from_button_name(vote_button_name)
	for vote in vote_history:
		var vote_history_info = get_vote_from_button_name(vote)
		#check for two cancelling votes
		if (vote_info[0] == vote_history_info[0]) and (vote_info[1] == - vote_history_info[1]):
			vote_history.erase(vote)
			return "Deleted"
		#Little sketchy, but if we have previous votes that match the current vote
		#we need to delete a different vote type to account for the new one
		#otherwise votes can update but not change the display	
		#probably a better way to do this
		elif (vote_info[0] == vote_history_info[0]):
			for vote2 in vote_history:
				var vote_history_info2 = get_vote_from_button_name(vote2)
				if vote_info[0] != vote_history_info2[0]:
					vote_history.erase(vote2)
	return "Unchanged"
	
func update_vote_history(button_name: String):
	var status = find_cancelling_votes(button_name)
	if status == "Unchanged":
		if len(vote_history) >= max_votes:
			vote_history.pop_front()
		vote_history.append(button_name)
		

func update_vote_counts(vote, vote_counts):
	var result = get_vote_from_button_name(vote)
	vote_counts[result[0]] += result[1]
	return vote_counts

func display_votes():
	
	var vote_counts = {
		"Wood": 0,
		"Fire": 0,
		"Metal": 0,
		"Water": 0,
		"Earth": 0,
		"Init": 0
	}
	# Update the text with vote information
	for vote in vote_history:
		vote_counts = update_vote_counts(vote, vote_counts)
	for element in vote_counts:
		if vote_counts[element] < 0:
			vote_text_labels[element].text = str(vote_counts[element])
		elif vote_counts[element] > 0:
			vote_text_labels[element].text = "+" + str(vote_counts[element])
		else:
			vote_text_labels[element].text = ''	
	
	# Update the text showing remaining votes
	var remaining_votes_label = get_node("Confirm_Vote/Remaining_Votes")
	if remaining_votes_label:
		var remaining_votes = 3 - vote_history.size()
		if remaining_votes >1:
			remaining_votes_label.text = '%d votes remaining' % (remaining_votes)
		elif remaining_votes == 1:
			remaining_votes_label.text = '%d vote remaining' % (remaining_votes)	
		else:
			remaining_votes_label.text = ''
	else:
		print("The node 'Remaining_Votes' was not found.")
func _on_pressed(button):
	update_vote_history(button.name)
	display_votes()
	
func verify_votes():
	return true

func _on_Confirm_Vote_pressed():
	var success = verify_votes()
	if success:
		get_tree().change_scene_to_file("res://Scenes/main.tscn")
		
