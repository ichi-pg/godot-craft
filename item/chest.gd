extends ColorRect

var chests = {}


func _ready():
	visible = false


func _on_chest_opened(chest_id, capacity):
	visible = not visible
	if not chests.has(chest_id):
		chests[chest_id] = {}
		chests[chest_id].capacity = capacity
	# TODO Subscribe erase chest.
