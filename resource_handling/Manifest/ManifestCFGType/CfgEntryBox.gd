tool
extends HBoxContainer

onready var TOGGLE = $BOX/BUTTONS/TOGGLE
onready var RENAME = $BOX/BUTTONS/RENAME
onready var DELETE = $BOX/BUTTONS/DELETE
onready var DELETEMENU = $DoDelete
onready var CONTENT = $BOX/CONTENT
onready var RENAMEBOX = $RenameTo
onready var RENAMEEDIT = $RenameTo/LineEdit

var toggled = false

var boxname = ""

var deleteformat = ""

var CONTAINER

var initial_state = {}

func _ready():
	deleteformat = DELETEMENU.dialog_text
	TOGGLE.connect("pressed",self,"_toggle_pressed")
	DELETE.connect("pressed",self,"_on_delete")
	DELETEMENU.connect("confirmed",self,"DELETE")
	TOGGLE.text = boxname
	RENAME.connect("pressed",self,"_on_rename")
	RENAMEBOX.connect("confirmed",self,"RENAME_CONFIRMED")
	

func changed(how = null):
	if CONTAINER:
		CONTAINER.has_changed()



func specify_box_type(type:String):
	for i in CONTENT.get_children():
		i.visible = i.name == type.to_lower()

func get_data():
	for i in CONTENT.get_children():
		if i.visible and i.has_method("get_data"):
			return i.get_data()
	return {}

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
	RENAMEEDIT.text = boxname
	RENAMEEDIT.caret_position = boxname.length()
	RENAMEBOX.popup_centered()
	RENAMEEDIT.grab_focus()

func RENAME_CONFIRMED():
	if CONTAINER:
		var newname = RENAMEEDIT.text
		if newname:
			if newname != boxname:
				CONTAINER.rename(boxname,newname)
			RENAMEBOX.hide()

func _draw():
	if CONTENT:
		CONTENT.visible = toggled
		TOGGLE.text = boxname
