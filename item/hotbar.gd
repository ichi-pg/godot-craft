extends Node

signal selected(category, item_id)
signal overflow(category, item_id, amount)

const Item = preload("res://item/item.tscn")
const MAX_ITEMS = 10

var select_index = 0

@onready var container = $HBoxContainer
@onready var selector = $Selector


func _ready():
	for i in range(MAX_ITEMS):
		var item = Item.instantiate()
		item.init_item_data(self, Common.ItemCategory.NULL, 0, 0)
		container.add_child(item)
	select_item(0)


func _input(event):
	for i in range(MAX_ITEMS):
		if event.is_action_pressed("hotbar_%d"%i):
			select_item(i)
			return
	if event.is_action_pressed("hotbar_up"):
		select_item(select_index - 1)
	elif event.is_action_pressed("hotbar_down"):
		select_item(select_index + 1)


func select_item(index):
	var count = container.get_child_count()
	if not count:
		select_index = 0
		selected.emit(Common.ItemCategory.NULL, 0)
		return
	select_index = index % count
	var item = container.get_child(select_index)
	selected.emit(item.category, item.item_id)
	selector.global_position = item.global_position


func add_item(category, item_id, amount):
	for item in container.get_children():
		if not item.item_id:
			item.set_item_data(category, item_id, amount)
			select_item(select_index)
			return
	overflow.emit(category, item_id, amount)


func remove_item(item):
	assert(item.get_parent() == container)
	item.set_item_data(Common.ItemCategory.NULL, 0, 0)
	select_item(select_index)
	return item


func _on_player_picked_up(category, item_id, amount):
	Common.increment_item(self, category, item_id, amount)


func _on_level_placed(tile_id):
	Common.decrement_item(self, Common.ItemCategory.TILE, tile_id, 1)
	# FIXME selected item is primary
