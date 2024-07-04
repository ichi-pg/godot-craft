@tool
extends Container

class_name TableEditor

@onready var item_list = $ItemList
@onready var container = $ScrollContainer/HBoxContainer


func _on_focus_entered():
	item_list.clear()
	container.clear()
	add_files_recursively("res:/", "res://")
	# TODO best trigger


func add_files_recursively(dir_path, dir_name):
	var dir = DirAccess.open(dir_name)
	if not dir:
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var file_path = dir_path + "/" + file_name
		if dir.current_is_dir():
			add_files_recursively(file_path, file_name)
		elif file_name.get_extension() == "tres":
			item_list.add_item(file_path)
		file_name = dir.get_next()


func _on_file_selected(index):
	container.clear()
	container.build(load(item_list.get_item_text(index)))
	# HACK connect both changed
