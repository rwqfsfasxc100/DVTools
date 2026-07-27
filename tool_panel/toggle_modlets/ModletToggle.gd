tool
extends CheckButton

var modlet_path:String = ""

func _ready():
	connect("visibility_changed",self,"change_name")

func change_name():
	var mname = parse_file_as_manifest()
	var nameConcat = modlet_path
	if mname:
		nameConcat = "%s (%s)" % [mname,modlet_path]
	text = nameConcat

var file:File = File.new()
func parse_file_as_manifest() -> String:
	var mname:String = ""
	if modlet_path and file.file_exists(modlet_path):
		var cfg = ConfigFile.new()
		cfg.load(modlet_path)
		var mv = 1.0
		if cfg.has_section("manifest_definitions") and cfg.has_section_key("manifest_definitions","manifest_version"):
			mv = cfg.get_value("manifest_definitions","manifest_version",mv)
		match mv:
			1,1.0,2,2.0:
				mname = cfg.get_value("package","name","")
			2.1,2.2:
				mname = cfg.get_value("mod_information","name","")
	return mname
