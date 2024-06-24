extends CanvasLayer

signal focused(is_focus)
signal item_dropped(category, item_id, amount)

const Item = preload("res://item/item.tscn")

var is_mouse_entering = false

@onready var viewport = get_viewport()
@onready var drag_item = Item.instantiate()


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
