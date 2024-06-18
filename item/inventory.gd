extends ColorRect

signal overflow(item_id, amount)

var items = {}

@onready var container = $GridContainer


func _ready():
	visible = false


func _input(event):
	if event.is_action_pressed("inventory_toggle"):
		visible = not visible


func _on_hotbar_overflow(item_id, amount):
	Common.increment_item(self, item_id, amount, 30)
