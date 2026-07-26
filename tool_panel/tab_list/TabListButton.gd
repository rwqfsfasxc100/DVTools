tool
extends MarginContainer

signal pressed

var container

var script_path:String = ""

onready var label = $HBoxContainer/Label
onready var display_button = $DisplayButton
onready var press_button = $PressButton
onready var close_button = $HBoxContainer/CloseButton
onready var confirm_close = $ConfirmationDialog

var confirm_format = ""

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if press_button.get_rect().has_point(event.position - press_button.get_global_transform_with_canvas().get_origin()):
#			if event.button_index == BUTTON_LEFT:
#				_on_selected()
			if event.button_index == BUTTON_MIDDLE:
				_on_close()

func _ready():
	press_button.connect("pressed",self,"_on_selected")
	close_button.connect("pressed",self,"_on_close")
	display_button.set_physics_process(false)
	display_button.set_process(false)
	confirm_close.add_button("Don't save",true,"dont_save")
	confirm_close.get_ok().text = "Save & Close"
	confirm_close.connect("confirmed",self,"save_and_close")
	confirm_close.connect("custom_action",self,"cws")
	confirm_format = confirm_close.dialog_text
	if container:
		container.connect("save_confirmed",self,"save_confirmed")

func SAVE():
	if container and container.has_method("SAVE"):
		container.SAVE()

func _on_selected():
	emit_signal("pressed")

func set_text(text:String):
	label.text = text

func cws(how):
	close_without_saving()

func _on_close():
	if container.tabs[script_path].needs_save:
		confirm_close.dialog_text = confirm_format % script_path
		confirm_close.popup_centered()
	else:
		close_without_saving()

var close_after_save = false

func save_and_close():
	SAVE()
	close_after_save = true

func save_confirmed():
	if close_after_save:
		close_without_saving()

func close_without_saving():
	container.remove(script_path)

var is_active_tab = false

func set_active_tab(how:bool):
	print(self," setting active tab: ",how)
	is_active_tab = how
	if how:
		container.active_tab = self
	
func _process(_delta):
	if display_button:
		if is_active_tab:
			display_button.self_modulate = Color.gray
		else:
			display_button.self_modulate = Color.white
