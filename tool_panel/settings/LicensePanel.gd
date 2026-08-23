tool
extends ConfirmationDialog

export (NodePath) var settings_button_path = NodePath("../VBoxContainer/Menu/License")
onready var settings_button = get_node_or_null(settings_button_path)
export (NodePath) var tool_panel_path = NodePath("..")
onready var tool_panel = get_node_or_null(tool_panel_path)

var tab_container

func _ready():
	if tool_panel and settings_button:
		yield(get_tree(),"idle_frame")
		settings_button.connect("pressed",self,"show")
		connect("confirmed",self,"saveSettings")
		tab_container = tool_panel.tab_container

func show():
	rect_min_size = Vector2(200,get_viewport().size.y - 200)
#	yield(get_tree().create_timer(0.2),"timeout")
	if is_tab_valid():
		var panel = tab_container.tabs[tab_container.active_tab.script_path]
		if panel != null and is_instance_valid(panel):
			var license = panel.fetch_license_from_other_drivers()
			$PanelContainer/TextEdit.text = license
			popup_centered()

func is_tab_valid():
	return tab_container.active_tab != null and is_instance_valid(tab_container.active_tab)

func saveSettings():
	if is_tab_valid():
		var panel = tab_container.tabs[tab_container.active_tab.script_path]
		if panel != null and is_instance_valid(panel):
			panel.current_license = $PanelContainer/TextEdit.text
