extends CanvasLayer

signal focused(is_focus)


func _on_mouse_entered():
	focused.emit(true)


func _on_mouse_exited():
	focused.emit(false)
 
