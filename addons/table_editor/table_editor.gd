@tool
extends Container

class_name TableEditor

var all_scripts: Array[Script]
var all_resources: Array[Resource]
var relational_resources: Array[Resource]
var selected_resource: Resource

@onready var line_edit = $VBoxContainer/LineEdit
@onready var item_list = $VBoxContainer/ItemList
@onready var container = $HSplitContainer/ScrollContainer/HBoxContainer
@onready var texture_rect: TextureRect = $HSplitContainer/TextureRect


func find_array_container(node: Node) -> ArrayContainer:
	if node is ArrayContainer:
		return node
	for child in node.get_children():
		var array_container = find_array_container(child)
		if array_container:
			return array_container
	return null


func contains_text(node: Node, text: String):
	if not text:
		return true
	if node is LineEdit:
		var line_edit = node as LineEdit
		if line_edit.text.to_lower().contains(text):
			return true
	if node is OptionButton:
		var option_button = node as OptionButton
		var item_text = option_button.get_item_text(option_button.selected)
		if item_text.to_lower().contains(text):
			return true
	for child in node.get_children():
		if contains_text(child, text):
			return true
	return false


func _on_filter_changed(text: String):
	# HACK when change file
	var array_container = find_array_container(container)
	if array_container:
		var lower = text.to_lower()
		for row in array_container.container.get_children():
			row.visible = contains_text(row, lower)

func _on_visibility_changed():
	if not item_list:
		return
	if not container:
		return
	if not line_edit.text_changed.is_connected(_on_filter_changed):
		line_edit.text_changed.connect(_on_filter_changed)
	item_list.clear()
	container.clear()
	all_scripts = []
	all_resources = []
	add_files_recursively("res:/", "res://")
	# HACK on create or delete resource
	# FIXME item list modified on addons


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


func save_resource():
	ResourceSaver.save(selected_resource)
