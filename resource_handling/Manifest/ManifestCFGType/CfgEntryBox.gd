tool
extends HBoxContainer

onready var TOGGLE = $BOX/BUTTONS/TOGGLE
onready var RENAME = $BOX/BUTTONS/RENAME
onready var DELETE = $BOX/BUTTONS/DELETE
onready var DELETEMENU = $DoDelete
onready var CONTENT = $BOX/CB/CONTENT
onready var RENAMEBOX = $RenameTo
onready var RENAMEEDIT = $RenameTo/VBoxContainer/LineEdit
onready var RENAMEOPTS = $RenameTo/VBoxContainer/OptionButton

var toggled = false

var boxname = ""

var deleteformat = ""

var CONTAINER

var initial_state = {}

var current_box_type = ""

var loaded_box

func _ready():
	deleteformat = DELETEMENU.dialog_text
	TOGGLE.connect("pressed",self,"_toggle_pressed")
	DELETE.connect("pressed",self,"_on_delete")
	DELETEMENU.connect("confirmed",self,"DELETE")
	TOGGLE.text = boxname
	RENAME.connect("pressed",self,"_on_rename")
	RENAMEBOX.connect("confirmed",self,"RENAME_CONFIRMED")
#	specify_box_type(initial_state.get("type","bool"))
	set_data(initial_state)

func changed(how = null):
	if CONTAINER:
		CONTAINER.has_changed()

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
	type = type.to_lower()
	if type != current_box_type:
		if loaded_box and not loaded_box.is_queued_for_deletion():
			CONTENT.remove_child(loaded_box)
			loaded_box.queue_free()
		for i in CONTENT.get_children():
			if i and not i.is_queued_for_deletion():
				CONTENT.remove_child(i)
				i.queue_free()
		if type in boxes:
			loaded_box = boxes[type].instance()
			CONTENT.add_child(loaded_box)
	elif not loaded_box or (loaded_box and not loaded_box.is_queued_for_deletion()):
		if type in boxes:
			loaded_box = boxes[type].instance()
			CONTENT.add_child(loaded_box)
	if loaded_box:
		loaded_box.visible = true

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
	if loaded_box:
		data = loaded_box.get_data().duplicate(true)
	if current_box_type == "optionbutton" and not data.get("options",[]).size():
		return {}
	data["type"] = current_box_type
	return data

func set_data(STATE):
	specify_box_type(STATE.get("type","bool"))
	if loaded_box:
		loaded_box.set_data(STATE)

func _toggle_pressed():
	toggled = !toggled
	update()

func _on_delete():
	DELETEMENU.dialog_text = deleteformat % boxname
	DELETEMENU.popup_centered()

func DELETE():
	if CONTAINER:
		CONTAINER.delete(boxname)

func _on_rename():
	RENAMEOPTS.clear()
	for i in config_types:
		RENAMEOPTS.add_item(i)
	var current_index = config_types.find(current_box_type)
	if current_index < 0:
		current_index = 0
	RENAMEOPTS.select(current_index)
	RENAMEEDIT.text = boxname
	RENAMEEDIT.caret_position = boxname.length()
	RENAMEBOX.popup_centered()
	RENAMEEDIT.grab_focus()
	toggled = false

func RENAME_CONFIRMED():
	if CONTAINER:
		var newname = RENAMEEDIT.text
		var newtype = config_types[RENAMEOPTS.selected]
		if newname or newtype != current_box_type:
			if newname != boxname:
				CONTAINER.rename(boxname,newname)
			if newtype != current_box_type:
				var state = get_data().duplicate(true)
				specify_box_type(newtype)
				if newtype == "optionbutton":
					state["options"] = PoolStringArray(["EXAMPLE_OPTION"])
				set_data(state)
			RENAMEBOX.hide()

func _draw():
	if CONTENT:
		CONTENT.visible = toggled
		TOGGLE.text = boxname
