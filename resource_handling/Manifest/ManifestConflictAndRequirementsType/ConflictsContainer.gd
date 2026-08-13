tool
extends VBoxContainer

signal changed()

func _ready():
	$ADD.connect("pressed",self,"_on_add_open")
	$ConfirmationDialog.connect("confirmed",self,"_add_confirmed")
	$PAGE/COUNT.connect("value_changed",self,"_page_value_changed")

func get_data():
	var out = []
	for i in $LIST.get_children():
		var data = i.get_data()
		out.append(data)
	return out

func set_data(STATE):
	for i in $LIST.get_children():
		$LIST.remove_child(i)
		i.queue_free()
	for i in Array(STATE):
		pass

func has_changed():
	emit_signal("changed")

func _on_add_open():
	$ConfirmationDialog/VBoxContainer/LineEdit.text = ""
	$ConfirmationDialog/VBoxContainer/Label.visible = false
	
	$ConfirmationDialog.popup_centered()
	$ConfirmationDialog/VBoxContainer/LineEdit.grab_focus()







