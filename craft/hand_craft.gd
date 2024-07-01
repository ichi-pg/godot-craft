extends ColorRect

@export var recipes: Array[CraftRecipe]


func _ready():
	visible = false


func _input(event):
	#if event.is_action_pressed("open_inventory"):
		#visible = not visible
	# TODO hand craft
	pass
