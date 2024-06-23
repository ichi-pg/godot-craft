extends TextureRect

class_name Item

var category = Common.ItemCategory.NULL
var item_id = 0
var amount = 0

@onready var label = $Label


func init(category, item_id, amount):
	self.category = category
	self.item_id = item_id
	self.amount = amount
	match category:
		Common.ItemCategory.NULL:
			$Label.visible = false
			modulate.a = 0
			return
		Common.ItemCategory.TILE:
			texture = Common.get_level_atlas(item_id)
	$Label.text = str(amount)
	$Label.visible = true
	modulate.a = 1


func increment(amount):
	self.amount = max(self.amount + amount, 0)
	label.text = str(self.amount)


func _get_drag_data(at_position):
	if category == Common.ItemCategory.NULL:
		return null
	var item = duplicate()
	item.position -= size * 0.5
	var preview = Control.new()
	preview.modulate.a =  0.5
	preview.z_index = 100
	preview.add_child(item)
	set_drag_preview(preview)
	# TODO cache
	# TODO disable level target
	# TODO self modulate.a
	# TODO split number
	return self


func _can_drop_data(at_position, data):
	return data is Item


func _drop_data(at_position, item):
	var category = self.category
	var item_id = self.item_id
	var amount = self.amount
	init(item.category, item.item_id, item.amount)
	item.init(category, item_id, amount)
	# TODO ignore selector
