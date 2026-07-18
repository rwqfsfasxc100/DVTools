tool
extends HBoxContainer

export (Dictionary) var supported_driver_files = {
	"ADD_EQUIPMENT_ITEMS.gd":"res://addons/DVTools/tool_panel/panels/ADD_EQUIPMENT_ITEMS.gd/EquipmentPanel.tscn",
	
}

export (NodePath) var tab_container_path = NodePath("../../TabContainer")
onready var tab_container:TabContainer = get_node_or_null(tab_container_path)

export (NodePath) var tool_panel_path = NodePath("../../..")
onready var tool_panel:MarginContainer = get_node_or_null(tool_panel_path)

var current_tab:int = 0 setget set_current_tab

var tabs:Dictionary = {}
var tab_buttons:Dictionary = {}

var active_tab = null

var open_file_diag = EditorFileDialog.new()
var save_as_file_diag = EditorFileDialog.new()

# Setter method for the current_tab value
func set_current_tab(val:int):
	if tab_container.get_child_count():
		current_tab = val
		tab_container.current_tab = val
		tab_container.get_child(val)._on_selected()
	else:
		active_tab = null

func _ready():
	tool_panel.connect("operation",self,"_on_menu_operation")
	setup_file_dialog(open_file_diag,0)
	setup_file_dialog(save_as_file_diag,1)

func setup_file_dialog(diag:EditorFileDialog,mode:int):
	diag.rect_min_size = get_viewport().size - Vector2(200,200)
	diag.show_hidden_files = true
	match mode:
		0:
			var supported_drivers = ""
			for i in supported_driver_files:
				if supported_drivers:
					supported_drivers += ", %s" % i
				else:
					supported_drivers = i
			diag.mode = EditorFileDialog.MODE_OPEN_FILE
			diag.add_filter("%s ; Supported Driver files" % supported_drivers)
			diag.connect("file_selected",self,"_open_this_file")
		1:
			diag.mode = EditorFileDialog.MODE_SAVE_FILE
			diag.add_filter("*.gd ; Driver files")
			diag.connect("file_selected",self,"_save_this_as_file")
	add_child(diag)

func _open_this_file(file_path:String):
	load_this_script(file_path)

var file = File.new()

func _save_this_as_file(file_path:String):
	if active_tab_valid() and active_tab.has_method("save_driver_data"):
		var data:String = active_tab.save_driver_data()
		

func save_data(data:String,file_path:String):
	if data:
		file.open(file_path,File.WRITE)
		file.store_string(data)
		file.close()
		tool_panel.reload_all_scripts()








func _on_menu_operation(operation:String):
	var split:PoolStringArray = operation.split("/")
	var depth:int = split.size()
	
	if depth == 2:
		if operation.begins_with("File/"):
			match split[1]:
				"Save":
					if active_tab_valid() and tabs[active_tab.script_path].needs_save:
						active_tab.SAVE()
				"Save As":
					if active_tab_valid():
						open_save_as()
				"Open":
					open_file_diag.popup_centered()
	
	if depth == 3:
		if operation.begins_with("File/New/"):
			make_empty_script_of_type(split[2])

func active_tab_valid():
	if active_tab and is_instance_valid(active_tab) and not active_tab.is_queued_for_deletion():
		return true
	return false

func open_save_as():
	if active_tab_valid():
		var path:String = active_tab.script_path
		save_as_file_diag.set_current_file(path.get_file())
		save_as_file_diag.popup_centered()



# Method used for loading panels when requested by the menu panel
func load_this_script(file_to_load:String):
	var add_new = true
	if file_to_load in tabs:
		tab_container.current_tab = tabs[file_to_load].get_position_in_parent()
		add_new = false
	if add_new:
		var panel = get_panel_for_driver(file_to_load.get_file(),file_to_load)
		if panel:
			add_item(panel,file_to_load)

func make_empty_script_of_type(type:String):
	var panel = get_panel_for_driver(type)
	if panel:
		var tempname = "new://%03d/temp_%s" % [randi() % 999,type]
		panel.this_script_path = tempname
		add_item(panel,tempname)

# Fetches and loads the requested panel
func get_panel_for_driver(panel_type:String,driver_script_path:String = ""):
	if panel_type in supported_driver_files:
		var panel:Node = load(supported_driver_files[panel_type]).instance()
		if panel:
			panel.this_script_path = driver_script_path
			panel.container_panel = self
			return panel
	return null


func _input(event):
	if event is InputEventKey and event.pressed and active_tab_valid() and tabs[active_tab.script_path].needs_save:
		if event.scancode == KEY_S and event.control:
			active_tab.SAVE()

func add_item(item:Node,script_path:String):
	tabs[script_path] = item
	tab_container.add_child(item)
	var button = load("res://addons/DVTools/tool_panel/tab_list/TabListButton.tscn").instance()
	button.connect("pressed",self,"change_tab_to",[script_path])
	button.container = self
	button.script_path = script_path
	tab_buttons[script_path] = button
	add_child(button)
	refresh_titles()
	change_tab_to(script_path)

func change_tab_to(btn:String):
	for b in tab_buttons:
		var i = tab_buttons[b]
		var sc = i.script_path
		var has = sc == btn
		i.set_active_tab(has)
		if has:
			current_tab = i.get_position_in_parent()

func set_tab_title(script:String,title:String):
	tab_buttons[script].set_text(title)
	
func refresh_titles():
	var unique = true
	var current_driver_names = {}
	for i in tabs:
		var iname:String = i.get_file()
		if iname in current_driver_names:
			current_driver_names[iname] = true
		else:
			current_driver_names[iname] = false
	for i in tabs:
		var iname:String = i.get_file()
		if iname.begins_with("temp_"):
			if tabs[i].needs_save:
				iname += "*"
			set_tab_title(i,iname)
		else:
			if current_driver_names[iname]:
				if tabs[i].needs_save:
					iname += "*"
				set_tab_title(i,"%s/%s" % [i.split("/")[2],iname])
			else:
				if tabs[i].needs_save:
					iname += "*"
				set_tab_title(i,iname)

func remove(script_path:String):
	var child = tabs[script_path]
	tab_container.remove_child(child)
	tabs.erase(script_path)
	child.queue_free()
	var button = tab_buttons[script_path]
	remove_child(button)
	tab_buttons.erase(script_path)
	button.queue_free()
	refresh_titles()
