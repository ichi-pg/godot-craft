@tool
extends Container

const ResourceContainer = preload("res://addons/table_editor/resource_container.tscn")

var variants: Array[Variant]


func build(variants: Array[Variant]):
	self.variants = variants
	for variant in variants:
		if variant is Resource:
			var container = ResourceContainer.instantiate()
			container.build(variant)
			add_child(container)
	var button = Button.new()
	button.text = "➕️Add"
	add_child(button)
	# TODO remove
