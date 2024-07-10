@tool
extends Container

class_name TableEditor

var all_scripts: Array[Script]
var all_resources: Array[Resource]
var relational_resources: Array[Resource]
var selected_resource: Resource

@onready var item_list = $ItemList
@onready var container = $HSplitContainer/ScrollContainer/HBoxContainer
@onready var texture_rect: TextureRect = $HSplitContainer/TextureRect


func _on_visibility_changed():
	if not item_list:
		return
	if not container:
		return
	item_list.clear()
	container.clear()
	all_scripts = []
	all_resources = []
	add_files_recursively("res:/", "res://")
	# HACK on create or delete resource
	# FIXME item list modified


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
			var resource = load(file_path)
			if resource.get_class() == "Resource":
				item_list.add_item(file_path)
				all_resources.append(resource)
		elif file_name.get_extension() == "gd":
			all_scripts.append(load(file_path))
		file_name = dir.get_next()


func _on_file_selected(index):
	selected_resource = load(item_list.get_item_text(index))
	relational_resources = []
	for resource in all_resources:
		if resource != selected_resource:
			relational_resources.append(resource)
	clear_texture()
	container.clear()
	container.build(selected_resource, self)


func clear_texture():
	for connection in texture_rect.get_signal_connection_list("gui_input"):
		texture_rect.gui_input.disconnect(connection["callable"])
	texture_rect.texture = null
