extends ColorRect

class_name Inventory

signal overflowed(category, item_id, amount)
signal item_pushed_out(category, item_id, amount)

var capacity = 30

@onready var container = $GridContainer


func _ready():
	visible = false
	# TODO sort
	# TODO bag and resize window
	# HACK can define base of inventory and chest


func _input(event):
	if event.is_action_pressed("open_inventory"):
		visible = not visible


func _on_chest_opened():
	visible = true


func _on_chest_erased():
	visible = false


func add_item(category, item_id, amount):
	Common.add_item_instance(self, category, item_id, amount)


func remove_item(item):
	Common.remove_item_instance(self, item)
	return null


func _can_drop_data(at_position, data):
	return data is ItemIcon


func _drop_data(at_position, item):
	add_item(item.category, item.item_id, item.amount)


func _on_item_pushed_out(item):
	Common.push_out_item(self, item)


func _on_item_pushed_in(category, item_id, amount):
	Common.increment_or_add_item(self, category, item_id, amount)
