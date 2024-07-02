@tool
extends Container

const ResourceContainer = preload("res://addons/table_editor/resource_container.tscn")
const ArrayContainer = preload("res://addons/table_editor/array_container.tscn")

var resource: Resource


func clear():
	for child in get_children():
		child.queue_free()


func build(resource: Resource):
	self.resource = resource
	for prop in resource.get_property_list():
		var prop_name = prop["name"]
		var prop_val = resource.get(prop_name)
		#if prop_val is String:
			#add_child(new_label(prop_name))
			# TODO string
		if prop_val is int:
			add_child(new_label(prop_name))
			var spin_box = SpinBox.new()
			spin_box.value = prop_val
			add_child(spin_box)
			# TODO enum
		if prop_val is Array:
			add_child(new_label(prop_name))
			var container = ArrayContainer.instantiate()
			container.build(prop_val)
			add_child(container)
		if prop_val is Resource:
			if prop_val is Script:
				continue
			if prop_val is TileSetAtlasSource:
				continue
			add_child(new_label(prop_name))
			var container = ResourceContainer.instantiate()
			container.build(prop_val)
			add_child(container)


func new_label(text: String):
	var label = Label.new()
	label.text = text
	return label
