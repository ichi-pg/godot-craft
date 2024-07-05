extends Node

signal player_picked_up(category, item_id, amount)
signal hud_focused(is_focus)
signal hotbar_selected(category, item_id)
signal tile_erased(tile_id, map_pos, world_pos)
signal tile_placed(tile_id, map_pos)
signal tile_interacted(tile_data, map_pos)
signal player_moved(pos)
signal level_readied(tile_map)

const DropItem = preload("res://world/drop_item.tscn")

@onready var player = $Player


func add_drop_item(category, item_id, amount, pos):
	var drop_item = DropItem.instantiate()
	drop_item.init_drop_item_data(category, item_id, amount)
	drop_item.global_position = pos
	add_child(drop_item)
	# TODO don't bury


func _on_item_dropped(category, item_id, amount, pos):
	if not pos:
		var direction = int(player.sprite.flip_h) - 0.5
		var distance = direction * Vector2.LEFT * 384
		pos = player.global_position + distance
	add_drop_item(category, item_id, amount, pos)
	# TODO get player size
	# TODO while walking


func _on_tile_erased(tile_id, map_pos, world_pos):
	add_drop_item(Item.Category.TILE, tile_id, 1, world_pos)
	tile_erased.emit(tile_id, map_pos, world_pos)


func _on_player_picked_up(category, item_id, amount):
	player_picked_up.emit(category, item_id, amount)


func _on_hud_focused(is_focus):
	hud_focused.emit(is_focus)


func _on_hotbar_selected(category, item_id):
	hotbar_selected.emit(category, item_id)


func _on_tile_placed(tile_id, map_pos):
	tile_placed.emit(tile_id, map_pos)


func _on_tile_interacted(tile_data, map_pos):
	tile_interacted.emit(tile_data, map_pos)


func _on_player_moved(pos):
	player_moved.emit(pos)


func _on_level_readied(tile_map):
	level_readied.emit(tile_map)
