extends TextureRect

class_name Item

signal swapped()
signal pushed()

const NULL_TEXTURE = preload("res://main/icon.svg")

var category = Common.ItemCategory.NULL
var item_id = 0
var amount = 0
var inventory: Control
var dragged: Item

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
	if category == Common.ItemCategory.NULL:
		return null
	if event.is_action_pressed("push_item"):
		pushed.emit()
		# HACK both run when quick drag
		# FIXME can't catch released shift + click


func _get_drag_data(at_position):
	if category == Common.ItemCategory.NULL:
		return null
	var item = duplicate()
	item.position -= size * 0.5
	if Input.is_action_pressed("drag_half") and amount > 1:
		var half_amount = int(amount * 0.5)
		set_item_data(category, item_id, amount - half_amount)
		item.init_item_data(inventory, category, item_id, half_amount)
		item.dragged = self
	else:
		item.init_item_data(inventory, category, item_id, amount)
		item.dragged = inventory.remove_item(self)
	var preview = Control.new()
	preview.z_index = Common.MAX_Z_INDEX
	preview.add_child(item)
	set_drag_preview(preview)
	# HACK cache
	# TODO one by one
	# TODO bulk push
	return item


func _can_drop_data(at_position, data):
	return data is Item


func _drop_data(at_position, item):
	drop_item(item.dragged, item, self)


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
	# NOTE Item divided from inventory or hotbar.
	dst.inventory.add_item(dst.category, dst.item_id, dst.amount)
