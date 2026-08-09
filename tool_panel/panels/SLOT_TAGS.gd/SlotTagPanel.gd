tool
extends "res://addons/DVTools/tool_panel/panels/PanelBase.gd"

var panel = self

var can_mark_unsaved = false
func _ready():
	get_equipment_tags()
	$VBoxContainer/ADD.connect("pressed",self,"show_add_panel")
	$ConfirmationDialog.connect("confirmed",self,"create_item")
	$ConfirmationDialog/VBoxContainer/HBoxContainer/OptionButton.connect("item_selected",self,"select_opt")
	$ConfirmationDialog/VBoxContainer/HBoxContainer/LineEdit.text = ""
	if not this_script_path.begins_with("new://"):
		var data = __get_script_constant_map_without_load(this_script_path).get("SLOT_TAGS",{})
		for i in data:
			create_item(i,data.get(i))
	can_mark_unsaved = true

var equipment_types:Array = []

func get_equipment_tags():
	var panel_settings = container_panel.tool_panel.plugin_settings
	var vanilla_tags = __get_script_constant_map_without_load("res://HevLib/scenes/equipment/vanilla_defaults/slot_tagging.gd")
	var equipment_tag_files = []
	equipment_types = vanilla_tags.get("equipment_types",[])
	if panel_settings:
			match panel_settings.get_value("driver_tag_discovery_preference"):
				0:
					equipment_tag_files = panel_settings.drivers_by_type.get("EQUIPMENT_TAGS.gd",[])
				1:
					equipment_tag_files = curate_tags(panel_settings.get_value("use_specific_tags"))
				2:
					if not this_script_path.begins_with("new://"):
						var thisDir = this_script_path.split("/",false)[1]
						for i in panel_settings.drivers_by_type.get("EQUIPMENT_TAGS.gd",[]):
							if i.split("/",false)[1] == thisDir:
								equipment_tag_files.append(i)
	for tag in equipment_tag_files:
		for st in __get_script_constant_map_without_load(tag).get("EQUIPMENT_TAGS",{}).get("equipment_types",[]):
			if not st in equipment_types:
				equipment_types.append(st)

func save_driver_data() -> String:
	needs_save = false
	return convert_to_constant(get_data(),"SLOT_TAGS")

func get_data():
	var out = {}
	for i in $VBoxContainer/ScrollContainer/VBoxContainer.get_children():
		if "slot_node_name" in i and i.slot_node_name:
			out[i.slot_node_name] = i.get_data()
	return out

func curate_tags(tags:Array) -> Array:
	var out:Array = Array()
	for i in tags:
		if i.get_file() == "ADD_EQUIPMENT_SLOTS.gd":
			out.append(i)
	return out

var node_names:Array = Array()
func fetch_tags():
	node_names.clear()
	var panel_settings = container_panel.tool_panel.plugin_settings
	node_names = __get_script_constant_map_without_load("res://HevLib/scenes/equipment/vanilla_defaults/slot_tagging.gd").vanilla_equipment_defaults_for_reference.keys()
	var slot_tag_files = []
	if panel_settings:
			match panel_settings.get_value("driver_tag_discovery_preference"):
				0:
					slot_tag_files = panel_settings.drivers_by_type.get("ADD_EQUIPMENT_SLOTS.gd",[])
				1:
					slot_tag_files = curate_tags(panel_settings.get_value("use_specific_tags"))
				2:
					if not this_script_path.begins_with("new://"):
						var thisDir = this_script_path.split("/",false)[1]
						for i in panel_settings.drivers_by_type.get("ADD_EQUIPMENT_SLOTS.gd",[]):
							if i.split("/",false)[1] == thisDir:
								slot_tag_files.append(i)
					
	for tag in slot_tag_files:
		var items:Dictionary = __get_script_constant_map_without_load(tag)
		for i in items:
			var id = items[i]
			if "slot_node_name" in id:
				var snn = id.slot_node_name
				if snn and not snn in node_names:
					node_names.append(snn)

var available_opts = []
func show_add_panel():
	var c = $ConfirmationDialog
	var le = $ConfirmationDialog/VBoxContainer/HBoxContainer/LineEdit
	var opt = $ConfirmationDialog/VBoxContainer/HBoxContainer/OptionButton
	opt.clear()
	fetch_tags()
	available_opts.clear()
	var current = get_current_nodes()
	for i in node_names:
		if not i in current:
			available_opts.append(i)
	for i in available_opts:
		opt.add_item(i)
	opt.select(0)
	le.text = available_opts[0]
	c.popup_centered()

func get_current_nodes():
	var out = []
	for i in $VBoxContainer/ScrollContainer/VBoxContainer.get_children():
		if "slot_node_name" in i and i.slot_node_name:
			out.append(i.slot_node_name)
	return out

func select_opt(idx:int):
	$ConfirmationDialog/VBoxContainer/HBoxContainer/LineEdit.text = available_opts[idx]

var slot_base = load("res://addons/DVTools/tool_panel/panels/SLOT_TAGS.gd/SlotPanelBase.tscn")
func create_item(item_name:String = "",data:Dictionary = {}):
	if item_name.empty():
		item_name = $ConfirmationDialog/VBoxContainer/HBoxContainer/LineEdit.text
	var slot = slot_base.instance()
	slot.panel = self
	slot.slot_node_name = item_name
	slot.init_data = data.duplicate(true)
	$VBoxContainer/ScrollContainer/VBoxContainer.add_child(slot)
