tool
extends HBoxContainer

onready var TOGGLE = $BOX/BUTTONS/TOGGLE
onready var RENAME = $BOX/BUTTONS/RENAME
onready var DELETE = $BOX/BUTTONS/DELETE
onready var DELETEMENU = $DoDelete
onready var CONTENT = $BOX/CONTENT
onready var URL = $BOX/CONTENT/URL/LineEdit
onready var ICON = $BOX/CONTENT/ICON/LineEdit
onready var DIROPEN = $BOX/CONTENT/ICON/DIR
onready var DIRMENU = EditorFileDialog.new()
onready var TOOLTIP = $BOX/CONTENT/TOOLTIP/LineEdit
onready var RENAMEBOX = $RenameTo
onready var RENAMEEDIT = $RenameTo/LineEdit

var toggled = false

var boxname = ""

var deleteformat = ""

var CONTAINER

var initial_state = {}

func _ready():
	deleteformat = DELETEMENU.dialog_text
	add_child(DIRMENU)
	DIRMENU.mode = EditorFileDialog.MODE_OPEN_FILE
	DIRMENU.add_filter("*.stex, *.png ; Supported icon image files")
	DIRMENU.show_hidden_files = true
	DIRMENU.rect_min_size = get_viewport().size - Vector2(200,200)
	TOGGLE.connect("pressed",self,"_toggle_pressed")
	DIROPEN.connect("pressed",self,"_open_dir")
	DIRMENU.connect("file_selected",self,"_icon_file_selected")
	DELETE.connect("pressed",self,"_on_delete")
	DELETEMENU.connect("confirmed",self,"DELETE")
	TOGGLE.text = boxname
	if "URL" in initial_state:
		URL.text = initial_state["URL"]
	if "ICON" in initial_state:
		ICON.text = initial_state["ICON"]
	if "TOOLTIP" in initial_state:
		TOOLTIP.text = initial_state["TOOLTIP"]
	RENAME.connect("pressed",self,"_on_rename")
	RENAMEBOX.connect("confirmed",self,"RENAME_CONFIRMED")
	URL.connect("text_changed",self,"changed")
	ICON.connect("text_changed",self,"changed")
	TOOLTIP.connect("text_changed",self,"changed")

func changed(how = null):
	if CONTAINER:
		CONTAINER.has_changed()


func _open_dir():
	DIRMENU.popup_centered()

func _icon_file_selected(how):
	ICON.text = how

func get_data():
	var UTXT = $BOX/CONTENT/URL/LineEdit.text
	var ITXT = $BOX/CONTENT/ICON/LineEdit.text
	var TTXT = $BOX/CONTENT/TOOLTIP/LineEdit.text
	var out = {}
	if UTXT:
		out["URL"] = UTXT
		if ITXT:
			out["ICON"] = ITXT
		if TTXT:
			out["TOOLTIP"] = TTXT
	return out

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
