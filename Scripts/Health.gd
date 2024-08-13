extends Node
@onready var player_life = $Life_Total
#var player_life
#var opponent_life
# Called when the node enters the scene tree for the first time.
func _ready():
	#player_life = get_node("Player_Life/Life_Total")
	#opponent_life = get_node("Opponent_Life/Life_Total")
	update_player_health_display()


func update_player_health_display():
	var player_life_total = GameState.game_state['Player']['Life']
	player_life.text = str(player_life_total)
	
	var opponent_life_total = GameState.game_state['Opponent']['Life']
	#opponent_life.text = str(opponent_life_total)
