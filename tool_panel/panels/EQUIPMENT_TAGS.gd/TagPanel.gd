tool
extends "res://addons/DVTools/tool_panel/panels/PanelBase.gd"

onready var lc = get_node("ScrollContainer/VBoxContainer")

var can_mark_unsaved = false
func _ready():
	if not this_script_path.begins_with("new://"):
		var data = __get_script_constant_map_without_load(this_script_path).get("EQUIPMENT_TAGS",{})
		set_properties_from_dict(data)
	yield(get_tree().create_timer(0.1),"timeout")
	lc.get_node("slot_types/property_editor").connect("changed",self,"mark_for_saving")
	lc.get_node("equipment_types/property_editor").connect("changed",self,"mark_for_saving")
	lc.get_node("hardpoint_types/property_editor").connect("changed",self,"mark_for_saving")
	lc.get_node("alignments/property_editor").connect("changed",self,"mark_for_saving")
	lc.get_node("slot_defaults/default_handler").connect("changed",self,"mark_for_saving")
	yield(get_tree().create_timer(0.05),"timeout")
	can_mark_unsaved = true

func mark_for_saving():
	needs_save = true

func save_driver_data() -> String:
	needs_save = false
	return convert_to_constant(get_these_tags(),"EQUIPMENT_TAGS")

func update_available_tags():
	if container_panel:
		fetch_tags()

var slot_types:Array = []
var equipment_types:Array = []
var alignments:Array = []
var hardpoint_types:Array = []
var slot_defaults:Dictionary = {}

func curate_tags(tags:Array) -> Array:
	var out:Array = Array()
	for i in tags:
		if i.get_file() == "EQUIPMENT_TAGS.gd":
			out.append(i)
	return out

func fetch_tags():
	var panel_settings = container_panel.tool_panel.plugin_settings
	var vanilla_tags = __get_script_constant_map_without_load("res://HevLib/scenes/equipment/vanilla_defaults/slot_tagging.gd")
	var equipment_tag_files = []
	slot_types = vanilla_tags.get("slot_types",[])
	equipment_types = vanilla_tags.get("equipment_types",[])
	alignments = vanilla_tags.get("alignments",[])
	hardpoint_types = vanilla_tags.get("hardpoint_types",[])
	slot_defaults = vanilla_tags.get("slot_defaults",{})
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
		if tag == this_script_path:
			continue
		var nodes = __get_script_constant_map_without_load(tag).get("EQUIPMENT_TAGS",{})
		var slotTypes : Array = nodes.get("slot_types",[])
		var equipmentItems : Array = nodes.get("equipment_types",[])
		var AL : Array = nodes.get("alignments",[])
		var hardpointTypes : Array = nodes.get("hardpoint_types",[])
		var slotDefaults : Dictionary = nodes.get("slot_defaults",{})
		if slotTypes:
			for st in slotTypes:
				if not st in slot_types:
					slot_types.append(st)
		if equipmentItems:
			for st in equipmentItems:
				if not st in equipment_types:
					equipment_types.append(st)
		if AL:
			for st in AL:
				if not st in alignments:
					alignments.append(st)
		if hardpointTypes:
			for st in hardpointTypes:
				if not st in hardpoint_types:
					hardpoint_types.append(st)
		if slotDefaults:
			for st in slotDefaults:
				if st in slot_defaults:
					for item in slotDefaults.get(st):
						if not item in slot_defaults.get(st):
							slot_defaults[st].append(item)
				else:
					slot_defaults.merge({st:slotDefaults.get(st)})

func get_these_tags() -> Dictionary:
	if not lc:
		lc = get_node("ScrollContainer/VBoxContainer")
	var out = {
		"slot_types":[],
		"equipment_types":[],
		"alignments":[],
		"hardpoint_types":[],
		"slot_defaults":{}
	}
	out["slot_types"].append_array(lc.get_node("slot_types/property_editor").get_property_value()[0])
	out["equipment_types"].append_array(lc.get_node("equipment_types/property_editor").get_property_value()[0])
	out["alignments"].append_array(lc.get_node("alignments/property_editor").get_property_value()[0])
	out["hardpoint_types"].append_array(lc.get_node("hardpoint_types/property_editor").get_property_value()[0])
	out["slot_defaults"].merge(lc.get_node("slot_defaults/default_handler").get_property_value()[0])
	return out

func set_properties_from_dict(dict:Dictionary):
	if not lc:
		lc = get_node("ScrollContainer/VBoxContainer")
	lc.get_node("slot_types/property_editor").set_property_value(PoolStringArray(dict.get("slot_types",[])))
	lc.get_node("equipment_types/property_editor").set_property_value(PoolStringArray(dict.get("equipment_types",[])))
	lc.get_node("alignments/property_editor").set_property_value(PoolStringArray(dict.get("alignments",[])))
	lc.get_node("hardpoint_types/property_editor").set_property_value(PoolStringArray(dict.get("hardpoint_types",[])))
	lc.get_node("slot_defaults/default_handler").set_property_value(dict.get("slot_defaults",{}))

