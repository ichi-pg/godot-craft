extends ColorRect

signal overflowed(category, item_id, amount)
signal item_pushed(category, item_id, amount)

var chests = {}
var chest_id = 0
var capacity = 0

@onready var container = $GridContainer


func _ready():
	visible = false


func _input(event):
	if event.is_action_pressed("open_inventory"):
		visible = false


func _on_chest_opened(chest_id, capacity):
	if not chests.has(chest_id):
		chests[chest_id] = {}
	self.chest_id = chest_id
	self.capacity = capacity
	visible = true
	# TODO Subscribe erase chest.


func add_item(category, item_id, amount):
	Common.add_item_instance(self, category, item_id, amount)


func remove_item(item):
	Common.remove_item_instance(self, item)
	return null


func _can_drop_data(at_position, data):
	return data is Item


func _drop_data(at_position, item):
	add_item(item.category, item.item_id, item.amount)


func _on_item_pushed(item: Item):
	Common.push_item(self, item)
