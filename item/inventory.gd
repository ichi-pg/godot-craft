extends ColorRect

class_name Inventory

signal overflow(category, item_id, amount)

const Item = preload("res://item/item.tscn")

@onready var container = $GridContainer


func _ready():
	visible = false
	# TODO sort


func _input(event):
	if event.is_action_pressed("inventory_toggle"):
		visible = not visible


func add_item(category, item_id, amount) -> Item:
	var item = Item.instantiate()
	item.init(category, item_id, amount)
	container.add_child(item)
	return item


func remove_item(item):
	item.queue_free()
	container.remove_child(item)


func _on_hotbar_overflow(category, item_id, amount):
	Common.increment_item(self, category, item_id, amount, 30)


func _can_drop_data(at_position, data):
	return data is Item


func _drop_data(at_position, item):
	add_item(item.category, item.item_id, item.amount)
	item.get_inventory().remove_item(item)
	# TODO max count
	# TODO stacking
