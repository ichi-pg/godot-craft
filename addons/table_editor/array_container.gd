@tool
extends HBoxContainer

class_name ArrayContainer

var rows: Array[Variant]
var container: Container
var row_name: String
var typed_script: Script


func build(rows: Array[Variant], array_name: String, typed_script: Script):
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
			add_row(row)
		# TODO int, float, string, enum, null
	var button = new_button("🟢Add " + row_name)
	button.pressed.connect(_on_add_row_pressed)
	add_child(container)
	add_child(button)
	# TODO exchange indices


func new_button(text: String):
	var button = Button.new()
	button.text = text
	return button


func _on_add_row_pressed():
	var row = typed_script.new()
	rows.append(row)
	add_row(row)


func add_row(row: Resource):
	var container = ResourceContainer.new()
	var button = new_button("🔴Remove " + row_name)
	button.pressed.connect(_on_remove_row_pressed.bind(row, container))
	container.build(row)
	container.add_child(button)
	self.container.add_child(container)


func _on_remove_row_pressed(row: Variant, container: Container):
	rows.erase(row)
	container.queue_free()
