tool
extends ResourceFormatSaver
class_name ModManifestSaver

const ManifestClass = preload("res://addons/DVTools/resource_handling/Manifest/ModManifestClass.gd")

func get_recognized_extensions(resource) -> PoolStringArray:
	return PoolStringArray(["manifest"])

func recognize(resource: Resource) -> bool:
	resource = resource as ManifestClass
	if resource:
		return true
	return false

func save(path:String,resource:Resource,flags:int) -> int:
	var file:File = File.new()
	var err:int = file.open(path,File.WRITE)
	if err != OK:
		printerr("Can't write file: \"%s\"! code: %d." % [path,err])
		return err
	file.close()
#	if file.file_exists(path):
#		var dir = Directory.new()
#		dir.remove(path)
	__config_store(resource.manifest,path)
	return OK

func __config_store(dict : Dictionary,filepath:String):
		var cfg:ConfigFile = ConfigFile.new()
		for section in dict:
			var keys = dict[section]
			for key in keys:
				cfg.set_value(section,key,keys[key])
		cfg.save(filepath)


