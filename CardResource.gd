extends Resource

@export var card_name: String
@export var card_power := 0
@export var card_toughness := 1
@export var berry_cost := 0
@export var stomp := false
#@export var ability: CardGameManager.abilities = CardGameManager.abilities.GATHERER
#@export var abilities: Array[CardGameManager.abilities] = []
@export var card_art: Texture

func to_str() -> String:
	return card_name
