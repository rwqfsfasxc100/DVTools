tool
extends ConfirmationDialog

export (NodePath) var settings_button_path = NodePath("../VBoxContainer/Menu/Settings")
onready var settings_button = get_node_or_null(settings_button_path)
export (NodePath) var tool_panel_path = NodePath("..")
onready var tool_panel = get_node_or_null(tool_panel_path)

var plugin_settings

var file_dialog:EditorFileDialog = EditorFileDialog.new()

onready var pck_line_edit:LineEdit = get_node_or_null(NodePath("PanelContainer/ScrollContainer/VBoxContainer/HevLibSettings/PCKPath/LineEdit"))
onready var pck_file_button:Button = get_node_or_null(NodePath("PanelContainer/ScrollContainer/VBoxContainer/HevLibSettings/PCKPath/Button2"))
var file:File = File.new()
var cfg:ConfigFile = ConfigFile.new()

var config_path:String = "user://cfg/Mod_Configurations.cfg"

func _ready():
	file_dialog.rect_min_size = get_viewport().size - Vector2(200,200)
	file_dialog.show_hidden_files = true
	file_dialog.mode = EditorFileDialog.MODE_OPEN_FILE
	file_dialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	file_dialog.add_filter("Delta-V.pck ; PCK Files")
	file_dialog.connect("file_selected",self,"_open_this_file")
	call_deferred("add_child",file_dialog)
	pck_file_button.connect("pressed",file_dialog,"popup_centered")
	cfg.load(config_path)
	var value:String = cfg.get_value("HevLib/HEVLIB_CONFIG_SECTION_DEBUG","pck_path_for_editor_testing","")
	cfg.clear()
	if file.file_exists(value):
		pck_line_edit.text = value
	else:
		value = ""
	saveModSettings(value)
	if tool_panel and settings_button:
		settings_button.connect("pressed",self,"show")
		connect("confirmed",self,"saveSettings")
		plugin_settings = tool_panel.plugin_settings
		initializeDisplays()

func _open_this_file(f:String):
	if file.file_exists(f):
		pck_line_edit.text = f
		_on_LineEdit_text_changed(f)

func _on_LineEdit_text_changed(f:String):
	if file.file_exists(f):
		saveModSettings(f)

func saveModSettings(how:String):
	cfg.load(config_path)
	cfg.set_value("HevLib/HEVLIB_CONFIG_SECTION_DEBUG","pck_path_for_editor_testing",how)
	cfg.save(config_path)
	cfg.clear()

func show():
	rect_min_size = Vector2(200,get_viewport().size.y - 200)
	
	loadCurrentConfigs()
	popup_centered()

onready var discovery_pref = get_node_or_null("PanelContainer/ScrollContainer/VBoxContainer/DiscoveryPreference/OptionButton")
onready var specific_tag_filepaths = get_node_or_null("PanelContainer/ScrollContainer/VBoxContainer/SpecificTagFilepaths/TextEdit")
onready var driver_filepaths = get_node_or_null("PanelContainer/ScrollContainer/VBoxContainer/DiscoveredDriversByMod/TextEdit")
onready var driver_filepaths_by_driver = get_node_or_null("PanelContainer/ScrollContainer/VBoxContainer/DiscoveredDriversByDriver/TextEdit")



var tag_preferences = PoolStringArray([
	"Use tags from all drivers available to the file system",
	"Use built-in/Vanilla tags & tags from specific drivers",
	"Use built-in/Vanilla tags & tags from only drivers in the same mod folder",
	"Use only built-in/Vanilla tags",
])

func initializeDisplays():
	if discovery_pref:
		discovery_pref.connect("item_selected",self,"dpref_selected")
		for i in tag_preferences:
			discovery_pref.add_item(i)

func loadCurrentConfigs():
	if plugin_settings:
		if discovery_pref:
			var how = plugin_settings.get_value("driver_tag_discovery_preference")
			discovery_pref.select(how)
			dpref_selected(how)
		if specific_tag_filepaths:
			var tags = plugin_settings.get_value("use_specific_tags")
			var ov = ""
			for tag in tags:
				if ov:
					ov += "\n" + tag
				else:
					ov = tag
			specific_tag_filepaths.text = ov
		if driver_filepaths:
			var how = plugin_settings.discovered_drivers
			var txt = ""
			var lastDir = ""
			for i in how:
				var thisDir = i.split("/",false)[1]
				if lastDir != thisDir:
					if txt:
						txt += "\n\n\t=== %s ===\t" % thisDir
					else:
						txt = "\t=== %s ===\t" % thisDir
				if txt:
					txt += "\n" + i
				else:
					txt = i
				lastDir = thisDir
			driver_filepaths.text = txt
		if driver_filepaths_by_driver:
			var how = plugin_settings.discovered_drivers
			var txt = ""
			var dict = {}
			for i in how:
				var thisDriver = i.get_file()
				if not thisDriver in dict:
					dict[thisDriver] = []
				if not i in dict[thisDriver]:
					dict[thisDriver].append(i)
			for driver in dict:
				var driverData = dict[driver]
				if txt:
					txt += "\n\n\t=== %s ===\t" % driver
				else:
					txt = "\t=== %s ===\t" % driver
				for i in driverData:
					if txt:
						txt += "\n" + i
					else:
						txt = i
			driver_filepaths_by_driver.text = txt
		

func saveSettings():
	if plugin_settings:
		if discovery_pref:
			plugin_settings.set_value("driver_tag_discovery_preference",discovery_pref.selected)
		if specific_tag_filepaths:
			var txt = specific_tag_filepaths.text
			var out = PoolStringArray()
			for i in txt.split("\n"):
				i = i.strip_edges()
				out.append(i)
			plugin_settings.set_value("use_specific_tags",out)
		
		
		plugin_settings.saveConfig()

func dpref_selected(how):
	if plugin_settings and specific_tag_filepaths:
		specific_tag_filepaths.readonly = how != 1


func _on_RefreshTooltips_pressed():
	plugin_settings.fetch_tooltips_file()
