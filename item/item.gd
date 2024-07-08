extends Resource

class_name Item

enum Category {
	NULL,
	TILE,
	TOOL,
}

@export var item_id: int
@export var item_name: String
@export var category: Category
@export var coord: Vector2i
@export var atlas: Texture2D

# TODO select atlas from enum
