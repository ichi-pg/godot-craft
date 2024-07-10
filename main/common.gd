extends Node

const ItemIcon = preload("res://item/item_icon.tscn")
const HALF_INT = QUARTER_INT * QUARTER_INT
const QUARTER_INT = 10000
const MAX_INT = 9223372036854775807
const MIN_INT = -9223372036854775808
const MAX_RANGE = HALF_INT
const MIN_RANGE = -HALF_INT

var level_atlas: Texture2D
var level_textures = {}


func get_level_texture(item_id, padding) -> AtlasTexture:
	var index = item_id + padding * HALF_INT
	if level_textures.has(index):
		return level_textures[index]
	var texture = AtlasTexture.new()
	texture.atlas = level_atlas
	var coord = Common.get_tile_coord(item_id)
	# TODO get tile size
	var pos = coord * 128 + Vector2i.ONE * padding
	var size = Vector2i(128 - padding, 128 - padding)
	texture.region = Rect2(pos, size)
	level_textures[index] = texture
	return texture


func get_tile_id(coord: Vector2i) -> int:
	# HACK cache
	return coord.x + coord.y * QUARTER_INT + QUARTER_INT + 1


func get_tile_coord(tile_id: int) -> Vector2i:
	# HACK cache
	return Vector2i(tile_id % QUARTER_INT - 1, int(tile_id / QUARTER_INT) - 1)


func find_item(container: Container, category, item_id) -> ItemIcon:
	# HACK dictionary
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


func push_out_item(inventory, item):
	var category = item.category
	var item_id = item.item_id
	var amount = item.amount
	inventory.remove_item(item)
	inventory.item_pushed_out.emit(category, item_id, amount)


func add_item_instance(inventory, category, item_id, amount):
	if inventory.container.get_child_count() >= inventory.capacity:
		inventory.overflowed.emit(category, item_id, amount)
		return
	var item = ItemIcon.instantiate()
	item.init_item_data(inventory, category, item_id, amount)
	item.pushed.connect(inventory._on_item_pushed_out.bind(item))
	inventory.container.add_child(item)


func remove_item_instance(inventory, item):
	assert(item.get_parent() == inventory.container)
	# NOTE To set zero is important if increment at the same time.
	item.set_item_data(Item.Category.NULL, 0, 0)
	item.queue_free()
	# HACK get_child_count is miss match?
