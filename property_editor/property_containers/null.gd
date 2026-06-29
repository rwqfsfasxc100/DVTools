tool
extends MarginContainer

signal changed()

func get_property_value():
	return [null,"null"]

func set_property_value(property):
	emit_signal("changed")
