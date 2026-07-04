tool
extends Button

var editor_property = []

func _init(e):
	editor_property[0] = e

func _ready():
	if editor_property:
		var obj = editor_property[0].get_inspector().get_edited_object()
		print(str(obj))
		
		
