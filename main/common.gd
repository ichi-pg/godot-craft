extends Node

enum ItemCategory {
	NULL,
	TILE,
}

const Item = preload("res://item/item.tscn")

var level_texture: AtlasTexture = AtlasTexture.new()
var level_atlas = {}


func get_level_atlas(item_id) -> AtlasTexture:
	if level_atlas.has(item_id):
		return level_atlas[item_id]
	var atlas = Common.level_texture.duplicate() as AtlasTexture
	var coord = Common.get_tile_coord(item_id)
	atlas.region = Rect2(coord * 128, Vector2i(128, 128))
	level_atlas[item_id] = atlas
	return atlas


func get_tile_id(coord: Vector2i) -> int:
	# TODO cache
	return coord.x + coord.y * 100 + 101


func get_tile_coord(tile_id: int) -> Vector2i:
	# TODO cache
	return Vector2i(tile_id % 100 - 1, int(tile_id / 100) - 1)


func find_item(container: Container, category, item_id) -> Item:
	# TODO Dictionary
	for item in container.get_children():
		if item.category == category and item.item_id == item_id:
			return item
	return null


func get_item_count(container: Container) -> int:
	# TODO count up
	var item_count = 0
	for item in container.get_children():
		if item.category != ItemCategory.NULL:
			item_count += 1
	return item_count


func increment_item(inventory, category, item_id, amount, max_count) -> Item:
	var item = find_item(inventory.container, category, item_id)
	if item:
		item.increment(amount)
		# TODO item's max count
		return null
	if get_item_count(inventory.container) >= max_count:
		inventory.overflow.emit(category, item_id, amount)
		return null
	return inventory.add_item(category, item_id, amount)


func decrement_item(inventory, category, item_id, amount) -> Item:
	var item = find_item(inventory.container, category, item_id)
	if not item:
		return null
	item.increment(-amount)
	if item.amount:
		return null
	inventory.remove_item(item)
	return item
