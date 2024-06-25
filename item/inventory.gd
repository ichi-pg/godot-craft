extends ColorRect

class_name Inventory

signal overflowed(category, item_id, amount)
signal item_pushed(category, item_id, amount)

var capacity = 30

@onready var container = $GridContainer


func _ready():
	visible = false
	# TODO sort
	# TODO bag and resize window


func _input(event):
	if event.is_action_pressed("open_inventory"):
		visible = not visible


func add_item(category, item_id, amount):
	Common.add_item_instance(self, category, item_id, amount)


func remove_item(item):
	Common.remove_item_instance(self, item)
	return null


func _on_hotbar_overflowed(category, item_id, amount):
	Common.increment_or_add_item(self, category, item_id, amount)
	# TODO wich chest


func _can_drop_data(at_position, data):
	return data is Item


func _drop_data(at_position, item):
	add_item(item.category, item.item_id, item.amount)


func _on_item_pushed(item: Item):
	Common.push_item(self, item)


func _on_hotbar_item_pushed(category, item_id, amount):
	Common.increment_or_add_item(self, category, item_id, amount)
	# TODO wich chest
