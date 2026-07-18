tool
extends MarginContainer

signal pressed

var container

var script_path:String = ""

onready var label = $HBoxContainer/Label
onready var display_button = $DisplayButton
onready var press_button = $PressButton
onready var close_button = $HBoxContainer/CloseButton

func _ready():
	press_button.connect("pressed",self,"_on_selected")
	close_button.connect("pressed",self,"_on_close")
	display_button.set_physics_process(false)
	display_button.set_process(false)


func _on_selected():
	emit_signal("pressed")

func set_text(text:String):
	label.text = text

func _on_close():
	if container.tabs[script_path].needs_save:
		pass
	else:
		container.remove(script_path)

var is_active_tab = false

func set_active_tab(how:bool):
	is_active_tab = how
	if how:
		container.active_tab = self
	
func _process(_delta):
	if is_active_tab:
		display_button.self_modulate = Color.gray
	else:
		display_button.self_modulate = Color.white
