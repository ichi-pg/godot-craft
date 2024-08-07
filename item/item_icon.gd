extends TextureRect

class_name ItemIcon

signal swapped()
signal pushed()

const NULL_TEXTURE = preload("res://assets/icon.svg")

var category = Item.Category.NULL
var item_id = 0
var amount = 0
var inventory: Control
var dragged: ItemIcon

@onready var label = $Label

# TODO remove category


func init_item_data(inventory, category, item_id, amount):
	self.inventory = inventory
	set_item_data(category, item_id, amount)


func set_item_data(category, item_id, amount):
	self.inventory = inventory
	self.category = category
	self.item_id = item_id
	self.amount = amount
	match category:
		Item.Category.NULL:
			texture = NULL_TEXTURE
			modulate.a = 0
			$Label.visible = false
			return
		Item.Category.TILE:
			texture = Common.get_level_texture(item_id, 0)
	modulate.a = 1
	$Label.text = str(amount)
	$Label.visible = true


func increment_amount(amount):
	assert(self.amount + amount > 0)
	self.amount += amount
	label.text = str(self.amount)


func _gui_input(event):
	if category == Item.Category.NULL:
		return null
	if event.is_action_pressed("push_item"):
		pushed.emit()
		# HACK both run when quick drag
		# FIXME can't catch released shift + click


func _get_drag_data(at_position):
	if category == Item.Category.NULL:
		return null
	var item_icon = duplicate()
	item_icon.position -= size * 0.5
	if Input.is_action_pressed("drag_half") and amount > 1:
		var half_amount = int(amount * 0.5)
		set_item_data(category, item_id, amount - half_amount)
		item_icon.init_item_data(inventory, category, item_id, half_amount)
		item_icon.dragged = self
	else:
		item_icon.init_item_data(inventory, category, item_id, amount)
		item_icon.dragged = inventory.remove_item(self)
	var preview = Control.new()
	preview.z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	preview.add_child(item_icon)
	set_drag_preview(preview)
	# HACK cache
	# TODO one by one
	# TODO bulk push
	return item_icon


func _can_drop_data(at_position, data):
	return data is ItemIcon


func _drop_data(at_position, item_icon):
	drop_item(item_icon.dragged, item_icon, self)


static func drop_item(src, mid, dst):
	# NOTE Merge items if same.
	if dst.category == mid.category and dst.item_id == mid.item_id:
		dst.increment_amount(mid.amount)
		return
	# NOTE Destination item move to other slot.
	if dst.item_id:
		swap_items(src, mid, dst)
	# NOTE Moved item overwrite destination slot.
	dst.set_item_data(mid.category, mid.item_id, mid.amount)
	dst.swapped.emit()


static func swap_items(src, mid, dst):
	# NOTE All item's amount moved from inventory.
	if not src:
		mid.inventory.add_item(dst.category, dst.item_id, dst.amount)
		return
	# NOTE All item's amount moved from hotbar.
	if not src.item_id:
		src.set_item_data(dst.category, dst.item_id, dst.amount)
		src.swapped.emit()
		return
	# NOTE item divided from inventory or hotbar.
	dst.inventory.add_item(dst.category, dst.item_id, dst.amount)
