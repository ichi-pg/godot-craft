@tool
extends VBoxContainer

class_name ArrayContainer

var resource_name: String
var rows: Array[Variant]
var container: Container


func build(rows: Array[Variant], array_name: String):
	self.rows = rows
	if array_name.ends_with("ies"):
		resource_name = array_name.trim_suffix("ies") + "y"
		# HACK movies, boxes, and so on
	else:
		resource_name = array_name.trim_suffix("s")
	container = VBoxContainer.new()
	for row in rows:
		if row is Resource:
			add_row(row)
		# TODO int, float, string, enum, null
	add_child(container)
	var button = new_button("➕️Add " + resource_name)
	button.pressed.connect(_on_add_row_pressed)
	add_child(button)


func new_button(text: String):
	var button = Button.new()
	button.text = text
	return button


func _on_add_row_pressed():
	var script = rows.get_typed_script()
	var row = script.new()
	rows.append(row)
	add_row(row)


func add_row(row: Resource):
	var container = ResourceContainer.new()
	container.build(row)
	var button = new_button("➖️Remove " + resource_name)
	button.pressed.connect(_on_remove_row_pressed.bind(row, container))
	container.add_child(button)
	self.container.add_child(container)


func _on_remove_row_pressed(row: Variant, container: Container):
	rows.erase(row)
	container.queue_free()
