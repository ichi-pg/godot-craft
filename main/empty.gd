extends ColorRect


func _can_drop_data(at_position, data):
	return data is Item


func _drop_data(at_position, item):
	item.get_inventory().remove_item(item)
	# TODO create drop
