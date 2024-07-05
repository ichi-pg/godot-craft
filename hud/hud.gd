extends CanvasLayer

signal focused(is_focus)
signal item_dropped(category, item_id, amount, pos)
signal hotbar_selected(category, item_id)
signal player_picked_up(category, item_id, amount)
signal tile_erased(tile_id, map_pos, world_pos)
signal tile_placed(tile_id, map_pos)
signal tile_interacted(tile_data, map_pos)
signal player_moved(pos)
signal level_readied(tile_map)

const ItemIcon = preload("res://item/item_icon.tscn")

var is_mouse_entered = false

@onready var viewport = get_viewport()
@onready var drag_item = ItemIcon.instantiate()
@onready var hotbar = $Hotbar
@onready var chest = $Chest


func _on_mouse_entered():
	is_mouse_entered = true
	focus()


func _on_mouse_exited():
	is_mouse_entered = false
	focus()
 

func _notification(notification_type):
	match notification_type:
		NOTIFICATION_DRAG_BEGIN:
			var data = viewport.gui_get_drag_data()
			if data is ItemIcon:
				drag_item.set_item_data(data.category, data.item_id, data.amount)
			focus()
		NOTIFICATION_DRAG_END:
			if not viewport.gui_is_drag_successful() and drag_item.item_id:
				item_dropped.emit(drag_item.category, drag_item.item_id, drag_item.amount, Vector2.ZERO)
			drag_item.set_item_data(Item.Category.NULL, 0, 0)
			focus()


func focus():
	focused.emit(is_mouse_entered or viewport.gui_is_dragging())


func _on_item_dropped(category, item_id, amount, pos):
	item_dropped.emit(category, item_id, amount, pos)


func _on_hotbar_selected(category, item_id):
	hotbar_selected.emit(category, item_id)


func _on_player_picked_up(category, item_id, amount):
	player_picked_up.emit(category, item_id, amount)
	# NOTE push in to hotbar because want to use soon (vs inventory)


func _on_tile_placed(tile_id, map_pos):
	tile_placed.emit(tile_id, map_pos)


func _on_inventory_item_pushed_out(category, item_id, amount):
	# HACK Want each nodes to subscribe, but it's complicated.
	if chest.visible:
		chest._on_item_pushed_in(category, item_id, amount)
	else:
		hotbar._on_item_pushed_in(category, item_id, amount)
	# NOTE hotbar <---> inventory : if chest disabled
	# NOTE hotbar ---> chest, inventory <---> chest : if chest visibled
	# NOTE overflow ---> inventory ---> drop : always


func _on_tile_interacted(tile_data, map_pos):
	tile_interacted.emit(tile_data, map_pos)


func _on_tile_erased(tile_id, map_pos, world_pos):
	tile_erased.emit(tile_id, map_pos, world_pos)


func _on_player_moved(pos):
	player_moved.emit(pos)


func _on_level_readied(tile_map):
	level_readied.emit(tile_map)
