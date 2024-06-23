extends ColorRect


func _can_drop_data(at_position, data):
	return data is Item


func _drop_data(at_position, item):
	item.init(Common.ItemCategory.NULL, 0, 0)
	# TODO from inventory
	# TODO drop
