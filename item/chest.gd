extends ColorRect

var opened_chest_id = 0
var chests = {}


func _ready():
	visible = false


func _on_chest_opened(chest_id, capacity):
	visible = not visible
	if not chests.has(chest_id):
		chests[chest_id] = {}
		chests[chest_id].capacity = capacity
	opened_chest_id = chest_id
	# TODO Subscribe erase chest.
