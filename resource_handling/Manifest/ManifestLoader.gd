tool
class_name ModManifestLoader
extends ResourceFormatLoader

const ManifestClass = preload("res://addons/DVTools/resource_handling/Manifest/ModManifestClass.gd")

func get_recognized_extensions() -> PoolStringArray:
	return PoolStringArray(["manifest"])

func get_resource_type(path: String) -> String:
	var ext = path.get_extension().to_lower()
	if ext == "manifest":
		return "Resource"
	return ""

func handles_type(typename: String) -> bool:
	return ClassDB.is_parent_class(typename, "Resource")

func load(path: String, original_path: String,no_subresource_cache:bool):
	var file:File = File.new()
	if not file.file_exists(path) and not ResourceLoader.exists(path):
		return ERR_CANT_OPEN
	var dt:Dictionary = __config_parse(path)
	var res := ManifestClass.new()
	res.set_manifest(dt)
	return res

func __config_parse(file_path: String) -> Dictionary:
	var file:File = File.new()
	var cfg:ConfigFile = ConfigFile.new()
	file.open(file_path,File.READ)
	var txt : String  = file.get_as_text()
	file.close()
	cfg.parse(txt)
	var cfg_sections : Array = cfg.get_sections()
	var cfg_dictionary : Dictionary = {}
	for section in cfg_sections:
		var data : Dictionary = {}
		var keys : Array = cfg.get_section_keys(section)
		for key in keys:
			var item = cfg.get_value(section,key)
			data.merge({key:item})
		cfg_dictionary.merge({section:data})
	return cfg_dictionary
