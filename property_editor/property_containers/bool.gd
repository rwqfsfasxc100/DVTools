tool
extends MarginContainer

signal changed()

func get_property_value():
	var value = $CheckButton.pressed
	return [value,"true" if value else "false"]

func set_property_value(property):
	var cb = $CheckButton
	if property:
		cb.pressed = true
	else:
		cb.pressed = false

func _ready():
	$CheckButton.connect("pressed",self,"_on_changed")

func _on_changed():
	pass
#	emit_signal("changed")
