tool
extends MarginContainer

signal reload_scripts

onready var tab_container = $VBoxContainer/ScrollContainer/TabList
onready var FileMenu = $VBoxContainer/Menu/File

func load_this_file(file_to_load:String):
	if tab_container and tab_container.has_method("load_this_script"):
		tab_container.load_this_script(file_to_load)

var closing_scripts_close_entries = false

func close_script(script_path:String):
	if closing_scripts_close_entries:
		tab_container.remove(script_path)

func _ready():
	FileMenu.connect("selected",self,"_on_file_operation")

signal operation(operation)
func _on_file_operation(operation:String):
	emit_signal("operation",operation)

func reload_all_scripts():
	emit_signal("reload_scripts")

