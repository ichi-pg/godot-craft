extends TextureRect

class_name Item

enum Category {
	NULL,
	TILE,
}

var category = Category.NULL
var item_id = 0
var amount = 0

@onready var label = $Label


func init(_category, _item_id, _amount):
	category = _category
	item_id = _item_id
	amount = _amount
	$Label.text = str(amount)
	match category:
		Category.NULL:
			texture = null
			size = Vector2(128, 128)
		Category.TILE:
			var atlas = Level.texture.duplicate() as AtlasTexture
			var coord = Level.get_tile_coord(item_id)
			atlas.region = Rect2(coord * 128, Vector2i(128, 128))
			texture = atlas
			# TODO free or cache


func increment(_amount):
	amount = max(amount + _amount, 0)
	label.text = str(amount)
