extends SubViewportContainer

const DEFAULT_ZOOM = Vector2.ONE * 0.1
const MAX_ZOOM = Vector2.ONE * 0.2
const MIN_ZOOM = Vector2.ONE * 0.02
const ZOOM_IN_RATE = Vector2.ONE * 2
const ZOOM_OUT_RATE = Vector2.ONE / 2

var is_mouse_entered = false

@onready var player_marker = $SubViewport/PlayerMarker
@onready var camera = $SubViewport/Camera2D


func _ready():
	visible = false
	# TODO tile_map
	# TODO scale
	# TODO background


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
	player_marker.global_position = pos


func _on_mouse_entered():
	is_mouse_entered = true


func _on_mouse_exited():
	is_mouse_entered = false
