extends TextureRect

class_name Item

var item_id = 0
var amount = 0

@onready var label = $Label


func init(id, amount):
	item_id = id
	increment(amount)
	match Common.get_item_category(item_id):
		Common.ItemCategory.TILE:
			var atlas = Common.level_texture.duplicate() as AtlasTexture
			var coord = Common.get_tile_coord(item_id)
			atlas.region = Rect2(coord * 128, Vector2i(128, 128))
			texture = atlas


func increment(value):
	amount = max(amount + value, 0)
	label.text = str(amount)
