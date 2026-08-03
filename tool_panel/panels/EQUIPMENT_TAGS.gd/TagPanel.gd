tool
extends "res://addons/DVTools/tool_panel/panels/PanelBase.gd"

onready var lc = get_node("ScrollContainer/VBoxContainer")

var can_mark_unsaved = false
func _ready():
	if not this_script_path.begins_with("new://"):
		var data = __get_script_constant_map_without_load(this_script_path).get("EQUIPMENT_TAGS",{})
		set_properties_from_dict(data)
	yield(get_tree().create_timer(0.15),"timeout")
	can_mark_unsaved = true

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
					equipment_tag_files = panel_settings.get_value("use_specific_tags")
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
		if equipmentItems.size() > 0:
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
