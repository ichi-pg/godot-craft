extends ColorRect

class_name Inventory

signal overflow(category, item_id, amount)

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
	assert(get_child_count() < max_items)
	var item = Item.instantiate()
	item.init_item_data(self, category, item_id, amount)
	container.add_child(item)


func remove_item(item):
	assert(item.get_parent() == container)
	item.queue_free()
	container.remove_child(item)


func _on_hotbar_overflow(category, item_id, amount):
	Common.increment_item(self, category, item_id, amount)


func _can_drop_data(at_position, data):
	return data is Item


func _drop_data(at_position, item):
	# NOTE don't use increment_item.
	if container.get_child_count() < max_items:
		add_item(item.category, item.item_id, item.amount)
	else:
		overflow.emit(item.category, item.item_id, item.amount)
