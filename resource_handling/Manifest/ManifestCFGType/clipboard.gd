tool
extends VBoxContainer

var p:Node

onready var entry_box = get_node_or_null("../../../../..")
onready var section_box = entry_box.get_node_or_null("../../../..")
onready var mod_box = section_box.get_node_or_null("../../..")

var format:Array = ["","",""]

func _ready() -> void:
	reformat()
	var set_button:Button = $CopySetGet/Button
	var get_button:Button = $CopySetGet/Button2
	var sub_button:Button = $CopySubscribe/Button
	var unsub_button:Button = $CopySubscribe/Button2
	
	set_button.connect("pressed",self,"_copy_set")
	get_button.connect("pressed",self,"_copy_get")
	sub_button.connect("pressed",self,"_copy_sub")
	unsub_button.connect("pressed",self,"_copy_unsub")

func reformat():
	format[0] = mod_box.manifest_name
	format[1] = section_box.boxname
	format[2] = entry_box.boxname


func _copy_set():
	reformat()
	OS.set_clipboard(get_set())
func _copy_get():
	reformat()
	OS.set_clipboard(get_get())
func _copy_sub():
	reformat()
	OS.set_clipboard(get_sub())
func _copy_unsub():
	reformat()
	OS.set_clipboard(get_unsub())

func get_set():return "__store_value(\"%s\",\"%s\",\"%s\")" % format
func get_get():return "__get_value(\"%s\",\"%s\",\"%s\")" % format
func get_sub():return "__subscribe_to_setting_change(\"function_name\",null,\"%s\",\"%s\",\"%s\")" % format
func get_unsub():return "__disconnect_subscription(\"function_name\",null,\"%s\",\"%s\",\"%s\")" % format
