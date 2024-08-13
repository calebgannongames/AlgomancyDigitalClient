extends Resource

@export var card_list: Array[Resource]


var generated := false
var deck := []:
	get:
		if not generated:
			generated = true
			return generate_cards()
		return deck

func generate_cards() -> Array:
	for res in card_list:
		var card = res.duplicate(true)
		card.set_local_to_scene(true)
		deck.append(card)
	return deck
