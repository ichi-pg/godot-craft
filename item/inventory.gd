extends ColorRect

class_name Inventory

signal overflowed(category, item_id, amount)
signal item_pushed(category, item_id, amount)

const Item = preload("res://item/item.tscn")

var max_items = 30

@onready var container = $GridContainer


func _ready():
	visible = false
	# TODO sort
	# TODO bag and resize window


func _input(event):
	if event.is_action_pressed("toggle_inventory"):
		visible = not visible


func add_item(category, item_id, amount):
	if container.get_child_count() >= max_items:
		overflowed.emit(category, item_id, amount)
		return
	var item = Item.instantiate()
	item.init_item_data(self, category, item_id, amount)
	item.pushed.connect(_on_item_pushed.bind(item))
	container.add_child(item)


func remove_item(item):
	assert(item.get_parent() == container)
	item.queue_free()
	# HACK get_child_count is miss match?
	return null


func _on_hotbar_overflowed(category, item_id, amount):
	Common.increment_or_add_item(self, category, item_id, amount)
	# TODO can replace to chest


func _can_drop_data(at_position, data):
	return data is Item


func _drop_data(at_position, item):
	add_item(item.category, item.item_id, item.amount)


func _on_item_pushed(item: Item):
	var amount = item.amount
	item_pushed.emit(item.category, item.item_id, amount)
	if amount == item.amount:
		remove_item(item)
	else:
		item.increment_amount(-amount)
	# FIXME lost when full hotbar because merge added item to removes item
	# 1. use decrement instead remove (bat ux and better code)
	# 2. force add when overflowed (best ux and bat code)
	# 3. check amount and remove or decrement (better ux and bat code)
	# 4. increment emit zero signal (better ux and best code)
	# 5. push after remove and fix quere free (best ux and best code)


func _on_hotbar_item_pushed(category, item_id, amount):
	Common.increment_or_add_item(self, category, item_id, amount)
	# TODO can replace to chest
