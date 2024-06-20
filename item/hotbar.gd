extends Node

signal selected(category, item_id)
signal overflow(category, item_id, amount)

var select_index = 0
var items = {}

@onready var container = $HBoxContainer
@onready var selector = $Selector


func _ready():
	increment_item(Item.Category.TILE, 101, 10)
	select_item(0)


func _input(event):
	for i in range(10):
		if event.is_action_pressed("hotbar_%d"%i):
			select_item(i)
	if event.is_action_pressed("hotbar_up"):
		select_item(select_index - 1)
	elif event.is_action_pressed("hotbar_down"):
		select_item(select_index + 1)


func select_item(index):
	var count = container.get_child_count()
	select_index = max(min(index, count - 1), 0)
	if not count:
		selected.emit(Item.Category.NULL, 0)
		return
	var item = container.get_child(select_index)
	selected.emit(item.category, item.item_id)
	selector.global_position = item.global_position


func increment_item(category, item_id, amount):
	if Inventory.increment_item(self, category, item_id, amount, 10):
		select_item(select_index)


func decrement_item(category, item_id, amount):
	if Inventory.decrement_item(self, category, item_id, amount):
		selected.emit(Item.Category.NULL, 0)


func _on_level_erased(tile_id):
	increment_item(Item.Category.TILE, tile_id, 1)
	# TODO pass drop

func _on_level_placed(tile_id):
	decrement_item(Item.Category.TILE, tile_id, 1)
