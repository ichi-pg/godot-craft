extends Resource

class_name VariantTable

@export var rows: Array[Variant]
@export var typed_script: Script


func get_by(prop_name: String, value: Variant):
	# HACK cache
	for row in rows:
		for prop in row.get_property_list():
			if prop["name"] == prop_name:
				if row.get(prop_name) == value:
					return row
	return null
