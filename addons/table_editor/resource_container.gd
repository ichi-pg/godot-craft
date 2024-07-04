@tool
extends HBoxContainer

class_name ResourceContainer

var resource: Resource

static var scripts = {}


func _ready():
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	# TODO SIZE_SHRINK_BEGIN


func clear():
	for child in get_children():
		child.queue_free()


func build(resource: Resource):
	self.resource = resource
	for prop in resource.get_property_list():
		var prop_name = prop["name"]
		var prop_class_name = prop["class_name"]
		var hint_string = prop["hint_string"]
		var type = prop["type"]
		var value = resource.get(prop_name)
		if value is int:
			if prop_class_name:
				var option_button = new_option_button(value, hint_string)
				option_button.item_selected.connect(_on_int_value_changed.bind(prop_name))
				add_child(new_label(prop_name))
				add_child(option_button)
			else:
				var spin_box = new_spin_box(value)
				spin_box.value_changed.connect(_on_int_value_changed.bind(prop_name))
				add_child(new_label(prop_name))
				add_child(spin_box)
				# TODO id to name
		#elif value is String:
			#add_child(new_label(prop_name))
			# TODO string
		if value is Array:
			add_child(new_label(prop_name))
			add_child(new_array_container(value, prop_name))
		if type == Variant.Type.TYPE_OBJECT:
			if ClassDB.get_class_list().has(hint_string):
				continue
				# HACK check all godot resources or check tree depth
			add_child(new_label(prop_name))
			if value != null:
				# HACK can't store scripts if all empty
				scripts[hint_string] = value.get_script()
				add_child(new_resource_container(value))
			else:
				var button = new_button("🆕new " + prop_name)
				button.pressed.connect(_on_new_resource_pressed.bind(prop_name, hint_string, button))
				add_child(button)


func _on_new_resource_pressed(prop_name, hint_string, button):
	var resource = scripts[hint_string].new()
	var container = new_resource_container(resource)
	add_child(container)
	move_child(container, button.get_index())
	button.queue_free()
	self.resource.set(prop_name, resource)


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


func new_spin_box(value: int):
	var spin_box = SpinBox.new()
	spin_box.value = value
	var line_edit = spin_box.get_line_edit()
	line_edit.expand_to_text_length = true
	return spin_box


func new_option_button(value: int, hint_string: String):
	var option_button = OptionButton.new()
	for option in hint_string.split(","):
		var item = option.split(":")
		option_button.add_item(item[0], int(item[1]))
	option_button.selected = value
	return option_button


func new_resource_container(value):
	var container = ResourceContainer.new()
	container.build(value)
	return container


func new_array_container(value, prop_name):
	var container = ArrayContainer.new()
	container.build(value, prop_name)
	return container


func _on_int_value_changed(value: float, prop_name: String):
	self.resource.set(prop_name, int(value))
	# TODO save resource without open resource
