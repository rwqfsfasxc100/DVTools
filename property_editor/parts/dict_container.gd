tool
extends HBoxContainer

var emit_update_signal = false setget set_update_signal

func set_update_signal(how):
	$key.emit_update_signal = how
	$value.emit_update_signal = how
	emit_update_signal = how

func get_property_value():
	var key = $key.get_property_value()
	var value = $value.get_property_value()
	return [{key[0]:value[0]},"{%s:%s}" % [key[1],value[1]]]

func set_property_value(key,value):
	$key.initialize(key)
	$value.initialize(value)

var parent_container = null

func _ready():
	if not $DELETE.is_connected("pressed",self,"_on_delete"):
		$DELETE.connect("pressed",self,"_on_delete")
	if not $UP.is_connected("pressed",self,"_on_up_pressed"):
		$UP.connect("pressed",self,"_on_up_pressed")
	if not $DOWN.is_connected("pressed",self,"_on_down_pressed"):
		$DOWN.connect("pressed",self,"_on_down_pressed")
	if not $ConfirmationDialog.is_connected("confirmed",self,"_do_delete"):
		$ConfirmationDialog.connect("confirmed",self,"_do_delete")

func _on_delete():
	$ConfirmationDialog.popup_centered()

func _on_up_pressed():
	var parent = get_parent()
	parent.move_child(self,clamp(get_position_in_parent() - 1,0,parent.get_child_count() - 1))
	if parent_container:
		parent_container._has_changed()

func _on_down_pressed():
	var parent = get_parent()
	parent.move_child(self,clamp(get_position_in_parent() + 1,0,parent.get_child_count() - 1))
	if parent_container:
		parent_container._has_changed()

func _do_delete():
	queue_free()
	if parent_container:
		parent_container.recalculate()
