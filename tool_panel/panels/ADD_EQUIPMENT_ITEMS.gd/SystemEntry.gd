tool
extends HBoxContainer

var panel
var stored_state:Dictionary = {}

onready var mainbutton = $MainButton
onready var deletebutton = $DELETE
onready var confirmation = $ConfirmationDialog

var confirm_format = ""

func _ready():
	mainbutton.connect("pressed",self,"_on_pressed")
	deletebutton.connect("pressed",self,"_check_delete")
	confirmation.connect("confirmed",self,"_on_delete")
	confirm_format = confirmation.dialog_text
	yield(get_tree(),"physics_frame")
	if stored_state and "system" in stored_state:
		var sys = stored_state.get("system","SYSTEM_EXAMPLE")
		mainbutton.text = sys
		mainbutton.hint_tooltip = sys

func _on_pressed():
	if panel and panel.has_method("_safe_open_from_button"):
		panel._safe_open_from_button(self)

func _on_delete():
	if panel and panel.has_method("_delete_this_button"):
		panel._delete_this_button(self)

func _change_system_display(how):
	if panel and panel.current_button == self:
		mainbutton.text = how
		mainbutton.hint_tooltip = how

func _check_delete():
	confirmation.dialog_text = confirm_format % stored_state.get("system","SYSTEM_EXAMPLE")
	confirmation.popup_centered()
