extends ColorRect

class_name Inventory

signal overflowed(category, item_id, amount)

const Item = preload("res://item/item.tscn")

var max_items = 30

@onready var container = $GridContainer


func _ready():
	visible = false
	# TODO sort
	# TODO bag and resize window


func _input(event):
	if event.is_action_pressed("inventory_toggle"):
		visible = not visible


func add_item(category, item_id, amount):
	if container.get_child_count() >= max_items:
		overflowed.emit(category, item_id, amount)
		return
	var item = Item.instantiate()
	item.init_item_data(self, category, item_id, amount)
	container.add_child(item)


func remove_item(item):
	assert(item.get_parent() == container)
	item.queue_free()
	# HACK get_child_count is miss match?
	return null


func _on_hotbar_overflowed(category, item_id, amount):
	Common.increment_item(self, category, item_id, amount)


func _can_drop_data(at_position, data):
	return data is Item


func _drop_data(at_position, item):
	add_item(item.category, item.item_id, item.amount)
