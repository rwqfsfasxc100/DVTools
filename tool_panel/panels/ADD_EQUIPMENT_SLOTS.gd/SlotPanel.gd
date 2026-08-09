tool
extends "res://addons/DVTools/tool_panel/panels/PanelBase.gd"

var current_button = null

onready var button_list = $HSplitContainer/HBoxContainer/SlotList/ScrollContainer/VBoxContainer

onready var lc = get_node("HSplitContainer/HBoxContainer2/ScrollContainer/VBoxContainer")
onready var add_entry_button = $HSplitContainer/HBoxContainer/SlotList/AddEntry

# TODO:
# Overrides need to be arrays of dropdowns, specifically for equipment.

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
	
	lc.get_node("slot_type/dropdown/TagPopup").initialize_current_tags()
	lc.get_node("alignment/dropdown/TagPopup").initialize_current_tags()
	lc.get_node("hardpoint_type/dropdown/TagPopup").initialize_current_tags()
	_open_this_button(button_list.get_child(0))
	
	yield(get_tree().create_timer(0.1),"timeout")
	lc.get_node("system_slot/property_editor").connect("changed",self,"mark_as_changed")
	lc.get_node("slot_node_name/property_editor").connect("changed",self,"mark_as_changed")
	lc.get_node("slot_display_name/property_editor").connect("changed",self,"mark_as_changed")
	lc.get_node("has_none/property_editor").connect("changed",self,"mark_as_changed")
	lc.get_node("always_display/property_editor").connect("changed",self,"mark_as_changed")
	lc.get_node("restrict_type/property_editor").connect("changed",self,"mark_as_changed")
	lc.get_node("open_by_default/property_editor").connect("changed",self,"mark_as_changed")
	lc.get_node("limit_ships/property_editor").connect("changed",self,"mark_as_changed")
	lc.get_node("prevent_ships/property_editor").connect("changed",self,"mark_as_changed")
	lc.get_node("add_vanilla_equipment/property_editor").connect("changed",self,"mark_as_changed")
	lc.get_node("restriction/property_editor").connect("changed",self,"mark_as_changed")
	lc.get_node("override_additive/property_editor").connect("changed",self,"mark_as_changed")
	lc.get_node("override_subtractive/property_editor").connect("changed",self,"mark_as_changed")
	lc.get_node("restrict_hold_type/RestrictHoldType").connect("item_selected",self,"mark_as_changed")
	lc.get_node("alignment/dropdown/TagPopup").connect("item_selected",self,"mark_as_changed")
	lc.get_node("hardpoint_type/dropdown/TagPopup").connect("item_selected",self,"mark_as_changed")
	lc.get_node("slot_type/dropdown/TagPopup").connect("item_selected",self,"mark_as_changed")
	lc.get_node("alignment/dropdown/LineEdit").connect("text_changed",self,"mark_as_changed")
	lc.get_node("hardpoint_type/dropdown/LineEdit").connect("text_changed",self,"mark_as_changed")
	lc.get_node("slot_type/dropdown/LineEdit").connect("text_changed",self,"mark_as_changed")

func mark_as_changed(propA = null):
	needs_save = true

func save_driver_data() -> String:
	var out:String = ""
	can_change_sys_display = false
	for i in range(button_list.get_child_count()):
		var btn = button_list.get_child(i)
		var st = btn.stored_state
		btn.saved_hash = hash(st)
		var ov = convert_to_constant(st,"_%03d" % i)
		if ov:
			out += ov + "\n\n"
	can_change_sys_display = true
	needs_save = false
	return out

func _safe_open_from_button(btn):
	if is_valid(current_button):
		current_button.stored_state = get_this_dict_for_saving()
		current_button._change_system_display()
		current_button.calc_hash()
	current_button = null
	_open_this_button(btn)

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

func _delete_this_button(btn):
	button_list.remove_child(btn)
	btn.queue_free()
	needs_save = true
	yield(get_tree(),"idle_frame")
	if not button_list.get_child_count():
		add_entry()
	else:
		_open_this_button(button_list.get_child(0))

func add_entry(system_dict:Dictionary = {}):
	needs_save = true
	_safe_open_from_button(add_example_entry(system_dict))

var can_change_sys_display = true

var ctr = 0
func _physics_process(delta):
	ctr += 1
	if ctr > 4:
		ctr = 0
		if can_change_sys_display and is_valid(current_button):
			var dict = get_this_dict_for_saving()
			current_button.stored_state = dict
			if current_button.has_method("_change_system_display"):
				current_button._change_system_display()

func is_valid(button):
	return button and is_instance_valid(button) and not button.is_queued_for_deletion()

func set_properties_from_dict(dict:Dictionary):
	if not lc:
		lc = get_node("HSplitContainer/HBoxContainer2/ScrollContainer/VBoxContainer")
	lc.get_node("system_slot/property_editor").set_property_value(dict.get("system_slot",""))
	lc.get_node("slot_node_name/property_editor").set_property_value(dict.get("slot_node_name","ExampleSlotName"))
	lc.get_node("slot_display_name/property_editor").set_property_value(dict.get("slot_display_name","SLOT_EXAMPLE"))
	lc.get_node("has_none/property_editor").set_property_value(dict.get("has_none",true))
	lc.get_node("always_display/property_editor").set_property_value(dict.get("always_display",true))
	lc.get_node("restrict_type/property_editor").set_property_value(dict.get("restrict_type",""))
	lc.get_node("open_by_default/property_editor").set_property_value(dict.get("open_by_default",false))
	lc.get_node("limit_ships/property_editor").set_property_value(PoolStringArray(dict.get("limit_ships",[])))
	lc.get_node("prevent_ships/property_editor").set_property_value(PoolStringArray(dict.get("prevent_ships",[])))
	lc.get_node("add_vanilla_equipment/property_editor").set_property_value(dict.get("add_vanilla_equipment",true))
	lc.get_node("slot_type/dropdown/TagPopup").initialize_current_tags(dict.get("slot_type","HARDPOINT"))
	lc.get_node("hardpoint_type/dropdown/TagPopup").initialize_current_tags(dict.get("hardpoint_type",""))
	lc.get_node("alignment/dropdown/TagPopup").initialize_current_tags(dict.get("alignment",""))
	lc.get_node("restriction/property_editor").set_property_value(dict.get("restriction",""))
	lc.get_node("override_additive/property_editor").set_property_value(PoolStringArray(dict.get("override_additive",[])))
	lc.get_node("override_subtractive/property_editor").set_property_value(PoolStringArray(dict.get("override_subtractive",[])))
	lc.get_node("restrict_hold_type/RestrictHoldType").set_hold_type(dict.get("restrict_hold_type",""))
	

func get_this_dict_for_saving() -> Dictionary:
	if not lc:
		lc = get_node("HSplitContainer/HBoxContainer2/ScrollContainer/VBoxContainer")
	var out:Dictionary = {}
	var system_slot = lc.get_node("system_slot/property_editor").get_property_value()[0]
	var slot_node_name = lc.get_node("slot_node_name/property_editor").get_property_value()[0]
	var slot_display_name = lc.get_node("slot_display_name/property_editor").get_property_value()[0]
	var has_none = lc.get_node("has_none/property_editor").get_property_value()[0]
	var always_display = lc.get_node("always_display/property_editor").get_property_value()[0]
	var restrict_type = lc.get_node("restrict_type/property_editor").get_property_value()[0]
	var open_by_default = lc.get_node("open_by_default/property_editor").get_property_value()[0]
	var limit_ships = lc.get_node("limit_ships/property_editor").get_property_value()[0]
	var prevent_ships = lc.get_node("prevent_ships/property_editor").get_property_value()[0]
	var add_vanilla_equipment = lc.get_node("add_vanilla_equipment/property_editor").get_property_value()[0]
	var slot_type = lc.get_node("slot_type/dropdown/TagPopup").get_selected_string()
	var hardpoint_type = lc.get_node("hardpoint_type/dropdown/TagPopup").get_selected_string()
	var align = lc.get_node("alignment/dropdown/TagPopup").get_selected_string()
	var restriction = lc.get_node("restriction/property_editor").get_property_value()[0]
	var override_additive = lc.get_node("override_additive/property_editor").get_property_value()[0]
	var override_subtractive = lc.get_node("override_subtractive/property_editor").get_property_value()[0]
	var restrict_hold_type = lc.get_node("restrict_hold_type/RestrictHoldType").get_hold_type()
	if slot_node_name:
		if system_slot:
			out["system_slot"] = system_slot
		out["slot_node_name"] = slot_node_name
		if slot_display_name:
			out["slot_display_name"] = slot_display_name
		if not has_none:
			out["has_none"] = false
		if not always_display:
			out["always_display"] = false
		if restrict_type:
			out["restrict_type"] = restrict_type
		if open_by_default:
			out["open_by_default"] = true
		if not limit_ships.empty():
			out["limit_ships"] = limit_ships
		if not prevent_ships.empty():
			out["prevent_ships"] = prevent_ships
		if not add_vanilla_equipment:
			out["add_vanilla_equipment"] = false
		if slot_type:
			out["slot_type"] = slot_type
		if slot_type == "HARDPOINT":
			if hardpoint_type:
				out["hardpoint_type"] = hardpoint_type
			if align:
				out["alignment"] = align
		if restriction:
			out["restriction"] = restriction
		if not override_additive.empty():
			out["override_additive"] = override_additive
		if not override_subtractive.empty():
			out["override_subtractive"] = override_subtractive
		if restrict_hold_type:
			out["restrict_hold_type"] = restrict_hold_type
	
	return out

