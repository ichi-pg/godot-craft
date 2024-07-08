@tool
extends HBoxContainer

class_name ResourceContainer

const IGNORE_PROPERTIES = ["resource_path", "resource_name"]

var resource: Resource
var table_editor: TableEditor
var option_items: Dictionary


func clear():
	for child in get_children():
		child.queue_free()


func find_option_items(prop_name, hint_string):
	if option_items.has(prop_name):
		return option_items[prop_name]
	var items = []
	if hint_string != "int":
		for option in hint_string.split(","):
			items.append(option.split(":"))
	elif prop_name.ends_with("_id"):
		var label_name = prop_name.replace("_id", "_name")
		for relational_resource in table_editor.relational_resources:
			for relational_property in relational_resource.get_property_list():
				var rows = relational_resource.get(relational_property["name"])
				if rows is Array:
					for row in rows:
						var label = row.get(label_name)
						var id = row.get(prop_name)
						if label and id:
							items.append([label, id])
	option_items[prop_name] = items
	return items


func build(resource: Resource, table_editor: TableEditor):
	self.table_editor = table_editor
	self.resource = resource
	for prop in resource.get_property_list():
		var prop_name = prop["name"]
		var hint_string = prop["hint_string"]
		var type = prop["type"]
		var value = resource.get(prop_name)
		# TODO texture preview
		if value is int:
			var option_items = find_option_items(prop_name, hint_string)
			if option_items.is_empty():
				var spin_box = new_spin_box(value)
				spin_box.value_changed.connect(_on_int_value_changed.bind(prop_name))
				add_child(new_label(prop_name))
				add_child(spin_box)
			else:
				var option_button = new_option_button(value, option_items)
				option_button.item_selected.connect(_on_option_value_changed.bind(prop_name, option_button))
				add_child(new_label(prop_name))
				add_child(option_button)
		if value is float:
			var spin_box = new_spin_box(value)
			spin_box.value_changed.connect(_on_value_changed.bind(prop_name))
			add_child(new_label(prop_name))
			add_child(spin_box)
		if value is String:
			if IGNORE_PROPERTIES.has(prop_name):
				continue
			var line_edit = new_line_edit(value)
			line_edit.text_changed.connect(_on_value_changed.bind(prop_name))
			add_child(new_label(prop_name))
			add_child(line_edit)
		if value is Vector2i:
			var x_spin_box = new_spin_box(value.x)
			var y_spin_box = new_spin_box(value.y)
			x_spin_box.value_changed.connect(_on_v2i_x_value_changed.bind(prop_name))
			y_spin_box.value_changed.connect(_on_v2i_y_value_changed.bind(prop_name))
			add_child(new_label(prop_name))
			add_child(x_spin_box)
			add_child(y_spin_box)
		if value is Array:
			add_child(new_label(prop_name))
			add_child(new_array_container(value, prop_name))
		if type == Variant.Type.TYPE_OBJECT:
			if ClassDB.get_class_list().has(hint_string):
				continue
			if value != null:
				add_child(new_label(prop_name))
				add_child(new_resource_container(value))
			else:
				var button = new_button("🔵new " + prop_name)
				button.pressed.connect(_on_new_resource_pressed.bind(prop_name, hint_string, button))
				add_child(new_label(prop_name))
				add_child(button)


func _on_new_resource_pressed(prop_name, hint_string, button):
	# HACK cache
	for script in table_editor.scripts:
		if script.source_code.contains("class_name " + hint_string):
			var resource = script.new()
			var container = new_resource_container(resource)
			add_child(container)
			move_child(container, button.get_index())
			button.queue_free()
			_on_value_changed(resource, prop_name)
			return


func new_button(text: String):
	var button = Button.new()
	button.text = text
	return button


func new_label(text: String):
	var label = LineEdit.new()
	label.text = text
	label.editable = false
	label.expand_to_text_length = true
	return label


func new_line_edit(value: String):
	var label = LineEdit.new()
	label.text = value
	label.expand_to_text_length = true
	return label


func new_spin_box(value: int):
	# FIXME 0-100
	var spin_box = SpinBox.new()
	spin_box.value = value
	var line_edit = spin_box.get_line_edit()
	line_edit.expand_to_text_length = true
	return spin_box


func new_option_button(id: int, items: Array):
	var option_button = OptionButton.new()
	for item in items:
		option_button.add_item(item[0], int(item[1]))
	option_button.selected = option_button.get_item_index(id)
	option_button.custom_minimum_size.x = 64
	return option_button


func new_resource_container(value):
	var container = ResourceContainer.new()
	container.build(value, table_editor)
	return container


func new_array_container(value, prop_name):
	var container = ArrayContainer.new()
	container.build(value, prop_name, value.get_typed_script(), table_editor)
	return container


func _on_value_changed(value: Variant, prop_name: String):
	resource.set(prop_name, value)
	ResourceSaver.save(table_editor.selected_resource)
	# TODO undo and modify


func _on_option_value_changed(idx: int, prop_name: String, option_button: OptionButton):
	_on_value_changed(option_button.get_item_id(idx), prop_name)


func _on_v2i_x_value_changed(x: float, prop_name: String):
	var v2i = resource.get(prop_name)
	v2i.x = x
	_on_value_changed(v2i, prop_name)


func _on_v2i_y_value_changed(y: float, prop_name: String):
	var v2i = resource.get(prop_name)
	v2i.y = y
	_on_value_changed(v2i, prop_name)


func _on_int_value_changed(value: float, prop_name: String):
	_on_value_changed(int(value), prop_name)
