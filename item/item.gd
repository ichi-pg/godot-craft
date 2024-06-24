extends TextureRect

class_name Item

signal swapped()
signal pushed()

const NULL_TEXTURE = preload("res://main/icon.svg")

var category = Common.ItemCategory.NULL
var item_id = 0
var amount = 0
var inventory: Control
var origin: Item

@onready var label = $Label


func init_item_data(inventory, category, item_id, amount):
	self.inventory = inventory
	set_item_data(category, item_id, amount)


func set_item_data(category, item_id, amount):
	self.inventory = inventory
	self.category = category
	self.item_id = item_id
	self.amount = amount
	match category:
		Common.ItemCategory.NULL:
			texture = NULL_TEXTURE
			modulate.a = 0
			$Label.visible = false
			return
		Common.ItemCategory.TILE:
			texture = Common.get_level_atlas(item_id, 0)
	modulate.a = 1
	$Label.text = str(amount)
	$Label.visible = true


func increment_amount(amount):
	assert(self.amount + amount > 0)
	self.amount += amount
	label.text = str(self.amount)


func _gui_input(event):
	if event.is_action_released("push_item"):
		pushed.emit()
		# HACK both run when quick drag
		# FIXME push empty to inventory


func _get_drag_data(at_position):
	if category == Common.ItemCategory.NULL:
		return null
	var item = duplicate()
	item.position -= size * 0.5
	if Input.is_action_pressed("pick_half") and amount > 1:
		var half_amount = int(amount * 0.5)
		set_item_data(category, item_id, amount - half_amount)
		item.init_item_data(inventory, category, item_id, half_amount)
		item.origin = self
	else:
		item.init_item_data(inventory, category, item_id, amount)
		item.origin = inventory.remove_item(self)
	var preview = Control.new()
	preview.z_index = Common.MAX_Z_INDEX
	preview.add_child(item)
	set_drag_preview(preview)
	# HACK cache
	# TODO disable level target
	# TODO one by one
	# TODO bulk push
	return item


func _can_drop_data(at_position, data):
	return data is Item


func _drop_data(at_position, item):
	if category == item.category and item_id == item.item_id:
		increment_amount(item.amount)
		return
	if item_id and item.origin:
		item.origin.set_item_data(category, item_id, amount)
		item.origin.swapped.emit()
	elif item_id:
		item.inventory.add_item(category, item_id, amount)
	set_item_data(item.category, item.item_id, item.amount)
	swapped.emit()
	# FIXME lost when half swap
