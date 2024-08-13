extends Node3D


signal step_changed(phase, new_step)

@onready var current_phase = 'Preparation'
@onready var current_step = phases[current_phase]['Steps'][0]
var turn_number = 0
var phases = {
	'Preparation': {"Next_Phase": "Battle", "Steps":['Refresh','Draw','Draft', 'Resources', 'Haste']},
	'Battle': {"Next_Phase": "Regroup", "Steps": ['Attack', 'Offensive_Battle', 'Defensive_Battle']},
	'Regroup': {"Next_Phase": "Deployment", "Steps": ['Regroup']},
	'Deployment': {"Next_Phase": "Preparation", "Steps": ['Deployment', 'End_of_Turn']},
}

func next_phase():
	current_phase = phases[current_phase]['Next_Phase']
	current_step = phases[current_phase]['Steps'][0]
	emit_signal("step_changed", current_phase, current_step)
	
func next_step():
	var index = phases[current_phase]['Steps'].find(current_step)
	var next_index = (index + 1) 
	if next_index >= phases[current_phase]['Steps'].size():
		next_phase()
	else:
		current_step = phases[current_phase]['Steps'][next_index]
		emit_signal("step_changed", current_phase, current_step)


