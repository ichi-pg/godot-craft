@tool
extends VBoxContainer

class_name ArrayContainer

var rows: Array[Variant]


func build(rows: Array[Variant]):
	self.rows = rows
	for row in rows:
		if row is Resource:
			var container = HBoxContainer.new()
			container.set_script(ResourceContainer)
			container.build(row)
			container.add_child(new_button("➖️Remove Row", _on_remove_row_pressed.bind(row)))
			add_child(container)
	add_child(new_button("➕️Add Row", _on_add_row_pressed))
	# TODO remove


func new_button(text: String, _on_pressed: Callable):
	var button = Button.new()
	button.text = text
	button.pressed.connect(_on_pressed)
	return button


func _on_add_row_pressed():
	# TODO default value of type
	pass


func _on_remove_row_pressed(row: Variant):
	#rows.erase(row)
	# TODO erase on rows and container
	pass
