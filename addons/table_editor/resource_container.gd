@tool
extends HBoxContainer

class_name ResourceContainer

const IGNORE_PROPERTIES = ["resource_path", "resource_name"]

var resource: Resource
var table_editor: TableEditor
var atlas_texture: AtlasTexture
var region_size: int


func clear():
	for child in get_children():
		child.queue_free()


func build(resource: Resource, table_editor: TableEditor):
	# HACK split class
	self.table_editor = table_editor
	self.resource = resource
	for prop in resource.get_property_list():
		var prop_name = prop["name"] as String
		var hint_string = prop["hint_string"] as String
		var type = prop["type"]
		var value = resource.get(prop_name)
		if value is int:
			var option_items = find_option_items(prop_name, hint_string)
			if option_items.is_empty():
				if prop_name.ends_with("_id"):
					var spin_box = new_spin_box(value)
					spin_box.value_changed.connect(_on_int_value_changed.bind(prop_name))
					spin_box.editable = false
					add_child(new_label(prop_name))
					add_child(spin_box)
					# HACK check duplicate ids
					# HACK unlock id editable
				else:
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
			if prop_name.contains("atlas"):
				var texture_rect = new_atras_texture(value, prop_name)
				if not texture_rect:
					continue
				atlas_texture = texture_rect.texture
				add_child(new_label(prop_name))
				add_child(texture_rect)
			else:
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
				match hint_string:
					"Texture2D":
						# HACK texture picker
						# HACK texture preview
						if value:
							add_child(new_label(prop_name))
							add_child(new_line_edit(value.resource_path))
						else:
							add_child(new_label(prop_name))
							add_child(new_line_edit(""))
			elif value != null:
				add_child(new_label(prop_name))
				add_child(new_resource_container(value))
			else:
				var button = new_button("🔵new " + prop_name)
				button.pressed.connect(_on_new_resource_pressed.bind(prop_name, hint_string, button))
				add_child(new_label(prop_name))
				add_child(button)


func find_option_items(prop_name, hint_string):
	# HACK cache
	var items = []
	if hint_string != "int":
		# HACK can't link new item if script not modify
		for option in hint_string.split(","):
			items.append(option.split(":"))
	elif prop_name.ends_with("_id"):
		var label_name = prop_name.replace("_id", "_name")
		for resource in table_editor.relational_resources:
			for prop in resource.get_property_list():
				var rows = resource.get(prop["name"])
				if rows is Array:
					for row in rows:
						var label = row.get(label_name)
						var id = row.get(prop_name)
						if label and id:
							items.append([label, id])
	return items


func find_resource_has_atlas() -> Resource:
	# HACK cache
	for resource in table_editor.relational_resources:
		for prop in resource.get_property_list():
			var rows = resource.get(prop["name"])
			if rows is Array:
				for row in rows:
					var atlas = row.get("atlas")
					if atlas:
						for row_prop in row.get_property_list():
							# HACK id pattern
							var row_name = row_prop["name"]
							var enum_value = row.get(row_name)
							if enum_value is int and row_prop["hint_string"] != "int":
								if enum_value == self.resource.get(row_name):
									return row as Resource
	return null


func new_atlas_region(coord: Vector2i):
	return Rect2(coord * region_size + Vector2i.ONE, Vector2i(region_size - 1, region_size - 1))


func new_atras_texture(coord: Vector2i, prop_name: String):
	var resource = find_resource_has_atlas()
	if not resource:
		return
	var rect = TextureRect.new()
	var texture = AtlasTexture.new()
	region_size = resource.get("region_size")
	texture.atlas = resource.get("atlas")
	texture.region = new_atlas_region(coord)
	rect.texture = texture
	rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	rect.gui_input.connect(_on_atlas_texture_gui_input.bind(texture, prop_name))
	return rect


func new_button(text: String):
	var button = Button.new()
	button.text = text
	return button


func new_label(text: String):
	var container = MarginContainer.new()
	var rect = ColorRect.new()
	var label = Label.new()
	label.text = text
	rect.color = Color(1, 1, 1, 0.1)
	container.add_child(rect)
	container.add_child(label)
	return container


func new_line_edit(value: String):
	var label = LineEdit.new()
	label.text = value
	label.expand_to_text_length = true
	return label


func new_spin_box(value: int):
	var spin_box = SpinBox.new()
	spin_box.min_value = Common.MIN_RANGE
	spin_box.max_value = Common.MAX_RANGE
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


func new_array_container(value: Array[Variant], prop_name: String):
	var container = ArrayContainer.new()
	var typed_script = value.get_typed_script()
	if not typed_script:
		typed_script = resource.get("typed_script")
	# HACK empty arrays synchronized if same scripts
	# HACK can't link script modify ???
	container.build(value, prop_name, typed_script, table_editor)
	return container


func new_script_resource(script: Script):
	var resource = script.new()
	for prop in resource.get_property_list():
		var prop_name = prop["name"]
		if prop_name.ends_with("_id"):
			resource.set(prop_name, randi_range(Common.MAX_RANGE/10, Common.MAX_RANGE-1))
			# HACK check duplicate ids
	return resource


func _on_atlas_texture_gui_input(event: InputEvent, texture: AtlasTexture, prop_name: String):
	if event.is_pressed():
		table_editor.clear_texture()
		table_editor.texture_rect.texture = texture.atlas
		table_editor.texture_rect.gui_input.connect(_on_atlas_gui_input.bind(prop_name))


func _on_atlas_gui_input(event: InputEvent, prop_name: String):
	if event.is_pressed():
		var mouse_event = event as InputEventMouse
		var rect = table_editor.texture_rect
		var texture_size = rect.texture.get_size()
		var coord = mouse_event.position * max(texture_size.x, texture_size.y) / rect.size / region_size
		_on_v2i_value_changed(Vector2i(coord), prop_name)
		# HACK link spin box


func _on_new_resource_pressed(prop_name, hint_string, button):
	# HACK cache
	for script in table_editor.all_scripts:
		if script.source_code.contains("class_name " + hint_string):
			var resource = new_script_resource(script)
			var container = new_resource_container(resource)
			add_child(container)
			move_child(container, button.get_index())
			button.queue_free()
			_on_value_changed(resource, prop_name)


func _on_value_changed(value: Variant, prop_name: String):
	resource.set(prop_name, value)
	table_editor.save_resource()
	# HACK undo and modify


func _on_option_value_changed(idx: int, prop_name: String, option_button: OptionButton):
	_on_value_changed(option_button.get_item_id(idx), prop_name)
	# HACK change atlas


func _on_v2i_value_changed(coord: Vector2i, prop_name: String):
	if atlas_texture:
		atlas_texture.region = new_atlas_region(coord)
	_on_value_changed(coord, prop_name)


func _on_v2i_x_value_changed(x: float, prop_name: String):
	var v2i = resource.get(prop_name)
	v2i.x = x
	_on_v2i_value_changed(v2i, prop_name)


func _on_v2i_y_value_changed(y: float, prop_name: String):
	var v2i = resource.get(prop_name)
	v2i.y = y
	_on_v2i_value_changed(v2i, prop_name)


func _on_int_value_changed(value: float, prop_name: String):
	_on_value_changed(int(value), prop_name)
