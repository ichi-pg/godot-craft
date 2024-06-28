extends SubViewportContainer

@onready var player_marker = $SubViewport/PlayerMarker


func _ready():
	visible = false


func _input(event):
	if event.is_action_pressed("open_mini_map"):
		visible = not visible


func _on_player_moved(pos):
	player_marker.global_position = pos
