@tool
extends HBoxContainer

class_name ArrayContainer

var rows: Array[Variant]
var container: Container
var row_name: String
var typed_script: Script
var table_editor: TableEditor


func build(rows: Array[Variant], array_name: String, typed_script: Script, table_editor: TableEditor):
	self.table_editor = table_editor
	self.rows = rows
	self.typed_script = typed_script
	if array_name.ends_with("ies"):
		row_name = array_name.trim_suffix("ies") + "y"
		# HACK movies, boxes, and so on
	elif array_name.ends_with("s"):
		row_name = array_name.trim_suffix("s")
	else:
		row_name = array_name
	container = VBoxContainer.new()
	for row in rows:
		if row is Resource:
			add_row(row, ResourceContainer.new())
		# HACK int, float, string, enum, null
	var button = new_button("🟢add " + row_name)
	button.pressed.connect(_on_add_row_pressed)
	add_child(container)
	add_child(button)
	# TODO exchange indices
	# TODO buttons theme


func new_button(text: String):
	var button = Button.new()
	button.text = text
	return button


func add_row(row: Resource, container: ResourceContainer):
	var button = new_button("🔴remove " + row_name)
	button.pressed.connect(_on_remove_row_pressed.bind(row, container))
	container.build(row, table_editor)
	container.add_child(button)
	self.container.add_child(container)


func _on_add_row_pressed():
	if not typed_script:
		return
	var container = ResourceContainer.new()
	var row = container.new_script_resource(typed_script)
	rows.append(row)
	add_row(row, container)
	table_editor.save_resource()


func _on_remove_row_pressed(row: Variant, container: Container):
	rows.erase(row)
	container.queue_free()
	table_editor.save_resource()
