tool
extends HBoxContainer

var entry_name = ""

func _ready():
	$UP.connect("pressed",self,"up")
	$DOWN.connect("pressed",self,"down")
	$DELETE.connect("pressed",self,"delete")
	$ConfirmationDialog.connect("confirmed",self,"do_delete")

func up():
	var par = get_parent()
	par.move_child(self,clamp(get_position_in_parent() - 1,0,par.get_child_count() - 1))

func down():
	var par = get_parent()
	par.move_child(self,clamp(get_position_in_parent() + 1,0,par.get_child_count() - 1))

func delete():
	$ConfirmationDialog.popup_centered()

func do_delete():
	get_parent().remove_child(self)
	queue_free()

