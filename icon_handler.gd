extends Node



const iconcat = []
const cache_meta = {"last_mtime": 0}

static func change_tree_appearance(tree: Tree) -> void:
	var path = "res://ModLoader.gd"
	var current_mtime = 0
	var file = File.new()
	if file.file_exists(path):
		current_mtime = file.get_modified_time(path)
	
	if current_mtime != cache_meta.last_mtime or iconcat.empty():
		cache_meta.last_mtime = current_mtime
		iconcat.clear()
		var items = __get_script_variables_without_load(path).get("addedMods",[])
		for i in items:
			iconcat.append("res://" + i.split("/")[2] + "/")
	
	change_item_appearance(tree.get_root())

static func change_item_appearance(tree_item: TreeItem) -> void:
	while tree_item:
		var metadata = tree_item.get_metadata(0)
		var file_path: String
		if metadata is String:
			file_path = metadata

		# A few examples for what to change and how. Not a style guide, make yours prettier
		if file_path:
#			if file_path.ends_with("res://"):
#				tree_item.set_icon(0, preload("res://icon.png"))
#				# Make sure the icon doesn't become oversized
#				tree_item.set_icon_max_width(0, 24)
#				# Folder icons have a blue tint, reset that
#				tree_item.set_icon_modulate(0, Color.white)
			var fn = file_path.get_file().to_lower()
			if fn.begins_with("modmain") and fn.ends_with(".gd"):
				tree_item.set_custom_color(0,Color.lightgreen)
			elif fn.begins_with("mod") and fn.ends_with(".manifest"):
				tree_item.set_custom_color(0,Color.lightgreen)
				tree_item.set_icon(0, preload("res://addons/DVTools/resource_handling/Manifest/ManifestIcon.tres"))
			
			if file_path in iconcat:
				tree_item.set_custom_color(0,Color.green)
			
			
		change_item_appearance(tree_item.get_children())
		tree_item = tree_item.get_next()




static func __get_script_variables_without_load(script_path : String) -> Dictionary:
		var filepath : String  = "user://cache/.HevLib_Cache/Variable_Fetch/"
		var pathway : Array = __trim_scripts(script_path)
		if pathway[1].size() == 0:
			return {}
		var dict : Dictionary = {}
		var l = __compile_script_object(pathway[0])
		for i in pathway[1]:
			dict[i] = l.get(i)
		return dict
		
const function_prefixes = ["func ","static func ","remote func ","master func ","puppet func ","remotesync func ","mastersync func ","puppetsync func ","sync func "]
const all_prefixes = ["func ","static func ","remote func ","master func ","puppet func ","remotesync func ","mastersync func ","puppetsync func ","sync func ","onready ","var ","signal ","const ","export ","extends "]
static func __trim_scripts(file_path : String, get_detailed_operands : bool = false, trim_unnecessary_newlines : bool = false, recurse_through_base_scripts : bool = true):
		if ResourceLoader.exists(file_path):
			var script_source = load(file_path)
			if script_source:
				return __trim_script_object(script_source,get_detailed_operands,trim_unnecessary_newlines,recurse_through_base_scripts)
		return ["extends Node",[],[],[],[],[],[],[]]
	
static func __trim_script_object(script_source : Script, get_detailed_operands : bool = false, trim_unnecessary_newlines : bool = false, recurse_through_base_scripts : bool = true):
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
				var base_script = script_source.get_base_script()
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
#					breakpoint
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
						concat = concat + this_stream.strip_edges() + "\n"
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
						var opnames : String  = ""
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
							if not colonDelim and not bracketDelim:
								opnames += i
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
						concat = concat + this_stream.strip_edges() + "\n"
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
						concat = concat + this_stream.strip_edges() + "\n"
						this_stream = ""
						streaming = false
					var cname : String  = line.split("=",false)[0].strip_edges().split("const ",true)[1].strip_edges().split(":",false)[0].strip_edges()
					const_names.append(cname)
					streaming = true
				elif line.begins_with("var "):
					if streaming:
						concat = concat + this_stream.strip_edges() + "\n"
						this_stream = ""
						streaming = false
					var vname : String  = line.split("=",false)[0].strip_edges().split("var ",true)[1].strip_edges().split(":",false)[0].strip_edges()
					var_names.append(vname)
					streaming = true
				elif line.begins_with("export ") and " var " in line:
					if streaming:
						concat = concat + this_stream.strip_edges() + "\n"
						this_stream = ""
						streaming = false
					var vname : String  = line.split("=",false)[0].strip_edges().split("var ",true)[1].strip_edges().split(":",false)[0].strip_edges()
					var_names.append(vname)
					streaming = true
				elif line.begins_with("onready ") and " var " in line:
					if streaming:
						concat = concat + this_stream.strip_edges() + "\n"
						this_stream = ""
						streaming = false
					var vname : String  = line.split("=",false)[0].strip_edges().split("var ",true)[1].strip_edges().split(":",false)[0].strip_edges()
					var_names.append(vname)
					streaming = true
				elif line.begins_with("extends "):
					if streaming:
						concat = concat + this_stream.strip_edges() + "\n"
						this_stream = ""
						streaming = false
					if extend_this:
						streaming = true
				if streaming:
					this_stream = this_stream + "\n" + line
			if streaming:
				concat = concat + this_stream.strip_edges() + "\n"
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

static func __compile_script_object(source_code : String, params = []) -> Script:
		if not params is Array:
			params = [params]
		var shash : String  = ""
		if params:
			var parStr : String  = str(params)
			shash = str(hash(source_code)) + "_" + str(hash(parStr))
		else:
			shash = str(hash(source_code))
		
		
		var gd:GDScript = GDScript.new()
		gd.set_source_code(source_code)
		gd.reload()
		var out
		if params:
			var f = funcref(gd,"new")
			var param_part = "_%d"
			var pb = ""
			var pd = ""
			for i in range(params.size()):
				var p = params[i]
				var pv = param_part % i
				if pb:
					pb += "," + pv
				else:
					pb = pv
				if pd:
					pd += "\n\tvar %s = arr[%d]" % [pv,i]
				else:
					pd = "\n\tvar %s = arr[%d]" % [pv,i]
			var sv = "static func parse(ref,arr):%s\n\treturn ref.call_func(%s)" % [pd,pb]
			
			var g:GDScript = GDScript.new()
			g.set_source_code(sv)
			g.reload()
			g.new()
			out = g.parse(f,params)
		else:
			out = gd.new()
		
		return out
