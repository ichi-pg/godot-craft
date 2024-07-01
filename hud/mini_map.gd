extends SubViewportContainer

const DEFAULT_ZOOM = Vector2.ONE / 40
const MAX_ZOOM = DEFAULT_ZOOM * 4
const MIN_ZOOM = DEFAULT_ZOOM / 4
const ZOOM_IN_RATE = Vector2.ONE * 2
const ZOOM_OUT_RATE = Vector2.ONE / 2

var is_mouse_entered = false
var tile_map: TileMap

@onready var player_marker = $SubViewport/PlayerMarker
@onready var camera = $SubViewport/Camera2D


func _ready():
	visible = false


func _input(event):
	if event.is_action_pressed("open_mini_map"):
		camera.zoom = DEFAULT_ZOOM
		visible = not visible
	if not is_mouse_entered:
		return
	if event.is_action_pressed("zoom_in_mini_map"):
		camera.zoom *= ZOOM_IN_RATE
	if event.is_action_pressed("zoom_out_mini_map"):
		camera.zoom *= ZOOM_OUT_RATE
	camera.zoom = clamp(camera.zoom, MIN_ZOOM, MAX_ZOOM)


func _on_player_moved(pos):
	player_marker.global_position = pos - Vector2.ONE * 64


func _on_mouse_entered():
	is_mouse_entered = true


func _on_mouse_exited():
	is_mouse_entered = false


func _on_level_readied(tile_map: TileMap):
	self.tile_map = tile_map.duplicate(0)
	for child in self.tile_map.get_children():
		child.queue_free()
	# TODO simply image and scale down
	# TODO background
	$SubViewport.add_child(self.tile_map)
	$SubViewport.move_child(self.tile_map, 0)


func _on_tile_placed(tile_id, map_pos):
	tile_map.set_cell(0, map_pos, 0, Common.get_tile_coord(tile_id))


func _on_tile_erased(tile_id, map_pos, world_pos):
	tile_map.erase_cell(0, map_pos)
