extends Node

var game_state = {}
var auto_activate_resources = true


var resources = {
	"Fire": {"Name": "Fire Resource", "Status": "Dormant", "Usage": "Available"},
	"Water": {"Name": "Water Resource", "Status": "Dormant", "Usage": "Available"},
	"Wood": {"Name": "Wood Resource", "Status": "Dormant", "Usage": "Available"},
	"Metal": {"Name": "Metal Resource", "Status": "Dormant", "Usage": "Available"},
	"Earth": {"Name": "Earth Resource", "Status": "Dormant", "Usage": "Available"},
	"Prismite": {"Name": "Prismite", "Status": "Dormant", "Usage": "Available"},
	"Shard": {"Name": "Shard Resource", "Status": "Dormant", "Usage": "Available"},
}
# Called when the node enters the scene tree for the first time.
func _ready():
	load_game_state()
	print("Loaded Game State")


func load_game_state():
	var file = FileAccess.open("res://Data/Game_State.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		var json = JSON.new()
		json.parse(json_text)
		game_state = json.data
		file.close()
	else:
		print("Failed to open Game_State.json")
		



	
