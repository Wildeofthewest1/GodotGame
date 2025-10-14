extends HBoxContainer

@onready var label := $CurrencyLabel

func _process(_delta):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		label.text = str(player.currency)
