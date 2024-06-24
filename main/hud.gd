extends CanvasLayer

signal focused(is_focus)
signal item_dropped(category, item_id, amount)

const Item = preload("res://item/item.tscn")

@onready var viewport = get_viewport()
@onready var drag_item = Item.instantiate()


func _on_mouse_entered():
	focused.emit(true)


func _on_mouse_exited():
	focused.emit(false)
 

func _notification(notification_type):
	match notification_type:
		NOTIFICATION_DRAG_BEGIN:
			var data = viewport.gui_get_drag_data()
			if data is Item:
				drag_item.set_item_data(data.category, data.item_id, data.amount)
		NOTIFICATION_DRAG_END:
			if not viewport.gui_is_drag_successful() and drag_item.item_id:
				item_dropped.emit(drag_item.category, drag_item.item_id, drag_item.amount)
			drag_item.set_item_data(Common.ItemCategory.NULL, 0, 0)
