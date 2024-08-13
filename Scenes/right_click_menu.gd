extends Control

@onready var drop_down_menu := $PopupMenu
# Called when the node enters the scene tree for the first time.
var card = null

var menu = [
	"Add +1/+1 counter",
	"Add -1/-1 counter",
	"Create trigger",
	"Create token",
	"Erase this card"
]

var functions = [
	"add_plus_counter",
	"add_minus_counter",
	"create_trigger",
	"create_my_token",
	"erase_self"
]

func add_items():
	for item in menu:
		drop_down_menu.add_item(item)
	
func _ready():
	add_items()


func _on_popup_menu_id_pressed(id):
	print("Selected: ", menu[id])
	if card != null:
		card.call(functions[id].to_lower())
	
	#queue_free()

	#queue_free()
		#queue_free()
		#if id == 2:
			#card.create_trigger()
		

