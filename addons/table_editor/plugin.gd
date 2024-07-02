@tool
extends EditorPlugin

const TableEditor = preload("res://addons/table_editor/table_editor.tscn")

var table_editor

func _enter_tree():
	table_editor = TableEditor.instantiate()
	add_control_to_bottom_panel(table_editor, "TableEditor")

func _exit_tree():
	remove_control_from_bottom_panel(table_editor)
	table_editor.queue_free()
