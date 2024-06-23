extends Node

signal selected(category, item_id)
signal overflow(category, item_id, amount)

const Item = preload("res://item/item.tscn")

var select_index = 0

@onready var container = $HBoxContainer
@onready var selector = $Selector


func _ready():
	for i in range(10):
		var item = Item.instantiate()
		item.init(Common.ItemCategory.NULL, 0, 0)
		container.add_child(item)
	increment_item(Common.ItemCategory.TILE, 101, 10)
	select_item(0)


func _input(event):
	for i in range(10):
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


func increment_item(category, item_id, amount):
	if Common.increment_item(self, category, item_id, amount, 10):
		select_item(select_index)


func decrement_item(category, item_id, amount):
	if Common.decrement_item(self, category, item_id, amount):
		select_item(select_index)


func add_item(category, item_id, amount) -> Item:
	for item in container.get_children():
		if not item.item_id:
			item.init(category, item_id, amount)
			return item
	return null


func remove_item(item):
	item.init(Common.ItemCategory.NULL, 0, 0)


func _on_level_erased(tile_id):
	increment_item(Common.ItemCategory.TILE, tile_id, 1)
	# TODO from drop

func _on_level_placed(tile_id):
	decrement_item(Common.ItemCategory.TILE, tile_id, 1)
