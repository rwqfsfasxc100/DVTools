extends EditorProperty

var LinkContainer

var current_value = {}
var updating = false

func _init():
	LinkContainer = preload("res://addons/DVTools/resource_handling/Manifest/ManifestLinkType/LinkContainer.tscn").instance()
	add_child(LinkContainer)
	add_focusable(LinkContainer)
	set_bottom_editor(LinkContainer)
	refresh_control_text()



func update_property():
	pass
	
	
	

func refresh_control_text():
	LinkContainer.get_node("ENTRY/COUNT").value = current_value.size()
