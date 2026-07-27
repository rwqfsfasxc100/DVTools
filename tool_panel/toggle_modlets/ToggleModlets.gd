tool
extends ConfirmationDialog

export (NodePath) var settings_button_path = NodePath("../VBoxContainer/Menu/ToggleModlets")
onready var settings_button = get_node_or_null(settings_button_path)
export (NodePath) var tool_panel_path = NodePath("..")
onready var tool_panel = get_node_or_null(tool_panel_path)

onready var list = $PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer

func _ready():
	if tool_panel and settings_button:
		settings_button.connect("pressed",self,"show")
		connect("confirmed",self,"saveSettings")

func show():
	loadCurrentConfigs()
	popup_centered()

var file:File = File.new()
var config_path:String = "user://cfg/Mod_Configurations.cfg"
var modlets_in_fs:Dictionary = {}

func loadCurrentConfigs():
	for i in list.get_children():
		list.remove_child(i)
		i.queue_free()
	modlets_in_fs.clear()
	if file.file_exists(config_path):
		var cfg = ConfigFile.new()
		cfg.load(config_path)
		if cfg.has_section("HevLib/modlets") and cfg.has_section_key("HevLib/modlets","seen_modlets"):
			var all_modlets = cfg.get_value("HevLib/modlets","seen_modlets")
			for modlet in all_modlets:
				if file.file_exists(modlet):
					modlets_in_fs[modlet] = all_modlets[modlet]
	for modlet in modlets_in_fs:
		var button = load("res://addons/DVTools/tool_panel/toggle_modlets/ModletToggle.tscn").instance()
		button.modlet_path = modlet
		button.pressed = modlets_in_fs[modlet]
		list.add_child(button)

func saveSettings():
	for button in list.get_children():
		var path = button.modlet_path
		if path:
			modlets_in_fs[path] = button.pressed
	var cfg = ConfigFile.new()
	cfg.load(config_path)
	cfg.set_value("HevLib/modlets","seen_modlets",modlets_in_fs)
	cfg.save(config_path)
