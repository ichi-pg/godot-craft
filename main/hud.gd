extends CanvasLayer

signal focused(is_focus)
signal item_dropped(category, item_id, amount)
signal hotbar_selected(category, item_id)
signal player_picked_up(category, item_id, amount)
signal level_placed(tile_id)
signal level_interacted(tile_data, pos)

const Item = preload("res://item/item.tscn")

var is_mouse_entering = false

@onready var viewport = get_viewport()
@onready var drag_item = Item.instantiate()
@onready var hotbar = $Hotbar
@onready var chest = $Chest


func _on_mouse_entered():
	is_mouse_entering = true
	focus()


func _on_mouse_exited():
	is_mouse_entering = false
	focus()
 

func _notification(notification_type):
	match notification_type:
		NOTIFICATION_DRAG_BEGIN:
			var data = viewport.gui_get_drag_data()
			if data is Item:
				drag_item.set_item_data(data.category, data.item_id, data.amount)
			focus()
		NOTIFICATION_DRAG_END:
			if not viewport.gui_is_drag_successful() and drag_item.item_id:
				item_dropped.emit(drag_item.category, drag_item.item_id, drag_item.amount)
			drag_item.set_item_data(Common.ItemCategory.NULL, 0, 0)
			focus()


func focus():
	focused.emit(is_mouse_entering or viewport.gui_is_dragging())


func _on_item_dropped(category, item_id, amount):
	item_dropped.emit(category, item_id, amount)


func _on_hotbar_selected(category, item_id):
	hotbar_selected.emit(category, item_id)


func _on_player_picked_up(category, item_id, amount):
	player_picked_up.emit(category, item_id, amount)
	# NOTE push in to hotbar because want to use soon (vs inventory)


func _on_level_placed(tile_id):
	level_placed.emit(tile_id)


func _on_inventory_item_pushed_out(category, item_id, amount):
	# HACK Want each nodes to subscribe, but it's complicated.
	if chest.visible:
		chest._on_item_pushed_in(category, item_id, amount)
	else:
		hotbar._on_item_pushed_in(category, item_id, amount)
	# NOTE hotbar <---> inventory : if chest disabled
	# NOTE hotbar ---> chest, inventory <---> chest : if chest visibled
	# NOTE overflow ---> inventory ---> drop : always


func _on_level_interacted(tile_data, pos):
	level_interacted.emit(tile_data, pos)
