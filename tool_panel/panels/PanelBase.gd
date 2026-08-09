tool
extends HBoxContainer

var container_panel

var this_script_path = ""

var needs_save = false

func SAVE():
	if this_script_path:
		if this_script_path.begins_with("new://"):
			container_panel.open_save_as()
		else:
			if self.has_method("save_driver_data"):
				container_panel.save_data(self.call("save_driver_data"),this_script_path)

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

