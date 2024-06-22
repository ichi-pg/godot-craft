extends TextureRect

class_name Item

const null_texture = preload("res://main/icon.svg")

static var dragged_item: Item
static var entered_item: Item

var category = Common.ItemCategory.NULL
var item_id = 0
var amount = 0
var base_position = Vector2.ZERO

@onready var label = $Label
@onready var viewport = get_viewport()


func init(category, item_id, amount):
	self.category = category
	self.item_id = item_id
	self.amount = amount
	match category:
		Common.ItemCategory.NULL:
			texture = null_texture
		Common.ItemCategory.TILE:
			texture = Common.get_level_atlas(item_id)
	$Label.text = str(amount)
	$Label.visible = category != Common.ItemCategory.NULL


func increment(amount):
	self.amount = max(self.amount + amount, 0)
	label.text = str(self.amount)


func swap_items(item):
	if not item:
		return
	var category = self.category
	var item_id = self.item_id
	var amount = self.amount
	init(item.category, item.item_id, item.amount)
	item.init(category, item_id, amount)


func _gui_input(event):
	if category == Common.ItemCategory.NULL:
		return
	if Input.is_action_just_pressed("battle_attack"):
		base_position = global_position
		dragged_item = self
	elif Input.is_action_just_released("battle_attack"):
		global_position = base_position
		swap_items(entered_item)
		# TODO drop on level
		# TODO drop on inventory
		dragged_item = null
		entered_item = null
	elif Input.is_action_pressed("battle_attack"):
		global_position = viewport.get_mouse_position() - size * 0.5


func _input(event):
	# TODO can be simply
	if dragged_item == null:
		return
	if dragged_item == self:
		return
	if not event is InputEventMouseMotion:
		return
	if get_global_rect().has_point(viewport.get_mouse_position()):
		entered_item = self
