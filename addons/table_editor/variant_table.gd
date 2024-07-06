extends Resource

class_name VariantTable

@export var rows: Array[Variant]
@export var typed_script: Script
@export var depends_tables: Array[VariantTable]


func get_by(property: String, value: Variant):
	# HACK cache
	# TODO Dictionary
	for row in rows:
		for prop in row.get_property_list():
			if prop["name"] == property:
				if row.get(property) == value:
					return row
	return null
