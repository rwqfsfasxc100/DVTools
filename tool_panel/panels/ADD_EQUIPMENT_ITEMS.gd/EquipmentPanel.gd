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


func convert_to_constant(data:Dictionary, constant_name:String) -> String:
	var out = ""
	if data:
		var x = "{"
		for property in data:
			var st = stringify_property(data[property],1,false)
			var p = "\"%s\":%s," % [property,st]
			x += "\n\t" + p
		x += "\n}"
		out = "const %s = %s" % [constant_name, x]
	return out

func stringify_property(property,depth:int = 0,stringify:bool = true):
	var out = ""
	var type = typeof(property)
	match type:
		TYPE_NIL:
			out = "null"
		TYPE_ARRAY,TYPE_COLOR_ARRAY,TYPE_INT_ARRAY,TYPE_RAW_ARRAY,TYPE_REAL_ARRAY,TYPE_STRING_ARRAY,TYPE_VECTOR2_ARRAY,TYPE_VECTOR3_ARRAY:
			var l = ""
			match type:
				TYPE_ARRAY:
					l = "%s"
				TYPE_COLOR_ARRAY:
					l = "PoolColorArray(%s)"
				TYPE_INT_ARRAY:
					l = "PoolIntArray(%s)"
				TYPE_RAW_ARRAY:
					l = "PoolByteArray(%s)"
				TYPE_REAL_ARRAY:
					l = "PoolRealArray(%s)"
				TYPE_STRING_ARRAY:
					l = "PoolStringArray(%s)"
				TYPE_VECTOR2_ARRAY:
					l = "PoolVector2Array(%s)"
				TYPE_VECTOR3_ARRAY:
					l = "PoolVector3Array(%s)"
				
			if property.empty():
				if type == TYPE_ARRAY:
					out = "[]"
				else:
					out = l % ""
			else:
				l = l % "[%s\n%s]"
				var combine = ""
				var nd = depth + 1
				var tabs = ""
				var etabs = ""
				for i in range(depth):
					etabs += "\t"
				for i in range(nd):
					tabs += "\t"
				for i in property:
					var r = stringify_property(i,nd,false)
					var p = tabs + r
					if combine:
						combine += ","
					combine += "\n%s" % p
				out = l % [combine,etabs]
		TYPE_BOOL:
			out = ("true") if property else ("false")
		TYPE_COLOR:
			out = "Color( %s, %s, %s, %s )" % [property.r,property.g,property.b,property.a]
		TYPE_DICTIONARY:
			if property.empty():
				out = "{}"
			else:
				var l = "{%s\n%s}"
				var st = ""
				var nd = depth + 1
				var tabs = ""
				var etabs = ""
				for i in range(depth):
					etabs += "\t"
				for i in range(nd):
					tabs += "\t"
				for key in property:
					var item = "%s:%s" % [stringify_property(key,depth,false),stringify_property(property[key],nd,false)]
					var p = tabs + item
					if st:
						st += ","
					st += "\n%s" % p
				out = l % [st,etabs]
		TYPE_INT,TYPE_REAL:
			out = str(property)
		TYPE_NODE_PATH:
			out = "NodePath( %s )" % str(property)
		TYPE_RECT2:
			out = "Rect2( %s, %s, %s, %s )" % [property.position.x,property.position.y,property.size.x,property.size.y]
		TYPE_STRING:
			out = "\"%s\"" % property
		TYPE_TRANSFORM2D:
			out = "Transform2D( %s, %s, %s )" % [stringify_property(property.x,depth,false),stringify_property(property.y,depth,false),stringify_property(property.origin,depth,false)]
		TYPE_VECTOR2:
			out = "Vector2( %s, %s )" % [property.x,property.y]
		TYPE_VECTOR3:
			out = "Vector3( %s, %s, %s )" % [property.x,property.y,property.z]
		TYPE_AABB:
			out = "AABB( %s, %s )" % [stringify_property(property.position,depth,false),stringify_property(property.size,depth,false)]
		TYPE_BASIS:
			out = "Basis( %s, %s, %s )" % [stringify_property(property.x,depth,false),stringify_property(property.y,depth,false),stringify_property(property.z,depth,false)]
		TYPE_PLANE:
			out = "Plane( %s, %s )" % [stringify_property(property.normal,depth,false),property.d]
		TYPE_QUAT:
			out = "Quat( %s, %s, %s, %s )" % [property.x,property.y,property.z,property.w]
		TYPE_TRANSFORM:
			out = "Transform( %s, %s )" % [stringify_property(property.basis,depth,false),stringify_property(property.origin,depth,false)]
		_:
			printerr("Property ",property," uses type not currently supported")
	if stringify:
		out = "\"%s\"" % out
	return out

