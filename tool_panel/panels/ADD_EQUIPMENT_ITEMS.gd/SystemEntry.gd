tool
extends HBoxContainer

var panel
var stored_state:Dictionary = {}

onready var mainbutton = $MainButton
onready var deletebutton = $DELETE
onready var confirmation = $ConfirmationDialog

var confirm_format = ""

var saved_hash = 0

func calc_hash():
	var nh = hash(stored_state)
	if saved_hash and panel and saved_hash != nh:
		panel.needs_save = true
	else:
		saved_hash = nh

func _ready():
	orig_state = stored_state
	mainbutton.connect("pressed",self,"_on_pressed")
	deletebutton.connect("pressed",self,"_check_delete")
	confirmation.connect("confirmed",self,"_on_delete")
	confirm_format = confirmation.dialog_text
	_change_system_display()

var orig_state = {}

func _on_pressed():
	if panel and panel.has_method("_safe_open_from_button"):
		panel._safe_open_from_button(self)

func _on_delete():
	if panel and panel.has_method("_delete_this_button"):
		panel._delete_this_button(self)

func _change_system_display():
	if stored_state and "system" in stored_state:
		var sys = stored_state.get("system","SYSTEM_EXAMPLE")
		mainbutton.text = sys
		mainbutton.hint_tooltip = sys

func _check_delete():
	confirmation.dialog_text = confirm_format % stored_state.get("system","SYSTEM_EXAMPLE")
	confirmation.popup_centered()
