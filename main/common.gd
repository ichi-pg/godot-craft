extends Node

enum ItemCategory {
	NULL,
	TILE,
}

const Item = preload("res://item/item.tscn")
const HALF_OF_INDEX = QUARTER_OF_INDEX * QUARTER_OF_INDEX
const QUARTER_OF_INDEX = 10000
const MAX_INT = 9223372036854775807
const MAX_Z_INDEX = 4096

var level_texture: AtlasTexture = AtlasTexture.new()
var level_atlas = {}


func get_level_atlas(item_id, padding) -> AtlasTexture:
	var index = item_id + padding * HALF_OF_INDEX
	if level_atlas.has(index):
		return level_atlas[index]
	var atlas = Common.level_texture.duplicate() as AtlasTexture
	var coord = Common.get_tile_coord(item_id)
	# TODO get tile size
	var pos = coord * 128 + Vector2i.ONE * padding
	var size = Vector2i(128 - padding, 128 - padding)
	atlas.region = Rect2(pos, size)
	level_atlas[index] = atlas
	return atlas


func get_tile_id(coord: Vector2i) -> int:
	# HACK cache
	return coord.x + coord.y * QUARTER_OF_INDEX + QUARTER_OF_INDEX + 1


func get_tile_coord(tile_id: int) -> Vector2i:
	# HACK cache
	return Vector2i(tile_id % QUARTER_OF_INDEX - 1, int(tile_id / QUARTER_OF_INDEX) - 1)


func find_item(container: Container, category, item_id) -> Item:
	# HACK Dictionary
	for item in container.get_children():
		if item.category == category and item.item_id == item_id:
			return item
	return null


func increment_or_add_item(inventory, category, item_id, amount):
	var item = find_item(inventory.container, category, item_id)
	if item:
		item.increment_amount(amount)
		# TODO item's max amount
	else:
		inventory.add_item(category, item_id, amount)


func decrement_or_remove_item(inventory, category, item_id, amount):
	var item = find_item(inventory.container, category, item_id)
	if item.amount > amount:
		item.increment_amount(-amount)
	else:
		inventory.remove_item(item)


func push_item(inventory, item):
	var category = item.category
	var item_id = item.item_id
	var amount = item.amount
	inventory.remove_item(item)
	inventory.item_pushed.emit(category, item_id, amount)


func add_item_instance(inventory, category, item_id, amount):
	if inventory.container.get_child_count() >= inventory.capacity:
		inventory.overflowed.emit(category, item_id, amount)
		return
	var item = Item.instantiate()
	item.init_item_data(inventory, category, item_id, amount)
	item.pushed.connect(inventory._on_item_pushed.bind(item))
	inventory.container.add_child(item)


func remove_item_instance(inventory, item):
	assert(item.get_parent() == inventory.container)
	# NOTE To set zero is important if increment at the same time.
	item.set_item_data(Common.ItemCategory.NULL, 0, 0)
	item.queue_free()
	# HACK get_child_count is miss match?
