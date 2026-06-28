extends EditorProperty

var LinkContainer

var current_value = {}
var updating = false

func _init():
	LinkContainer = preload("res://addons/DVTools/resource_handling/Manifest/ManifestTagType/TagContainer.tscn").instance()
	add_child(LinkContainer)
	add_focusable(LinkContainer)
	set_bottom_editor(LinkContainer)
	refresh_control_text()
	LinkContainer.connect("changed",self,"_on_update")

func _on_update():
	if updating:
		return
	
	current_value = LinkContainer.get_data()
#	refresh_control_text()
	emit_changed(get_edited_property(), current_value)



func update_property():
	var new_value = get_edited_object()[get_edited_property()]
	if (new_value == current_value):
		return

	# Update the control with the new value.
	updating = true
	current_value = new_value
	refresh_control_text()
	updating = false
	

func refresh_control_text():
	LinkContainer.set_data(current_value)
