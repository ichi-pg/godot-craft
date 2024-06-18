extends Node

signal selected(item_id)
signal overflow(item_id, amount)

var select_index = 0
var items = {}

@onready var container = $HBoxContainer
@onready var selector = $Selector


func _ready():
	increment_item(Common.get_item_id(101, Common.ItemCategory.TILE), 10)
	select_item(0)


func _input(event):
	if event.is_action_pressed("hotbar_up"):
		select_item(select_index - 1)
	elif event.is_action_pressed("hotbar_down"):
		select_item(select_index + 1)


func select_item(index):
	var count = container.get_child_count()
	select_index = max(min(index, count - 1), 0)
	if not count:
		selected.emit(0)
		return
	var item = container.get_child(select_index)
	selected.emit(item.item_id)
	selector.global_position = item.global_position


func increment_item(item_id, amount):
	Common.increment_item(self, item_id, amount, 10)


func decrement_item(item_id, amount):
	var item = Common.decrement_item(self, item_id, amount)
	if item == container.get_child(select_index):
		selected.emit(0)


func _on_level_erased(tile_id):
	increment_item(Common.get_item_id(tile_id, Common.ItemCategory.TILE), 1)


func _on_level_placed(tile_id):
	decrement_item(Common.get_item_id(tile_id, Common.ItemCategory.TILE), 1)
