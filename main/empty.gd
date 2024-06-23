extends ColorRect

signal drop_item(category, item_id, amount)


func _can_drop_data(at_position, data):
	return data is Item


func _drop_data(at_position, item):
	drop_item.emit(item.category, item.item_id, item.amount)
	item.get_inventory().remove_item(item)
