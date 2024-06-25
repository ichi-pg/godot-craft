extends Node

signal player_picked_up(category, item_id, amount)
signal hud_focused(is_focus)
signal hotbar_selected(category, item_id)
signal level_placed(tile_id)

const Drop = preload("res://item/drop.tscn")

@onready var player = $Player


func add_drop(category, item_id, amount, pos):
	var drop = Drop.instantiate()
	drop.init_drop(category, item_id, amount)
	drop.global_position = pos
	add_child(drop)
	# TODO don't bury
	# TODO rename drop


func _on_item_dropped(category, item_id, amount):
	var direction = int(player.sprite.flip_h) - 0.5
	var distance = direction * Vector2.LEFT * 384
	add_drop(category, item_id, amount, player.global_position + distance)
	# TODO get player size
	# TODO while walking


func _on_level_erased(tile_id, pos):
	add_drop(Common.ItemCategory.TILE, tile_id, 1, pos)


func _on_player_picked_up(category, item_id, amount):
	player_picked_up.emit(category, item_id, amount)


func _on_hud_focused(is_focus):
	hud_focused.emit(is_focus)


func _on_hotbar_selected(category, item_id):
	hotbar_selected.emit(category, item_id)


func _on_level_placed(tile_id):
	level_placed.emit(tile_id)
