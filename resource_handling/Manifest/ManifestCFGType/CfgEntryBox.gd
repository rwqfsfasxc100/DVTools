tool
extends HBoxContainer

var toggled = false

var boxname = ""

var deleteformat = ""

var CONTAINER

var initial_state = {}

var current_box_type = ""

var loaded_box

func _ready():
	deleteformat = $DoDelete.dialog_text
	$BOX/BUTTONS/TOGGLE.connect("pressed",self,"_toggle_pressed")
	$BOX/BUTTONS/DELETE.connect("pressed",self,"_on_delete")
	$DoDelete.connect("confirmed",self,"$BOX/BUTTONS/DELETE")
	$BOX/BUTTONS/TOGGLE.text = boxname
	$BOX/BUTTONS/RENAME.connect("pressed",self,"_on_rename")
	$RenameTo.connect("confirmed",self,"RENAME_CONFIRMED")
	$BOX/BUTTONS/UP.connect("pressed",self,"_on_up_pressed")
	$BOX/BUTTONS/DOWN.connect("pressed",self,"_on_down_pressed")
#	specify_box_type(initial_state.get("type","bool"))
	set_data(initial_state,boxname)
	yield(get_tree(),"idle_frame")
	_on_down_pressed()

func changed(how = null):
	if CONTAINER:
		CONTAINER.has_changed()

func _on_up_pressed():
	if CONTAINER:
		CONTAINER.move_id_up(boxname,get_position_in_parent())
func _on_down_pressed():
	if CONTAINER:
		CONTAINER.move_id_down(boxname,get_position_in_parent())

const config_types = PoolStringArray([
	"bool",
	"int",
	"float",
	"string",
	"optionbutton",
	"input",
	"action",
])

func specify_box_type(type:String):
	type = fix_type_name(type)
	if type != current_box_type:
		if loaded_box and not loaded_box.is_queued_for_deletion():
			$BOX/CB/CONTENT.remove_child(loaded_box)
			loaded_box.queue_free()
		for i in $BOX/CB/CONTENT.get_children():
			if i and not i.is_queued_for_deletion():
				$BOX/CB/CONTENT.remove_child(i)
				i.queue_free()
		if type in boxes:
			var box = boxes[type].instance()
			box.name = "loaded_box"
			box.boxname = boxname
			loaded_box = box
			$BOX/CB/CONTENT.add_child(loaded_box)
	elif not loaded_box or (loaded_box and not loaded_box.is_queued_for_deletion()):
		if type in boxes:
			var box = boxes[type].instance()
			box.name = "loaded_box"
			box.boxname = boxname
			loaded_box = box
			$BOX/CB/CONTENT.add_child(loaded_box)
	if loaded_box:
		loaded_box.visible = true
	else:
		printerr("Loaded box was not set")

func fix_type_name(type:String = "bool") -> String:
	type = type.to_lower()
	match type:
		"boolean":
			type = "bool"
		"integer":
			type = "int"
		"real":
			type = "float"
		"str":
			type = "string"
		"option","option_button":
			type = "optionbutton"
	return type

var boxes = {
	"action":load("res://addons/DVTools/resource_handling/Manifest/ManifestCFGType/config_displays/action.tscn"),
	"bool":load("res://addons/DVTools/resource_handling/Manifest/ManifestCFGType/config_displays/bool.tscn"),
	"float":load("res://addons/DVTools/resource_handling/Manifest/ManifestCFGType/config_displays/float.tscn"),
	"input":load("res://addons/DVTools/resource_handling/Manifest/ManifestCFGType/config_displays/input.tscn"),
	"int":load("res://addons/DVTools/resource_handling/Manifest/ManifestCFGType/config_displays/int.tscn"),
	"optionbutton":load("res://addons/DVTools/resource_handling/Manifest/ManifestCFGType/config_displays/optionbutton.tscn"),
	"string":load("res://addons/DVTools/resource_handling/Manifest/ManifestCFGType/config_displays/string.tscn"),
}

func get_data():
	var data = {}
	if not loaded_box:
		loaded_box = $BOX/CB/CONTENT.get_node("loaded_box")
	if loaded_box:
		boxname = loaded_box.boxname
		current_box_type = loaded_box.type
		data = loaded_box.get_data().duplicate(true)
	if current_box_type == "optionbutton" and not data.get("options",[]).size():
		return {}
	data["type"] = current_box_type
	data["display_order_position"] = get_position_in_parent()
	return data

func set_data(STATE,bn:String = ""):
	specify_box_type(STATE.get("type","bool"))
	if loaded_box:
		loaded_box.set_data(STATE)
		if bn:
			loaded_box.boxname = bn

func _toggle_pressed():
	toggled = !toggled
	update()

func _on_delete():
	$DoDelete.dialog_text = deleteformat % boxname
	$DoDelete.popup_centered()

func DELETE():
	if CONTAINER:
		CONTAINER.delete(boxname)

func _on_rename():
	$RenameTo/VBoxContainer/OptionButton.clear()
	for i in config_types:
		$RenameTo/VBoxContainer/OptionButton.add_item(i)
	var current_index = config_types.find(current_box_type)
	if current_index < 0:
		current_index = 0
	$RenameTo/VBoxContainer/OptionButton.select(current_index)
	$RenameTo/VBoxContainer/LineEdit.text = boxname
	$RenameTo/VBoxContainer/LineEdit.caret_position = boxname.length()
	$RenameTo.popup_centered()
	$RenameTo/VBoxContainer/LineEdit.grab_focus()
	toggled = false

func RENAME_CONFIRMED():
	if CONTAINER:
		var newname = $RenameTo/VBoxContainer/LineEdit.text
		var newtype = config_types[$RenameTo/VBoxContainer/OptionButton.selected]
		if newname or newtype != current_box_type:
			if newname != boxname:
				CONTAINER.rename(boxname,newname)
			if newtype != current_box_type:
				var state = get_data().duplicate(true)
				specify_box_type(newtype)
				if newtype == "optionbutton":
					state["options"] = PoolStringArray(["EXAMPLE_OPTION"])
				set_data(state)
			$RenameTo.hide()

func _draw():
	if $BOX/CB/CONTENT:
		$BOX/CB/CONTENT.visible = toggled
		$BOX/BUTTONS/TOGGLE.text = boxname
