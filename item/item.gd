extends TextureRect

class_name Item

const null_texture = preload("res://main/icon.svg")

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
			texture = null_texture
			modulate.a = 0
			$Label.visible = false
			return
		Common.ItemCategory.TILE:
			texture = Common.get_level_atlas(item_id, 0)
	modulate.a = 1
	$Label.text = str(amount)
	$Label.visible = true


func increment_amount(amount):
	self.amount = max(self.amount + amount, 0)
	label.text = str(self.amount)


func _get_drag_data(at_position):
	if category == Common.ItemCategory.NULL:
		return null
	var item = duplicate()
	item.init_item_data(inventory, category, item_id, amount)
	item.origin = self
	item.position -= size * 0.5
	var preview = Control.new()
	preview.z_index = Common.MAX_Z_INDEX
	preview.add_child(item)
	set_drag_preview(preview)
	# HACK cache
	# TODO disable level target
	# TODO take half
	# TODO quick transfer
	inventory.remove_item(self)
	return item


func _can_drop_data(at_position, data):
	return data is Item


func _drop_data(at_position, item):
	if category == item.category and item_id == item.item_id:
		increment_amount(item.amount)
		return
	if item_id and is_instance_valid(item.origin):
		# HACK is_instance_valid
		item.origin.set_item_data(category, item_id, amount)
	elif item_id:
		# FIXME check full
		item.inventory.add_item(category, item_id, amount)
	set_item_data(item.category, item.item_id, item.amount)
	# FIXME select item in hotbar
