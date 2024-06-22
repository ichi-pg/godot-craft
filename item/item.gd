extends TextureRect

class_name Item

const null_texture = preload("res://main/icon.svg")

var category = Common.ItemCategory.NULL
var item_id = 0
var amount = 0
var base_position = Vector2.ZERO

@onready var label = $Label
@onready var viewport = get_viewport()


func init(_category, _item_id, _amount):
	category = _category
	item_id = _item_id
	amount = _amount
	match category:
		Common.ItemCategory.NULL:
			texture = null_texture
		Common.ItemCategory.TILE:
			texture = Common.get_level_atlas(item_id)
	$Label.text = str(amount)
	$Label.visible = category != Common.ItemCategory.NULL


func increment(_amount):
	amount = max(amount + _amount, 0)
	label.text = str(amount)


func _gui_input(event):
	if Input.is_action_just_pressed("battle_attack"):
		base_position = global_position
	elif Input.is_action_just_released("battle_attack"):
		global_position = base_position
		# TODO get cross item and move child
	elif Input.is_action_pressed("battle_attack"):
		global_position = viewport.get_mouse_position() - size / 2

