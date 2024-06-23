extends Node

const drop = preload("res://item/drop.tscn")

@onready var player = $Player


func add_drop(category, item_id, amount, pos):
	var drop = drop.instantiate()
	drop.init_drop(category, item_id, amount)
	drop.global_position = pos
	add_child(drop)
	# TODO don't bury
	# TODO rename drop


func _on_drop_item(category, item_id, amount):
	var direction = int(player.sprite.flip_h) - 0.5
	var distance = direction * Vector2.LEFT * 384
	add_drop(category, item_id, amount, player.global_position + distance)
	# TODO get player size
	# TODO while walking


func _on_level_erased(tile_id, pos):
	add_drop(Common.ItemCategory.TILE, tile_id, 1, pos)
