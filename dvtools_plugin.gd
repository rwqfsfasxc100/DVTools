tool
extends EditorPlugin

const panel_enabled = true

const classes = [
	preload("res://addons/DVTools/resource_handling/Manifest/ModManifestClass.gd"),
	preload("res://addons/DVTools/resource_handling/Manifest/ManifestLinkType/ManifestLinkTypeClass.gd"),
	preload("res://addons/DVTools/resource_handling/Manifest/ManifestTagType/ManifestTagTypeClass.gd"),
	preload("res://addons/DVTools/resource_handling/Manifest/ManifestLangType/ManifestLangTypeClass.gd"),
	preload("res://addons/DVTools/resource_handling/Manifest/ManifestCFGType/ManifestCfgTypeClass.gd")
	
]

const property_handler_plugins = [
	preload("res://addons/DVTools/resource_handling/Manifest/ManifestLinkType/LinkHandler.gd"),
	preload("res://addons/DVTools/resource_handling/Manifest/ManifestVersionLock/MVLockHandler.gd"),
	preload("res://addons/DVTools/resource_handling/Manifest/ManifestTagType/TagHandler.gd"),
	preload("res://addons/DVTools/resource_handling/Manifest/ManifestLangType/LangHandler.gd"),
	preload("res://addons/DVTools/resource_handling/Manifest/ManifestCFGType/CfgHandler.gd"),
	preload("res://addons/DVTools/resource_handling/Manifest/ManifestConflictAndRequirementsType/MVConflictsHelper.gd")
	
]

var supported_driver_files = PoolStringArray([
	"ADD_EQUIPMENT_ITEMS.gd",
	"ADD_EQUIPMENT_SLOTS.gd",
	"EQUIPMENT_TAGS.gd",
	"SLOT_TAGS.gd",
	
])


var tool_panel_instance

var inspector_plugins = []

var icon_handler:Node
var file_tree: Tree
var search_box: LineEdit
var _is_update_queued = false

var _did_enable_panel = false

var plugin_settings

func _enter_tree():
	plugin_settings = load("res://addons/DVTools/tool_panel/settings/SettingsHandler.tscn").instance()
	add_child(plugin_settings)
	plugin_settings.init_settings()
	# Initializes the main panel
	if panel_enabled:
		tool_panel_instance = ResourceLoader.load("res://addons/DVTools/tool_panel/DVToolPanel.tscn","",true).instance()
		tool_panel_instance.connect("reload_scripts",self,"reload_open_scripts")
		tool_panel_instance.plugin_settings = plugin_settings
		get_editor_interface().get_editor_viewport().add_child(tool_panel_instance)
		make_visible(false)
		
		# Driver detection
		var scriptEditor = get_editor_interface().get_script_editor()
		scriptEditor.connect("editor_script_changed",self,"handle_driver")
		scriptEditor.connect("script_close",self,"close_script")
		_did_enable_panel = true
	
	set_physics_process(true)
	
	# Setting up for tooltips
	get_tree().connect("node_added", self, "_on_node_added", [], CONNECT_DEFERRED)
	
	for p in property_handler_plugins:
		var plugin = p.new()
		add_inspector_plugin(plugin)
		inspector_plugins.append(plugin)
	
	add_icon_handler()
	
	


func _exit_tree():
	plugin_settings = null
	# Removing tooltips
	get_tree().disconnect("node_added", self, "_on_node_added")
	
	# Removing inspector plugins
	for plugin in inspector_plugins:
		remove_inspector_plugin(plugin)
	
	inspector_plugins = []
	
	remove_icon_handler()
	
	if _did_enable_panel:
		# Removing main screen panel
		if tool_panel_instance:
			tool_panel_instance.queue_free()
			tool_panel_instance.disconnect("reload_scripts",self,"reload_open_scripts")
			tool_panel_instance.queue_free()
		# Removing driver detection
		var scriptEditor = get_editor_interface().get_script_editor()
		scriptEditor.disconnect("editor_script_changed",self,"handle_driver")
		scriptEditor.disconnect("script_close",self,"close_script")
	

# Main screen panel handling

func reload_open_scripts():
	var scriptEditor : ScriptEditor = get_editor_interface().get_script_editor()
	scriptEditor.reload_scripts()


func has_main_screen():
	return panel_enabled

const plugin_name = "ΔV Tools"

func make_visible(visible:bool,file_to_load:String = ""):
	if tool_panel_instance:
		tool_panel_instance.visible = visible
		if visible:
			get_editor_interface().set_main_screen_editor(plugin_name)
			if file_to_load:
				if tool_panel_instance.has_method("load_this_file"):
					tool_panel_instance.load_this_file(file_to_load)
		

func get_plugin_name():
	return plugin_name

func get_plugin_icon():
	return get_editor_interface().get_base_control().get_icon("Node", "EditorIcons")


var can_open_driver = true
func handle_driver(script:Script):
	yield(get_tree(),"idle_frame")
	if can_open_driver:
		can_open_driver = false
		yield(get_tree(),"idle_frame")
		if script:
			var path = script.resource_path
			var is_driver = path.get_file() in supported_driver_files
			_update_driver_editor_lock(script, is_driver)
			make_visible(is_driver, path)
		can_open_driver = true

func _get_active_text_edit(node: Node) -> TextEdit:
	if node is TextEdit and node.is_visible_in_tree():
		return node as TextEdit
	for child in node.get_children():
		var found = _get_active_text_edit(child)
		if found:
			return found
	return null

var _unlocked_drivers := {}

func _update_driver_editor_lock(script: Script, is_driver: bool):
	var script_editor = get_editor_interface().get_script_editor()
	var text_edit = _get_active_text_edit(script_editor)
	if not text_edit:
		return
		
	var path = script.resource_path
	var is_unlocked = _unlocked_drivers.get(path, false)
	
	if is_driver and not is_unlocked:
		text_edit.readonly = true
	else:
		text_edit.readonly = false
		
	var parent = text_edit.get_parent()
	if not parent:
		return
		
	var banner = parent.get_node_or_null("DVToolsDriverBanner")
	if not is_driver:
		if banner:
			banner.hide()
		return
		
	if not banner:
		banner = PanelContainer.new()
		banner.name = "DVToolsDriverBanner"
		
		var margin = MarginContainer.new()
		banner.add_child(margin)
		
		var hbox = HBoxContainer.new()
		margin.add_child(hbox)
		
		var label = Label.new()
		label.name = "BannerLabel"
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(label)
		
		var button = Button.new()
		button.name = "BannerButton"
		hbox.add_child(button)
		
		parent.add_child(banner)
		parent.move_child(banner, 0)
		
	banner.show()
	var label: Label = banner.find_node("BannerLabel", true, false)
	var button: Button = banner.find_node("BannerButton", true, false)
	
	if is_unlocked:
		label.text = "Driver script (manual edit unlocked)."
		button.text = "Relock"
	else:
		label.text = "Driver script managed by ΔV Tools panel."
		button.text = "Unlock Editing"
		
	if button.is_connected("pressed", self, "_on_banner_button_pressed"):
		button.disconnect("pressed", self, "_on_banner_button_pressed")
	button.connect("pressed", self, "_on_banner_button_pressed", [script, not is_unlocked])

func _on_banner_button_pressed(script: Script, set_unlock: bool):
	if script:
		_unlocked_drivers[script.resource_path] = set_unlock
		_update_driver_editor_lock(script, true)

func close_script(script:Object):
	can_open_driver = false
	make_visible(false)
	if tool_panel_instance.has_method("close_script"):
		tool_panel_instance.close_script(script.resource_path)
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	can_open_driver = true
	

func handles(object):
	
	return false



# Tooltip handling
# Tooltips for properties can be added by setting a 'hint_tooltip' entry in the property's _get_property_list entry

func _on_node_added(node: Node):
	if node:
		if node.get_class().begins_with("EditorProperty"):
			if node.has_method("get_edited_object"):
				var obj = node.get_edited_object()
				
				var hp = obj.has_method("_get_property_list")
				if hp:
					var properties = obj._get_property_list()
					var np = node.get_parent() if not "hint_tooltip" in node else node
					var pname = np.hint_tooltip
					for p in properties:
						var prname = p.name
						if prname == pname:
							if "hint_tooltip" in p:
								var tt = p.hint_tooltip
								np.hint_tooltip = pname + "\n" + tt
								np.update()

# Code to handle icon changes

func add_icon_handler():
	icon_handler = load("res://addons/DVTools/icon_handler.gd").new()
	var file_list: ItemList
	var interface := get_editor_interface()
	for node in interface.get_file_system_dock().get_children():
		# Only the parent of the file tree and file list is a VSplit
		if node is VSplitContainer:
			file_tree = node.get_child(0)
			file_list = node.get_child(1).get_child(1)
		elif node is VBoxContainer:
			if node.get_child_count() > 0 and node.get_child(0) is HBoxContainer:
				for child in node.get_child(0).get_children():
					if child is LineEdit:
						search_box = child
						break
	
	if file_tree:
		icon_handler.change_tree_appearance(file_tree)
		file_tree.connect("item_collapsed", self, "_on_tree_item_collapsed")
		
		if search_box:
			search_box.connect("text_changed", self, "_on_search_changed")
		
		var file_system := interface.get_resource_filesystem()
		file_system.connect("filesystem_changed", self, "recheck_icon_handler")
		file_system.connect("filesystem_changed", plugin_settings, "recheck_fs")
	
	
func _on_tree_item_collapsed(_item: TreeItem):
	recheck_icon_handler()

func _on_search_changed(_new_text: String):
	recheck_icon_handler()

func recheck_icon_handler():
	if _is_update_queued:
		return
	_is_update_queued = true
	yield(get_tree(), "idle_frame")
	_is_update_queued = false
	
	if not file_tree:
		return
	if not icon_handler or not is_instance_valid(icon_handler) or icon_handler.is_queued_for_deletion():
		icon_handler = load("res://addons/DVTools/icon_handler.gd").new()

	if is_instance_valid(icon_handler):
		icon_handler.change_tree_appearance(file_tree)
	
func remove_icon_handler():
	var file_system := get_editor_interface().get_resource_filesystem()
	if file_system and file_system.is_connected("filesystem_changed", self, "recheck_icon_handler"):
		file_system.disconnect("filesystem_changed", self, "recheck_icon_handler")
	if file_tree:
		if file_tree.is_connected("item_collapsed", self, "_on_tree_item_collapsed"):
			file_tree.disconnect("item_collapsed", self, "_on_tree_item_collapsed")
	if search_box and search_box.is_connected("text_changed", self, "_on_search_changed"):
		search_box.disconnect("text_changed", self, "_on_search_changed")
		
	file_system.scan()
	icon_handler = null
	file_tree = null
	search_box = null
















var useful_links = PoolStringArray([
	"https://forum.godotengine.org/t/how-do-i-modify-tooltip-for-editorproperty-from-editorplugin/139911",
	"https://github.com/AnidemDex/Godot-CustomResource",
	"https://gist.github.com/Qubus0/4f0077675647a986cb9e83b9cb9e0d87",
	
])
