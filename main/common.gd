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


func get_item_count(container: Container) -> int:
	# HACK count up
	var item_count = 0
	for item in container.get_children():
		if item.category != ItemCategory.NULL:
			item_count += 1
	return item_count


func increment_item(inventory, category, item_id, amount):
	# NOTE try increment or add. add_item simply add.
	var item = find_item(inventory.container, category, item_id)
	if item:
		item.increment_amount(amount)
		# TODO item's max count
	elif get_item_count(inventory.container) < inventory.max_items:
		inventory.add_item(category, item_id, amount)
	else:
		inventory.overflow.emit(category, item_id, amount)


func decrement_item(inventory, category, item_id, amount):
	# NOTE try decrement or remove. remove_item simply remove.
	var item = find_item(inventory.container, category, item_id)
	if not item:
		push_error("not item")
	elif item.amount > amount:
		item.increment_amount(-amount)
	else:
		inventory.remove_item(item)
