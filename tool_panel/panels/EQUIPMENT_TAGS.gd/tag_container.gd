tool
extends HBoxContainer

var emit_update_signal = false setget set_update_signal

func set_update_signal(how):
	emit_update_signal = how

func get_property_value():
	var value = $Label.text
	return [value,str(value)]

func set_property_value(value):
	$Label.text = str(value)

var parent_container = null

func _ready():
	if not $DELETE.is_connected("pressed",self,"_on_delete"):
		$DELETE.connect("pressed",self,"_on_delete")
	if not $ConfirmationDialog.is_connected("confirmed",self,"_do_delete"):
		$ConfirmationDialog.connect("confirmed",self,"_do_delete")

func _on_delete():
	$ConfirmationDialog.popup_centered()

func _do_delete():
	queue_free()
	if parent_container:
		parent_container.recalculate()
