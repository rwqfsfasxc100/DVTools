tool
extends "res://addons/DVTools/tool_panel/panels/PanelBase.gd"

var current_button = null

onready var button_list = $HSplitContainer/HBoxContainer/SlotList/ScrollContainer/VBoxContainer

onready var lc = get_node("HSplitContainer/HBoxContainer2/ScrollContainer/VBoxContainer")
onready var add_entry_button = $HSplitContainer/HBoxContainer/SlotList/AddEntry

func _ready():
	add_entry_button.connect("pressed",self,"add_entry")
	if not this_script_path.begins_with("new://"):
		var data = __get_script_constant_map_without_load(this_script_path)
		if data:
			for i in data:
				yield(get_tree(),"idle_frame")
				add_example_entry(data[i])
	yield(get_tree(),"idle_frame")
	if not button_list.get_child_count():
		add_example_entry()
	
	lc.get_node("slot_type/TagPopup").initialize_current_tags()
	lc.get_node("alignment/TagPopup").initialize_current_tags()
	lc.get_node("hardpoint_type/TagPopup").initialize_current_tags()
	_open_this_button(button_list.get_child(0))

func save_driver_data() -> String:
	var out:String = ""
	
	
	
	
	return out

func _open_this_button(btn):
	current_button = btn
	set_properties_from_dict(btn.stored_state)

var slot_entry = load("res://addons/DVTools/tool_panel/panels/ADD_EQUIPMENT_SLOTS.gd/SlotEntry.tscn")

func add_example_entry(system_dict:Dictionary = {}):
	var button = slot_entry.instance()
	button.panel = self
	if system_dict.empty():
		needs_save = true
	button.stored_state = system_dict.duplicate(true)
	button.calc_hash()
#	button.saved_hash = hash(button.stored_state)
	button_list.add_child(button)
	return button

func set_properties_from_dict(dict:Dictionary):
	if not lc:
		lc = get_node("HSplitContainer/HBoxContainer2/HSplitContainer/HBoxContainer/ScrollContainer/VBoxContainer")
	
