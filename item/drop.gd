extends RigidBody2D

var category = Common.ItemCategory.NULL
var item_id = 0
var amount = 0


func init(category, item_id, amount):
	self.category = category
	self.item_id = item_id
	self.amount = amount
	match category:
		Common.ItemCategory.TILE:
			$Sprite2D.texture = Common.get_level_atlas(item_id, 1)
