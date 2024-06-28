extends ColorRect

signal overflowed(category, item_id, amount)
signal item_pushed_out(category, item_id, amount)
signal item_dropped(category, item_id, amount, pos)
signal opened()

const ChestContainer = preload("res://item/chest_container.tscn")

var container: ChestContainer
var capacity = 0

@onready var margin = $MarginContainer


func _ready():
	visible = false


func _input(event):
	if not visible:
		return
	if event.is_action_pressed("open_inventory"):
		close_chest()


func close_chest():
	visible = false
	container.visible = false
	# HACK it's easy if common always disable
	# HACK it's simple if not use margin
	margin.remove_child(container)
	Common.add_child(container)
	container = null
	capacity = 0


func _on_level_interacted(tile_data, map_pos):
	# HACK open other chest quickly
	if visible:
		return
	capacity = tile_data.get_custom_data("chest_capacity")
	if not capacity:
		return
	container = find_container(map_pos)
	if container:
		Common.remove_child(container)
	else:
		container = ChestContainer.instantiate()
		container.map_position = map_pos
	margin.add_child(container)
	container.visible = true
	visible = true
	opened.emit()
	# TODO player can use items to craft in hidden chests
	# TODO treasure chests already were when world created
	# TODO save and load
	# TODO can't open while opened by a other player
	# TODO share hidden chests with each other players


func find_container(map_pos):
	# HACK dictionary
	for container in Common.get_children():
		if container.map_position == map_pos:
			return container
	return null


func add_item(category, item_id, amount):
	Common.add_item_instance(self, category, item_id, amount)


func remove_item(item):
	Common.remove_item_instance(self, item)
	return null


func _can_drop_data(at_position, data):
	return data is Item


func _drop_data(at_position, item):
	add_item(item.category, item.item_id, item.amount)


func _on_item_pushed_out(item: Item):
	Common.push_out_item(self, item)


func _on_item_pushed_in(category, item_id, amount):
	if not visible:
		overflowed.emit(category, item_id, amount)
		return
	Common.increment_or_add_item(self, category, item_id, amount)


func _on_level_erased(tile_id, map_pos, world_pos):
	if container and container.map_position == map_pos:
		close_chest()
	var container = find_container(map_pos)
	if not container:
		return
	for item in container.get_children():
		item_dropped.emit(item.category, item.item_id, item.amount, world_pos)
	container.queue_free()
