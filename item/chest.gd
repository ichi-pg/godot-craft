extends ColorRect

signal overflowed(category, item_id, amount)
signal item_pushed_out(category, item_id, amount)
signal opened()

var chests = {}
var chest_id = 0
var capacity = 0

@onready var container = $GridContainer


func _ready():
	visible = false


func _input(event):
	if event.is_action_pressed("open_inventory"):
		visible = false


func _on_level_interacted(tile_data: TileData, pos: Vector2i):
	if visible:
		return
	capacity = tile_data.get_custom_data("chest_capacity")
	if not capacity:
		return
	# TODO chest id rule
	chest_id = 0
	# HACK can replace opened to visibled
	opened.emit()
	visible = true
	# TODO must drop items when erase tile
	# TODO save multi chests items
	# TODO can't open while opened by a other player


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
