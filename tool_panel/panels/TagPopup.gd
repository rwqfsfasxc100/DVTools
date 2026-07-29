tool
extends OptionButton

export (String,"equipment_type","slot_type","alignment","hardpoint_type") var tag_type = "equipment_type"

export (NodePath) var slot_type_path = NodePath()
onready var slottype_node = get_node_or_null(slot_type_path)
export (NodePath) var equipment_type_path = NodePath()
onready var equipmenttype_node = get_node_or_null(equipment_type_path)
export (NodePath) var alignment_type_path = NodePath()
onready var alignmenttype_node = get_node_or_null(alignment_type_path)
export (NodePath) var hardpoint_type_path = NodePath()
onready var hardpointtype_node = get_node_or_null(hardpoint_type_path)
export (NodePath) var lineedit_path = NodePath("../LineEdit")
onready var line_edit = get_node_or_null(lineedit_path)

export (NodePath) var panel_path = NodePath("../../../../../../../../..")
onready var panel = get_node_or_null(panel_path)

var panel_settings

var slot_types:Array = []
var equipment_types:Array = []
var alignments:Array = []
var hardpoint_types:Array = []
var slot_defaults:Dictionary = {}

func _ready():
	connect("item_selected",self,"_do_refresh")
	match tag_type:
		"slot_type":
			if equipmenttype_node:
				connect("refresh",equipmenttype_node,"_on_refresh",[],CONNECT_DEFERRED)
			if alignmenttype_node:
				connect("refresh",alignmenttype_node,"_on_refresh")
			if hardpointtype_node:
				connect("refresh",hardpointtype_node,"_on_refresh",[],CONNECT_DEFERRED)
	clip_text = true

var available:Array = []
var slot_tooltips:Dictionary = {"":""}
var equipment_tooltips:Dictionary = {"":""}
var alignment_tooltips:Dictionary = {"":""}
var hardpoint_tooltips:Dictionary = {"":""}



func get_selected_string() -> String:
	if line_edit:
		return line_edit.text
	elif available:
		if selected < available.size() and selected > -1:
			return available[selected]
		return available[0]
	return ""

var last_used = ""

func initialize_current_tags(use_specific:String = last_used):
	if "container_panel" in panel and panel.container_panel:
		panel_settings = panel.container_panel.tool_panel.plugin_settings
		var vanilla_tags = __get_script_constant_map_without_load("res://HevLib/scenes/equipment/vanilla_defaults/slot_tagging.gd")
		var equipment_tag_files = []
		slot_types = vanilla_tags.get("slot_types",[])
		equipment_types = vanilla_tags.get("equipment_types",[])
		alignments = vanilla_tags.get("alignments",[])
		hardpoint_types = vanilla_tags.get("hardpoint_types",[])
		slot_defaults = vanilla_tags.get("slot_defaults",{})
		match tag_type:
			"slot_type":
				for i in slot_types:
					slot_tooltips[i] = "Vanilla/Built-in"
			"equipment_type":
				for i in equipment_types:
					equipment_tooltips[i] = "Vanilla/Built-in"
			"alignment":
				for i in alignments:
					alignment_tooltips[i] = "Vanilla/Built-in"
			"hardpoint_type":
				for i in hardpoint_types:
					hardpoint_tooltips[i] = "Vanilla/Built-in"
		
		if panel_settings:
			match panel_settings.get_value("driver_tag_discovery_preference"):
				0:
					equipment_tag_files = panel_settings.drivers_by_type.get("EQUIPMENT_TAGS.gd",[])
				1:
					equipment_tag_files = panel_settings.get_value("use_specific_tags")
		for tag in equipment_tag_files:
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
					if tag_type == "slot_type":
						slot_tooltips[st] = tag
			if equipmentItems.size() > 0:
				for st in equipmentItems:
					if not st in equipment_types:
						equipment_types.append(st)
					if tag_type == "equipment_type":
						equipment_tooltips[st] = tag
			if AL:
				for st in AL:
					if not st in alignments:
						alignments.append(st)
					if tag_type == "alignment":
						alignment_tooltips[st] = tag
			if hardpointTypes:
				for st in hardpointTypes:
					if not st in hardpoint_types:
						hardpoint_types.append(st)
					if tag_type == "hardpoint_type":
						hardpoint_tooltips[st] = tag
			if slotDefaults:
				for st in slotDefaults:
					if st in slot_defaults:
						for item in slotDefaults.get(st):
							if not item in slot_defaults.get(st):
								slot_defaults[st].append(item)
					else:
						slot_defaults.merge({st:slotDefaults.get(st)})
		clear()
		var source_tooltips:Dictionary = {"":""}
		match tag_type:
			"equipment_type":
				if slottype_node and slottype_node.has_method("get_selected_string"):
					var st = slottype_node.get_selected_string()
					if st == "HARDPOINT":
						var allHP = []
						for i in hardpoint_types:
							for r in slot_defaults.get(i,[]):
								if not r in allHP:
									allHP.append(r)
						available = allHP
						source_tooltips.merge(equipment_tooltips)
					else:
						available = slot_defaults.get(st,[""])
						source_tooltips.merge(equipment_tooltips)
				else:
					available = equipment_types
					source_tooltips.merge(equipment_tooltips)
			"slot_type":
				available = slot_types
				source_tooltips.merge(slot_tooltips)
			"hardpoint_type":
				if slottype_node and slottype_node.has_method("get_selected_string"):
					var st = slottype_node.get_selected_string()
					if st == "HARDPOINT":
						var allHP = []
						for i in hardpoint_types:
							allHP.append(i)
						available = allHP
						source_tooltips.merge(hardpoint_tooltips)
					else:
						available = [""]
				else:
					available = [""]
			"alignment":
				if slottype_node and slottype_node.has_method("get_selected_string"):
					var st = slottype_node.get_selected_string()
					if st == "HARDPOINT":
						available = [""]
						available.append_array(alignments)
						source_tooltips.merge(alignment_tooltips)
					else:
						available = [""]
				else:
					available = [""]
		
		for r in range(available.size()):
			var i = available[r]
			add_item(i)
			if i in source_tooltips:
				set_item_tooltip(r,source_tooltips[i])
		if available:
			if use_specific:
				var av = available.find(use_specific)
				if av > -1:
					select(av)
					hint_tooltip = use_specific
					if line_edit:
						line_edit.text = use_specific
						line_edit.hint_tooltip = use_specific
				else:
					select(0)
					hint_tooltip = available[0]
					if line_edit:
						line_edit.text = available[0]
						line_edit.hint_tooltip = available[0]
			else:
				select(0)
				hint_tooltip = available[0]
				if line_edit:
					line_edit.text = available[0]
					line_edit.hint_tooltip = available[0]
			last_used = available[selected]
		else:
			last_used = ""
			hint_tooltip = ""
			if line_edit:
				line_edit.text = ""
				line_edit.hint_tooltip = ""

signal refresh

func _do_refresh(how):
	emit_signal("refresh")
	if line_edit:
		if available:
			line_edit.text = available[how]
		else:
			line_edit.text = ""

func _on_refresh():
	if available:
		last_used = available[selected]
		if line_edit: line_edit.text = available[selected]
	else:
		last_used = ""
		if line_edit: line_edit.text = ""
	initialize_current_tags()

func __get_script_constant_map_without_load(script_path : String) -> Dictionary:
	var pathway : Array = __trim_scripts(script_path)
	if not pathway[2]: return {}
	var dict : Dictionary = {}
	var l : Dictionary = __compile_script(pathway[0]).get_script_constant_map()
	for i in pathway[2]:
		dict[i] = l[i]
	return dict

func __compile_script(source_code : String) -> Script:
	var out:GDScript = GDScript.new()
	out.set_source_code(source_code)
	out.reload()
	return out

func __trim_scripts(file_path : String, get_detailed_operands : bool = false, trim_unnecessary_newlines : bool = false, recurse_through_base_scripts : bool = true):
	if __load_if_can(file_path):
		var script_source = __get_load()
		if script_source:
			return __trim_script_object(script_source,get_detailed_operands,trim_unnecessary_newlines,recurse_through_base_scripts)
	return ["extends Node",[],[],[],[],[],[],[]]

func __load_if_can(filepath : String, override_cache : bool = false, type_hint : String = ""):
	if not filepath:
		return false
	if __file_exists(filepath):
		var obj = ResourceLoader.load(filepath,type_hint,override_cache)
		if obj:
			last_successful_object = obj
			return true
	last_successful_object = null
	return false

var file:File = File.new()
func __file_exists(file_path:String) -> bool:
	file_path = ProjectSettings.localize_path(file_path)
	if ResourceLoader.exists(file_path) or file.file_exists(file_path):
		return true
	return false
var last_successful_object = null
func __get_load(get_last_successful : bool = false):
	return last_successful_object

const function_prefixes = ["func ","static func ","remote func ","master func ","puppet func ","remotesync func ","mastersync func ","puppetsync func ","sync func "]
const all_prefixes = ["func ","static func ","remote func ","master func ","puppet func ","remotesync func ","mastersync func ","puppetsync func ","sync func ","onready ","var ","signal ","const ","export ","extends "]

func __trim_script_object(script_source : Script, get_detailed_operands : bool = false, trim_unnecessary_newlines : bool = false, recurse_through_base_scripts : bool = true):
	var concat : String = ""
	var var_names : Array = []
	var const_names : Array = []
	var method_names : Array = []
	var signal_names : Array = []
	var method_values : Array = []
	var method_output_type : Array = []
	var signal_values : Array = []
	if script_source:
		var extend_this:bool = true
		if recurse_through_base_scripts:
			var base_script:Script = script_source.get_base_script()
			if base_script:
				var base_data : Array = __trim_script_object(base_script,get_detailed_operands,trim_unnecessary_newlines,recurse_through_base_scripts)
				concat += base_data[0]
				if concat.find("extends ") > -1:
					extend_this = false
				if not concat.ends_with("\n"):
					concat += "\n"
				for i in base_data[1]:
					if not i in var_names:
						var_names.append(i)
				for i in base_data[2]:
					if not i in const_names:
						const_names.append(i)
				for f in range(base_data[3].size()):
					var i = base_data[3][f]
					if not i in signal_names:
						signal_names.append(i)
						signal_values.append(base_data[5][f])
				for f in range(base_data[4].size()):
					var i = base_data[4][f]
					if not i in method_names:
						method_names.append(i)
						method_values.append(base_data[6][f])
						method_output_type.append(base_data[7][f])
		var data : String  = script_source.get_source_code()
		var streaming:bool = false
		var this_stream : String = ""
		var lines:PoolStringArray = data.split("\n")
		for line in lines:
			var result : String = ""
			var is_part_of_string:bool = false
			var prev_char_escape:bool = false
			while line != "":
				var part:String = line.substr(0,1)
				if part == "\\":
					prev_char_escape = !prev_char_escape
				else:
					prev_char_escape = false
				if part == "\"" and not prev_char_escape:
					is_part_of_string = !is_part_of_string
				if part == "#" and (not is_part_of_string and not prev_char_escape):
					break
				line.erase(0,1)
				result += part
			line = result
			var has_prefix:bool = false
			var has_sig:bool = false
			for prefix in function_prefixes:
				if line.begins_with(prefix):
					has_prefix = true
			if line.begins_with("signal "):
				has_sig = true
			if has_prefix:
				if streaming:
					concat += this_stream.strip_edges() + "\n"
					this_stream = ""
					streaming = false
				var av:PoolStringArray = line.split("func ")[1].split("(")
				var mname : String  = av[0]
				if get_detailed_operands:
					var operands : String = line.split(mname)[1].strip_edges()
					var os:PoolStringArray = operands.split("->")
					var outputType : String = ""
					if os.size() > 1:
						outputType = os[1].rstrip(":")
						operands = os[0].strip_edges()
					if operands.begins_with("("):
						operands = operands.substr(1, operands.length())
					if operands.ends_with(":"):
						operands = operands.substr(0, operands.length() - 1)
					if operands.ends_with(")"):
						operands = operands.substr(0,operands.length() - 1)
					var opvalues : Array = []
					var thisOpValue : String  = ""
					var colonDelim:bool = false
					var bracketDelim:bool = false
					for i in operands:
						if not colonDelim and i == ":":
							colonDelim = true
						if colonDelim and i == ",":
							colonDelim = false
						if not bracketDelim and i == "(":
							bracketDelim = true
						if bracketDelim and i == ")":
							bracketDelim = false
						if not bracketDelim and i == ",":
							opvalues.append(thisOpValue.strip_edges())
							thisOpValue = ""
						else:
							thisOpValue += i
					if thisOpValue:
						opvalues.append(thisOpValue.strip_edges())
						thisOpValue = ""
					method_values.append(opvalues)
					method_output_type.append(outputType.strip_edges())
				method_names.append(mname)
			elif has_sig:
				if streaming:
					concat += this_stream.strip_edges() + "\n"
					this_stream = ""
					streaming = false
				var av:PoolStringArray = line.split("signal ")[1].split("(")
				var sname : String  = av[0]
				if get_detailed_operands:
					var op = []
					if av.size() > 1:
						var operands : String  = av[1].rstrip(")")
						if operands:
							for o in operands.split(","):
								op.append(o.strip_edges())
					signal_values.append(op)
				signal_names.append(sname)
			elif line.begins_with("const "):
				if streaming:
					concat += this_stream.strip_edges() + "\n"
					this_stream = ""
					streaming = false
				var cname : String  = line.split("=",false)[0].strip_edges().split("const ",true)[1].strip_edges().split(":",false)[0].strip_edges()
				const_names.append(cname)
				streaming = true
			elif line.begins_with("var "):
				if streaming:
					concat += this_stream.strip_edges() + "\n"
					this_stream = ""
					streaming = false
				var vname : String  = line.split("=",false)[0].strip_edges().split("var ",true)[1].strip_edges().split(":",false)[0].strip_edges()
				var_names.append(vname)
				streaming = true
			elif line.begins_with("export ") and " var " in line:
				if streaming:
					concat += this_stream.strip_edges() + "\n"
					this_stream = ""
					streaming = false
				var vname : String  = line.split("=",false)[0].strip_edges().split("var ",true)[1].strip_edges().split(":",false)[0].strip_edges()
				var_names.append(vname)
				streaming = true
			elif line.begins_with("onready ") and " var " in line:
				if streaming:
					concat += this_stream.strip_edges() + "\n"
					this_stream = ""
					streaming = false
				var vname : String  = line.split("=",false)[0].strip_edges().split("var ",true)[1].strip_edges().split(":",false)[0].strip_edges()
				var_names.append(vname)
				streaming = true
			elif line.begins_with("extends "):
				if streaming:
					concat += this_stream.strip_edges() + "\n"
					this_stream = ""
					streaming = false
				if extend_this:
					streaming = true
			if streaming:
				this_stream = this_stream + "\n" + line
		if streaming:
			concat += this_stream.strip_edges() + "\n"
			this_stream = ""
			streaming = false
	if trim_unnecessary_newlines:
		var reconcat : String  = ""
		for line in concat.split("\n"):
			var newline:bool = false
			var ls : String  = line.strip_edges()
			for a in all_prefixes:
				if ls.begins_with(a):
					newline = true
			if newline and reconcat:
				ls = "\n" + ls
			reconcat += ls
		concat = reconcat
	return [concat if concat !="" else "extends Node",var_names,const_names,signal_names,method_names,signal_values,method_values,method_output_type]

