tool
extends "res://addons/DVTools/tool_panel/panels/PanelBase.gd"

onready var slot_order_list = get_node_or_null(NodePath("VBoxContainer/Slot Order/VBoxContainer/ScrollContainer/VBoxContainer"))
onready var slot_order_relative_list = get_node_or_null(NodePath("VBoxContainer/Relative Slot Order/VBoxContainer/ScrollContainer/VBoxContainer"))
onready var slot_order_add = get_node_or_null(NodePath("VBoxContainer/Slot Order/VBoxContainer/Button"))
onready var slot_order_relative_add = get_node_or_null(NodePath("VBoxContainer/Relative Slot Order/VBoxContainer/Button"))

onready var regular_container = load("res://addons/DVTools/tool_panel/panels/SLOT_ORDER.gd/regular_order/RegularOrderEntry.tscn")

func _ready():
	if not this_script_path.begins_with("new://"):
		var data = __get_script_constant_map_without_load(this_script_path)
		
		print(JSON.print(data,"\t"))
	get_available_slot_node_names()






















func get_available_slot_node_names():
	var panel_settings = container_panel.tool_panel.plugin_settings
	var node_names:PoolStringArray = panel_settings.get_upgrades_slots()
	for i in fetch_data_from_all_drivers("ADD_EQUIPMENT_SLOTS.gd"):
		var data:Dictionary = __get_script_constant_map_without_load(i)
		for slot in data:
			var d = data[slot]
			if "slot_node_name" in d:
				node_names.append(d["slot_node_name"])
	print(node_names)
	


