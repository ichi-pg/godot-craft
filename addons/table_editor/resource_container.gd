@tool
extends HBoxContainer

class_name ResourceContainer

var resource: Resource


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
		var value = resource.get(prop_name)
		#if value is String:
			#add_child(new_label(prop_name))
			# TODO string
		if value is int:
			add_child(new_label(prop_name))
			var spin_box = SpinBox.new()
			spin_box.value = value
			spin_box.value_changed.connect(_on_int_value_changed.bind(prop_name))
			var line_edit = spin_box.get_line_edit()
			line_edit.expand_to_text_length = true
			add_child(spin_box)
			# TODO enum
			# TODO id to name
		elif value is Array:
			add_child(new_label(prop_name))
			var container = ArrayContainer.new()
			container.build(value, prop_name)
			add_child(container)
		elif value is Resource:
			if value is Script:
				continue
			if value is TileSetAtlasSource:
				continue
			# HACK check all godot resources or check tree depth
			add_child(new_label(prop_name))
			var container = ResourceContainer.new()
			container.build(value)
			add_child(container)
		elif prop_class_name:
			print(prop)
			# TODO bew button if null


func new_label(text: String):
	var label = LineEdit.new()
	label.text = text
	label.editable = false
	label.expand_to_text_length = true
	return label


func _on_int_value_changed(value: float, prop_name: String):
	self.resource.set(prop_name, int(value))
	# TODO save resource without open resource
	pass
