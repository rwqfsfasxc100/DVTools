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
