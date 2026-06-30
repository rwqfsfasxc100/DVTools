tool
extends EditorProperty

var CfgContainer

var current_value = {}
var updating = false

func _init():
	CfgContainer = preload("res://addons/DVTools/resource_handling/Manifest/ManifestCFGType/CfgContainer.tscn").instance()
	add_child(CfgContainer)
	add_focusable(CfgContainer)
	set_bottom_editor(CfgContainer)
	refresh_control_text()
	CfgContainer.connect("changed",self,"_on_update")

func _ready():
	var obj = get_edited_object()
	obj.connect("about_to_save",self,"_on_update")

func _on_update():
	if updating:
		return
	
	current_value = CfgContainer.get_data()
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
	print("setting config data as %s" % str(current_value))
	CfgContainer.set_data(current_value)
