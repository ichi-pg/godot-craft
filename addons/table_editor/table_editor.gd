@tool
extends Container

class_name TableEditor

@onready var files = $ItemList
@onready var container = $ScrollContainer/ResourceContainer

# TODO auto load resources
# TODO expend values to table


func _ready():
	files.clear()
	container.clear()
	add_files("res:/", "res://")
	# TODO other load ways


func add_files(dir_path, dir_name):
	var dir = DirAccess.open(dir_name)
	if not dir:
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var file_path = dir_path + "/" + file_name
		if dir.current_is_dir():
			add_files(file_path, file_name)
		elif file_name.get_extension() == "tres":
			files.add_item(file_path)
		file_name = dir.get_next()


func _on_file_selected(index):
	container.clear()
	container.build(load(files.get_item_text(index)))
