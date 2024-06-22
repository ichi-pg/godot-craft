extends TileMap

class_name Level

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
	Common.level_texture.atlas = source.texture


func _on_player_moved(pos):
	player_position = pos
	update_target()


func _input(event):
	if not cursor.visible:
		pass
	elif event is InputEventMouseMotion:
		mouse_position = viewport.get_mouse_position() - viewport.get_visible_rect().size * 0.5
		update_target()
	elif target_map_position == local_to_map(player_position):
		pass
	elif not event.is_action_pressed("battle_attack"):
		pass
		# TODO range
	elif target_tile_id:
		# TODO pickaxe
		# TODO tile health
		var fix_target_tile_id = target_tile_id
		erase_cell(0, target_map_position)
		update_target_tile(0)
		erased.emit(fix_target_tile_id)
		# TODO gravity
	elif is_around_empty(target_map_position):
		pass
	elif select_tile_id:
		var fix_select_tile_id = select_tile_id
		set_cell(0, target_map_position, 1, Common.get_tile_coord(fix_select_tile_id))
		update_target_tile(fix_select_tile_id)
		placed.emit(fix_select_tile_id)


func is_around_empty(pos):
	if get_cell_tile_data(0, pos + Vector2i.LEFT):
		return false
	if get_cell_tile_data(0, pos + Vector2i.RIGHT):
		return false
	if get_cell_tile_data(0, pos + Vector2i.UP):
		return false
	if get_cell_tile_data(0, pos + Vector2i.DOWN):
		return false
	# TODO tile type
	return true


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


func _on_hotbar_selected(category, item_id):
	if category == Common.ItemCategory.TILE:
		select_tile_id = item_id
	else:
		select_tile_id = 0


func _on_hud_focused(is_focus):
	cursor.visible = not is_focus
