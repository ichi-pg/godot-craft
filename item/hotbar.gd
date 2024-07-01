extends ColorRect

signal selected(category, item_id)
signal overflowed(category, item_id, amount)
signal item_pushed_out(category, item_id, amount)

const Item = preload("res://item/item.tscn")
const CAPACITY = 10

var select_index = 0
var is_mini_map_mouse_entered = false

@onready var container = $GridContainer
@onready var selector = $Selector


func _ready():
	for i in range(CAPACITY):
		var item = Item.instantiate()
		item.init_item_data(self, Common.ItemCategory.NULL, 0, 0)
		item.swapped.connect(_on_item_swapped)
		item.pushed.connect(_on_item_pushed_out.bind(item))
		container.add_child(item)
	select_item(0)
	# HACK be able to responsive if use FlowContainer


func _input(event):
	# NOTE Do only one which these actions.
	for i in range(CAPACITY):
		if event.is_action_pressed("hotbar_%d"%i):
			select_item(i)
			return
	if is_mini_map_mouse_entered:
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
	overflowed.emit(category, item_id, amount)


func remove_item(item):
	assert(item.get_parent() == container)
	item.set_item_data(Common.ItemCategory.NULL, 0, 0)
	select_item(select_index)
	return item


func _on_player_picked_up(category, item_id, amount):
	Common.increment_or_add_item(self, category, item_id, amount)


func _on_tile_placed(tile_id, map_pos):
	Common.decrement_or_remove_item(self, Common.ItemCategory.TILE, tile_id, 1)
	# FIXME selected item is primary


func _on_item_swapped():
	select_item(select_index)


func _on_item_pushed_out(item):
	Common.push_out_item(self, item)
	# FIXME can't push if closed inventory


func _on_item_pushed_in(category, item_id, amount):
	Common.increment_or_add_item(self, category, item_id, amount)


func _on_mini_map_mouse_entered():
	is_mini_map_mouse_entered = true


func _on_mini_map_mouse_exited():
	is_mini_map_mouse_entered = false
