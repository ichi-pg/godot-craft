extends Resource

class_name Item

enum Category {
	NULL,
	TILE,
	TOOL,
}

@export var category: Category
@export var item_id: int
@export var item_name: String
@export var coord: Vector2i
