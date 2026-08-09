tool
extends "res://addons/DVTools/tool_panel/panels/PanelBase.gd"

var current_button = null

onready var button_list = $HSplitContainer/HBoxContainer/SysList/ScrollContainer/VBoxContainer

onready var lc = get_node("HSplitContainer/HBoxContainer2/HSplitContainer/HBoxContainer/ScrollContainer/VBoxContainer")
onready var add_entry_button = $HSplitContainer/HBoxContainer/SysList/AddEntry

onready var system_entry = load("res://addons/DVTools/tool_panel/panels/ADD_EQUIPMENT_ITEMS.gd/SystemEntry.tscn")

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
	lc.get_node("equipment_type/dropdown/TagPopup").initialize_current_tags()
	_open_this_button(button_list.get_child(0))
	
	yield(get_tree().create_timer(0.1),"timeout")
	lc.get_node("system/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("price/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("name_override/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("description/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("manual/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("specs/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("num_val/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("capability_lock/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("test_protocol/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("default/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("control/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("story_flag/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("story_flag_min/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("story_flag_max/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("warn_if_thermal_below/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("warn_if_electric_below/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("sticker_price_format/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("sticker_price_multi_format/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("normal_color/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("installed_color/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("disabled_color/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("config_id/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("config_section/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("config_entry/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("config_invert_config/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("restriction/property_editor").connect("changed",self,"make_save_needed")
	lc.get_node("equipment_type/dropdown/TagPopup").connect("item_selected",self,"make_save_needed")
	lc.get_node("slot_type/dropdown/TagPopup").connect("item_selected",self,"make_save_needed")
	lc.get_node("alignment/dropdown/TagPopup").connect("item_selected",self,"make_save_needed")
	lc.get_node("equipment_type/dropdown/LineEdit").connect("text_changed",self,"make_save_needed")
	lc.get_node("slot_type/dropdown/LineEdit").connect("text_changed",self,"make_save_needed")
	lc.get_node("alignment/dropdown/LineEdit").connect("text_changed",self,"make_save_needed")

func make_save_needed(aval = null):
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

func _delete_this_button(btn):
	button_list.remove_child(btn)
	btn.queue_free()
	needs_save = true
	yield(get_tree(),"idle_frame")
	if not button_list.get_child_count():
		add_entry()
	else:
		_open_this_button(button_list.get_child(0))

func add_example_entry(system_dict:Dictionary = {}):
	var button = system_entry.instance()
	button.panel = self
	if system_dict.empty():
		needs_save = true
	button.stored_state = system_dict.duplicate(true)
	button.calc_hash()
#	button.saved_hash = hash(button.stored_state)
	button_list.add_child(button)
	return button

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
		lc = get_node("HSplitContainer/HBoxContainer2/HSplitContainer/HBoxContainer/ScrollContainer/VBoxContainer")
	lc.get_node("system/property_editor").set_property_value(dict.get("system","SYSTEM_EXAMPLE"))
	lc.get_node("price/property_editor").set_property_value(dict.get("price",0))
	lc.get_node("name_override/property_editor").set_property_value(dict.get("name_override",""))
	lc.get_node("description/property_editor").set_property_value(dict.get("description",""))
	lc.get_node("manual/property_editor").set_property_value(dict.get("manual",""))
	lc.get_node("specs/property_editor").set_property_value(dict.get("specs",""))
	lc.get_node("num_val/property_editor").set_property_value(dict.get("num_val",-1))
	lc.get_node("capability_lock/property_editor").set_property_value(dict.get("capability_lock",false))
	lc.get_node("test_protocol/property_editor").set_property_value(dict.get("test_protocol","fire"))
	lc.get_node("default/property_editor").set_property_value(dict.get("default",false))
	lc.get_node("control/property_editor").set_property_value(dict.get("control",""))
	lc.get_node("story_flag/property_editor").set_property_value(dict.get("story_flag",""))
	lc.get_node("story_flag_min/property_editor").set_property_value(dict.get("story_flag_min",-1))
	lc.get_node("story_flag_max/property_editor").set_property_value(dict.get("story_flag_max",-1))
	lc.get_node("warn_if_thermal_below/property_editor").set_property_value(dict.get("warn_if_thermal_below",0.0))
	lc.get_node("warn_if_electric_below/property_editor").set_property_value(dict.get("warn_if_electric_below",0.0))
	lc.get_node("sticker_price_format/property_editor").set_property_value(dict.get("sticker_price_format","%s E$"))
	lc.get_node("sticker_price_multi_format/property_editor").set_property_value(dict.get("sticker_price_multi_format","%s E$ (x%d)"))
	lc.get_node("normal_color/property_editor").set_property_value(dict.get("normal_color",Color(1,1,1,1)))
	lc.get_node("installed_color/property_editor").set_property_value(dict.get("installed_color",Color(0,1,0,1)))
	lc.get_node("disabled_color/property_editor").set_property_value(dict.get("disabled_color",Color(0.2,0.2,0.2,1)))
	lc.get_node("config_id/property_editor").set_property_value(dict.get("config",{}).get("id",""))
	lc.get_node("config_section/property_editor").set_property_value(dict.get("config",{}).get("section",""))
	lc.get_node("config_entry/property_editor").set_property_value(dict.get("config",{}).get("entry",""))
	lc.get_node("config_invert_config/property_editor").set_property_value(dict.get("config",{}).get("invert_config",""))
	lc.get_node("restriction/property_editor").set_property_value(dict.get("restriction",""))
	lc.get_node("equipment_type/dropdown/TagPopup").initialize_current_tags(dict.get("equipment_type",""))
	lc.get_node("slot_type/dropdown/TagPopup").initialize_current_tags(dict.get("slot_type","HARDPOINT"))
	lc.get_node("alignment/dropdown/TagPopup").initialize_current_tags(dict.get("alignment",""))

func get_this_dict_for_saving() -> Dictionary:
	if not lc:
		lc = get_node("HSplitContainer/HBoxContainer2/HSplitContainer/HBoxContainer/ScrollContainer/VBoxContainer")
	var out:Dictionary = {}
	var system = lc.get_node("system/property_editor").get_property_value()[0]
	var price = lc.get_node("price/property_editor").get_property_value()[0]
	var name_override = lc.get_node("name_override/property_editor").get_property_value()[0]
	var description = lc.get_node("description/property_editor").get_property_value()[0]
	var manual = lc.get_node("manual/property_editor").get_property_value()[0]
	var specs = lc.get_node("specs/property_editor").get_property_value()[0]
	var num_val = lc.get_node("num_val/property_editor").get_property_value()[0]
	var capability_lock = lc.get_node("capability_lock/property_editor").get_property_value()[0]
	var test_protocol = lc.get_node("test_protocol/property_editor").get_property_value()[0]
	var default = lc.get_node("default/property_editor").get_property_value()[0]
	var control = lc.get_node("control/property_editor").get_property_value()[0]
	var story_flag = lc.get_node("story_flag/property_editor").get_property_value()[0]
	var story_flag_min = lc.get_node("story_flag_min/property_editor").get_property_value()[0]
	var story_flag_max = lc.get_node("story_flag_max/property_editor").get_property_value()[0]
	var warn_if_thermal_below = lc.get_node("warn_if_thermal_below/property_editor").get_property_value()[0]
	var warn_if_electric_below = lc.get_node("warn_if_electric_below/property_editor").get_property_value()[0]
	var sticker_price_format = lc.get_node("sticker_price_format/property_editor").get_property_value()[0]
	var sticker_price_multi_format = lc.get_node("sticker_price_multi_format/property_editor").get_property_value()[0]
	var normal_color = lc.get_node("normal_color/property_editor").get_property_value()[0]
	var installed_color = lc.get_node("installed_color/property_editor").get_property_value()[0]
	var disabled_color = lc.get_node("disabled_color/property_editor").get_property_value()[0]
	var config_id = lc.get_node("config_id/property_editor").get_property_value()[0]
	var config_section = lc.get_node("config_section/property_editor").get_property_value()[0]
	var config_entry = lc.get_node("config_entry/property_editor").get_property_value()[0]
	var config_invert_config = lc.get_node("config_invert_config/property_editor").get_property_value()[0]
	var restriction = lc.get_node("restriction/property_editor").get_property_value()[0]
	var equipment_type = lc.get_node("equipment_type/dropdown/TagPopup").get_selected_string()
	var slot_type = lc.get_node("slot_type/dropdown/TagPopup").get_selected_string()
	var align = lc.get_node("alignment/dropdown/TagPopup").get_selected_string()
	if system:
		out["system"] = system
		if price > 0:
			out["price"] = price
		if name_override:
			out["name_override"] = name_override
		if description:
			out["description"] = description
		if manual:
			out["manual"] = manual
		if specs:
			out["specs"] = specs
		if num_val > -1:
			out["num_val"] = num_val
		if capability_lock:
			out["capability_lock"] = true
		if test_protocol != "fire":
			out["test_protocol"] = test_protocol
		if default:
			out["default"] = true
		if control:
			out["control"] = control
		if story_flag:
			out["story_flag"] = story_flag
			if story_flag_min > -1:
				out["story_flag_min"] = story_flag_min
			if story_flag_max > -1:
				out["story_flag_max"] = story_flag_max
		if warn_if_thermal_below > 0.0:
			out["warn_if_thermal_below"] = warn_if_thermal_below
		if warn_if_electric_below > 0.0:
			out["warn_if_electric_below"] = warn_if_electric_below
		if sticker_price_format and sticker_price_format != "%s E$":
			out["sticker_price_format"] = sticker_price_format
		if sticker_price_multi_format and sticker_price_multi_format != "%s E$ (x%d)":
			out["sticker_price_multi_format"] = sticker_price_multi_format
		if normal_color != Color(1,1,1,1):
			out["normal_color"] = normal_color
		if installed_color != Color(0,1,0,1):
			out["installed_color"] = installed_color
		if disabled_color != Color(0.2,0.2,0.2,1):
			out["disabled_color"] = disabled_color
		if config_id and config_section and config_entry:
			var cfg = {}
			cfg["id"] = config_id
			cfg["section"] = config_section
			cfg["entry"] = config_entry
			if config_invert_config:
				cfg["invert_config"] = true
			out["config"] = cfg
		if equipment_type:
			out["equipment_type"] = equipment_type
		if slot_type:
			out["slot_type"] = slot_type
			if slot_type == "HARDPOINT":
				if align:
					out["alignment"] = align
		if restriction:
			out["restriction"] = restriction
		
		# No subdriver support yet, just keeps any already in the file in the output
		match slot_type:
			"HARDPOINT":
				if "weapon_slot" in current_button.stored_state:
					out["weapon_slot"] = current_button.stored_state["weapon_slot"]
				if "WEAPONSLOT_ADD" in current_button.stored_state:
					out["WEAPONSLOT_ADD"] = current_button.stored_state["WEAPONSLOT_ADD"]
			"MASS_DRIVER_AMMUNITION":
				if "REGISTER_AMMO" in current_button.stored_state:
					out["REGISTER_AMMO"] = current_button.stored_state["REGISTER_AMMO"]
			"NANODRONE_STORAGE":
				if "REGISTER_NANO" in current_button.stored_state:
					out["REGISTER_NANO"] = current_button.stored_state["REGISTER_NANO"]
			"STANDARD_REACTION_CONTROL_THRUSTERS":
				if "AUX_POWER_SLOT" in current_button.stored_state:
					out["AUX_POWER_SLOT"] = current_button.stored_state["AUX_POWER_SLOT"]
				if "THRUSTERS" in current_button.stored_state:
					out["THRUSTERS"] = current_button.stored_state["THRUSTERS"]
				if "AUX_POWER_AND_THRUSTERS" in current_button.stored_state:
					out["AUX_POWER_AND_THRUSTERS"] = current_button.stored_state["AUX_POWER_AND_THRUSTERS"]
			"STANDARD_MAIN_ENGINE":
				if "AUX_POWER_SLOT" in current_button.stored_state:
					out["AUX_POWER_SLOT"] = current_button.stored_state["AUX_POWER_SLOT"]
				if "THRUSTERS" in current_button.stored_state:
					out["THRUSTERS"] = current_button.stored_state["THRUSTERS"]
				if "AUX_POWER_AND_THRUSTERS" in current_button.stored_state:
					out["AUX_POWER_AND_THRUSTERS"] = current_button.stored_state["AUX_POWER_AND_THRUSTERS"]
			"FISSION_RODS":
				if "REGISTER_REACTOR_RODS" in current_button.stored_state:
					out["REGISTER_REACTOR_RODS"] = current_button.stored_state["REGISTER_REACTOR_RODS"]
			"ULTRACAPACITOR":
				if "REGISTER_ULTRACAPACITORS" in current_button.stored_state:
					out["REGISTER_ULTRACAPACITORS"] = current_button.stored_state["REGISTER_ULTRACAPACITORS"]
			"FISSION_TURBINE":
				if "REGISTER_TURBINES" in current_button.stored_state:
					out["REGISTER_TURBINES"] = current_button.stored_state["REGISTER_TURBINES"]
			"AUX_POWER_SLOT":
				if "auxiliary_power_unit" in current_button.stored_state:
					out["auxiliary_power_unit"] = current_button.stored_state["auxiliary_power_unit"]
				if "AUX_POWER_SLOT" in current_button.stored_state:
					out["AUX_POWER_SLOT"] = current_button.stored_state["AUX_POWER_SLOT"]
				if "THRUSTERS" in current_button.stored_state:
					out["THRUSTERS"] = current_button.stored_state["THRUSTERS"]
				if "AUX_POWER_AND_THRUSTERS" in current_button.stored_state:
					out["AUX_POWER_AND_THRUSTERS"] = current_button.stored_state["AUX_POWER_AND_THRUSTERS"]
			"PROPELLANT_TANK":
				if "REGISTER_PROPELLANT" in current_button.stored_state:
					out["REGISTER_PROPELLANT"] = current_button.stored_state["REGISTER_PROPELLANT"]
	return out


