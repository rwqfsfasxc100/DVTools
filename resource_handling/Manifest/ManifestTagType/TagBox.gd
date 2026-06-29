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

var initial_type = null

func _enter_tree():
	if initial_type != null:
		$BOX/CONTENT.initialize(initial_type)

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

func get_data():
	var value = $BOX/CONTENT.get_property_value()[0]
	var out = {
		"value":value,
		"type":property_assignment[typeof(value)].to_lower()
	}
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

const property_assignment = {
	TYPE_NIL:"null",
	TYPE_BOOL:"bool",
	TYPE_INT:"int",
	TYPE_REAL:"float",
	TYPE_STRING:"string",
	TYPE_VECTOR2:"Vector2",
	TYPE_RECT2:"Rect2",
	TYPE_VECTOR3:"Vector3",
	TYPE_TRANSFORM2D:"Transform2D",
	TYPE_COLOR:"Color",
	TYPE_DICTIONARY:"Dictionary",
	TYPE_ARRAY:"Array",
	TYPE_RAW_ARRAY:"PoolByteArray",
	TYPE_INT_ARRAY:"PoolIntArray",
	TYPE_REAL_ARRAY:"PoolRealArray",
	TYPE_STRING_ARRAY:"PoolStringArray",
	TYPE_VECTOR2_ARRAY:"PoolVector2Array",
	TYPE_VECTOR3_ARRAY:"PoolVector3Array",
	TYPE_COLOR_ARRAY:"PoolColorArray",
}
