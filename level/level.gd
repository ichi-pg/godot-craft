extends TileMap

signal erased(tile_id)
signal placed(tile_id)

var player_position = Vector2.ZERO
var mouse_position = Vector2.ZERO
var target_map_position = Vector2i.ZERO
var target_tile_id = 0
var select_tile_id = 0
var tile_size = tile_set.tile_size * 0.5

@onready var viewport = get_viewport()
@onready var cursor = $Cursor


func _ready():
	var source = tile_set.get_source(1) as TileSetAtlasSource
	Common.level_texture = AtlasTexture.new()
	Common.level_texture.atlas = source.texture


func _on_player_moved(pos):
	player_position = pos
	update_target()


func _input(event):
	if event is InputEventMouseMotion:
		mouse_position = viewport.get_mouse_position() - viewport.get_visible_rect().size * 0.5
		update_target()
	elif target_map_position == local_to_map(player_position):
		pass
	elif not event.is_action_pressed("battle_attack"):
		pass
	elif target_tile_id:
		# TODO pickaxe
		# TODO block health
		erase_cell(0, target_map_position)
		erased.emit(target_tile_id)
		update_target_tile(0)
	elif select_tile_id:
		# TODO is on floor
		# TODO pass drop
		set_cell(0, target_map_position, 1, Common.get_tile_coord(select_tile_id))
		placed.emit(select_tile_id)
		update_target_tile(select_tile_id)


func update_target():
	var new_target_map_position = local_to_map(mouse_position + player_position)
	if target_map_position == new_target_map_position:
		return
	target_map_position = new_target_map_position
	update_target_tile(Common.get_tile_id(get_cell_atlas_coords(0, target_map_position)))


func update_target_tile(tile_id):
	target_tile_id = tile_id
	if target_tile_id:
		cursor.color = Color(Color.ORANGE_RED, 0.3)
	else:
		cursor.color = Color(Color.SKY_BLUE, 0.3)
	cursor.global_position = map_to_local(target_map_position) - tile_size


func _on_hotbar_selected(item_id):
	select_tile_id = Common.get_item_category_id(item_id, Common.ItemCategory.TILE)
