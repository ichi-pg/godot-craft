@tool
extends VBoxContainer

class_name ArrayContainer

var resource_name: String
var rows: Array[Variant]
var container: Container


func build(rows: Array[Variant], array_name: String):
	self.rows = rows
	resource_name = array_name.trim_suffix("s")
	container = VBoxContainer.new()
	for row in rows:
		if row is Resource:
			add_row(row)
		# TODO int, float, string, enum, null
	add_child(container)
	add_child(new_button("➕️Add " + resource_name, _on_add_row_pressed))


func new_button(text: String, _on_pressed: Callable):
	var button = Button.new()
	button.text = text
	button.pressed.connect(_on_pressed)
	return button


func _on_add_row_pressed():
	var script = rows.get_typed_script()
	var row = script.new()
	rows.append(row)
	add_row(row)
	# TODO new resource property


func add_row(row: Resource):
	var container = ResourceContainer.new()
	container.build(row)
	container.add_child(new_button("➖️Remove " + resource_name, _on_remove_row_pressed.bind(row, container)))
	self.container.add_child(container)


func _on_remove_row_pressed(row: Variant, container: Container):
	rows.erase(row)
	container.queue_free()
