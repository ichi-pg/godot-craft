extends Node

const drop = preload("res://item/drop.tscn")

@onready var player = $Player


func _on_drop_item(category, item_id, amount):
	var drop = drop.instantiate()
	drop.init(category, item_id, amount)
	var direction = int(player.sprite.flip_h) - 0.5
	var offset = direction * Vector2.LEFT * 256
	# TODO get player size
	drop.global_position = player.global_position + offset
	add_child(drop)
	# TODO don't bury
