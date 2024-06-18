extends Node

const Item = preload("res://item/item.tscn")

var level_texture: AtlasTexture = null

enum ItemCategory {
	TILE,
}


func get_item_category(item_id: int) -> ItemCategory:
	return int(item_id / 10000)


func get_item_category_id(item_id: int, category: ItemCategory) -> int:
	if get_item_category(item_id) == category:
		return item_id % 10000
	else:
		return 0


func get_item_id(category_id: int, category: ItemCategory) -> int:
	return category_id + category * 10000


func get_tile_id(coord: Vector2i) -> int:
	return coord.x + coord.y * 100 + 101


func get_tile_coord(tile_id: int) -> Vector2i:
	return Vector2i(tile_id % 100 - 1, int(tile_id / 100) - 1)


func increment_item(inventory, item_id: int, amount: int, max_count: int) -> void:
	if inventory.items.has(item_id):
		inventory.items[item_id].increment(amount)
		return
	if inventory.container.get_child_count() >= max_count:
		inventory.overflow.emit(item_id, amount)
		return
	var item = Item.instantiate()
	inventory.items[item_id] = item
	inventory.container.add_child(item)
	item.init(item_id, amount)


func decrement_item(inventory, item_id: int, amount: int) -> Item:
	if not inventory.items.has(item_id):
		return null
	var item = inventory.items[item_id]
	item.increment(-amount)
	if item.amount:
		return null
	inventory.items.erase(item_id)
	item.queue_free()
	return item
