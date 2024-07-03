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
			add_child(container)
	var button = Button.new()
	button.text = "➕️Add Row"
	button.pressed.connect(_on_add_row_pressed)
	add_child(button)
	# TODO remove

func _on_add_row_pressed():
	# TODO default value of type
	pass
