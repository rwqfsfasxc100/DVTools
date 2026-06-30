tool
extends HBoxContainer

onready var TOGGLE = $BOX/BUTTONS/TOGGLE
onready var RENAME = $BOX/BUTTONS/RENAME
onready var DELETE = $BOX/BUTTONS/DELETE
onready var DELETEMENU = $DoDelete
onready var CONTENT = $BOX/CONTENT
onready var URL = $BOX/CONTENT/URL/LineEdit
onready var RENAMEBOX = $RenameTo
onready var RENAMEEDIT = $RenameTo/LineEdit

var toggled = false

var boxname = ""

var deleteformat = ""

var CONTAINER

var initial_state = 100.0

func _ready():
	deleteformat = DELETEMENU.dialog_text
	TOGGLE.connect("pressed",self,"_toggle_pressed")
	DELETE.connect("pressed",self,"_on_delete")
	DELETEMENU.connect("confirmed",self,"DELETE")
	TOGGLE.text = boxname
	RENAME.connect("pressed",self,"_on_rename")
	RENAMEBOX.connect("confirmed",self,"RENAME_CONFIRMED")
	URL.connect("text_entered",self,"_LE_text_changed")
	URL.connect("focus_exited",self,"_lost_focus")
	URL.text = str(initial_state)

func changed(how = null):
	if CONTAINER:
		CONTAINER.has_changed()

func _LE_text_changed(text:String):
	var ft = float(text)
	URL.text = str(ft)
	changed()

func _lost_focus():
	var txt = URL.text
	_LE_text_changed(txt)


func get_data():
	var txt = $BOX/CONTENT/URL/LineEdit.text
	if not txt:
		txt = 100.0
	return str(txt) + "%"

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
