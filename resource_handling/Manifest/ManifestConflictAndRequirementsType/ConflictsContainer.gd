tool
extends VBoxContainer

signal changed()

func _ready():
	$HB/CONTENT/ADD.connect("pressed",self,"_on_add_open")
	$ConfirmationDialog.connect("confirmed",self,"_add_confirmed")

func get_data():
	var out = []
	for i in $HB/CONTENT/LIST.get_children():
		var data = i.get_data()
		out.append(data)
	return out

func set_data(STATE):
	for i in $HB/CONTENT/LIST.get_children():
		$HB/CONTENT/LIST.remove_child(i)
		i.queue_free()
	for i in Array(STATE):
		match typeof(i):
			TYPE_STRING,TYPE_DICTIONARY:
				add(0,i)
			TYPE_ARRAY,TYPE_STRING_ARRAY:
				add(1,i)
	refresh_title()

func has_changed():
	emit_signal("changed")

func _on_add_open():
	$ConfirmationDialog/VBoxContainer/OptionButton.clear()
	for i in ["Singular mod (only item checked)","Multiple mods (any number can exist to trigger the check)"]:
		$ConfirmationDialog/VBoxContainer/OptionButton.add_item(i)
	$ConfirmationDialog/VBoxContainer/OptionButton.select(0)
	$ConfirmationDialog.popup_centered()
	$ConfirmationDialog/VBoxContainer/OptionButton.grab_focus()

func _add_confirmed():
	add($ConfirmationDialog/VBoxContainer/OptionButton.selected)
	

func add(type:int = 0,data = null):
	var node = null
	match type:
		0:
			node = load("res://addons/DVTools/resource_handling/Manifest/ManifestConflictAndRequirementsType/SingleConflictEntry.tscn").instance()
		1:
			node = load("res://addons/DVTools/resource_handling/Manifest/ManifestConflictAndRequirementsType/MultiConflictEntry.tscn").instance()
	if node != null:
		if data != null and node.has_method("set_data"):
			node.set_data(data)
		$HB/CONTENT/LIST.add_child(node)

func _draw():
	refresh_title()

func refresh_title():
	$TBOX/TOGGLE.text = "Toggle visibility (%d checks)" % $HB/CONTENT/LIST.get_child_count()


func _on_TOGGLE_pressed():
	$HB/CONTENT.visible = !$HB/CONTENT.visible
