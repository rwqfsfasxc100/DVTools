tool
extends EditorProperty

var ConflictsContainer

var current_value = []
var updating = false

func _init():
	ConflictsContainer = preload("res://addons/DVTools/resource_handling/Manifest/ManifestConflictAndRequirementsType/ConflictsContainer.tscn").instance()
	add_child(ConflictsContainer)
	add_focusable(ConflictsContainer)
	set_bottom_editor(ConflictsContainer)
	refresh_control_text()
	ConflictsContainer.connect("changed",self,"_on_update")

func _ready():
	var obj = get_edited_object()
	obj.connect("about_to_save",self,"_on_update")

func _on_update():
	if updating:
		return
	
	current_value = ConflictsContainer.get_data()
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
	ConflictsContainer.set_data(current_value)
