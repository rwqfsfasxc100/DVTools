extends EditorProperty


var property_control = LineEdit.new()
var current_value = 2.2
var updating = false


func _init():
	property_control.editable = false
	property_control.align = LineEdit.ALIGN_CENTER
	add_child(property_control)
	add_focusable(property_control)
	refresh_control_text()

func update_property():
	# Read the current value from the property.
	var new_value = get_edited_object()[get_edited_property()]
	if (new_value == current_value):
		return

	# Update the control with the new value.
	updating = true
	current_value = new_value
	refresh_control_text()
	updating = false

func refresh_control_text():
	property_control.text = str(current_value)
