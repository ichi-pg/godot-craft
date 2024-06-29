extends Node

signal player_picked_up(category, item_id, amount)
signal hud_focused(is_focus)
signal hotbar_selected(category, item_id)
signal level_erased(tile_id, map_pos, world_pos)
signal level_placed(tile_id, map_pos)
signal level_interacted(tile_data, map_pos)
signal player_moved(pos)
signal level_readied(tile_map)

const Drop = preload("res://item/drop.tscn")

@onready var player = $Player


func add_drop(category, item_id, amount, pos):
	var drop = Drop.instantiate()
	drop.init_drop(category, item_id, amount)
	drop.global_position = pos
	add_child(drop)
	# TODO don't bury
	# TODO rename drop


func _on_item_dropped(category, item_id, amount, pos):
	if not pos:
		var direction = int(player.sprite.flip_h) - 0.5
		var distance = direction * Vector2.LEFT * 384
		pos = player.global_position + distance
	add_drop(category, item_id, amount, pos)
	# TODO get player size
	# TODO while walking


func _on_level_erased(tile_id, map_pos, world_pos):
	add_drop(Common.ItemCategory.TILE, tile_id, 1, world_pos)
	level_erased.emit(tile_id, map_pos, world_pos)


func _on_player_picked_up(category, item_id, amount):
	player_picked_up.emit(category, item_id, amount)


func _on_hud_focused(is_focus):
	hud_focused.emit(is_focus)


func _on_hotbar_selected(category, item_id):
	hotbar_selected.emit(category, item_id)


func _on_level_placed(tile_id, map_pos):
	level_placed.emit(tile_id, map_pos)


func _on_level_interacted(tile_data, map_pos):
	level_interacted.emit(tile_data, map_pos)


func _on_player_moved(pos):
	player_moved.emit(pos)


func _on_level_readied(tile_map):
	level_readied.emit(tile_map)
