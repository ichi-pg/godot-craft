extends ColorRect

class_name Inventory

signal overflow(category, item_id, amount)

const Item = preload("res://item/item.tscn")

var items = {}

@onready var container = $GridContainer


func _ready():
	visible = false


func _input(event):
	if event.is_action_pressed("inventory_toggle"):
		visible = not visible


func _on_hotbar_overflow(category, item_id, amount):
	increment_item(self, category, item_id, amount, 30)
	# TODO drop


static func increment_item(inventory, category, item_id, amount, max_count) -> Item:
	if not inventory.items.has(category):
		inventory.items[category] = {}
	var items = inventory.items[category] as Dictionary
	if items.has(item_id):
		items[item_id].increment(amount)
		return null
	if inventory.container.get_child_count() >= max_count:
		inventory.overflow.emit(category, item_id, amount)
		return null
	var item = Item.instantiate()
	items[item_id] = item
	inventory.container.add_child(item)
	item.init(category, item_id, amount)
	return item


static func decrement_item(inventory, category, item_id, amount) -> Item:
	if not inventory.items.has(category):
		inventory.items[category] = {}
	var items = inventory.items[category] as Dictionary
	if not items.has(item_id):
		return null
	var item = items[item_id]
	item.increment(-amount)
	if item.amount:
		return null
	items.erase(item_id)
	inventory.container.remove_child(item)
	item.queue_free()
	return item
