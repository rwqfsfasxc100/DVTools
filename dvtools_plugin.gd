tool
extends EditorPlugin

const panel_enabled = false


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
	
	
]


var tool_panel_instance

var inspector_plugins = []

var icon_handler:Node
var file_tree: Tree
var search_box: LineEdit
var _is_update_queued = false

func _enter_tree():
	# Initializes the main panel
	if panel_enabled:
		tool_panel_instance = preload("res://addons/DVTools/DVToolPanel.tscn").instance()
		get_editor_interface().get_editor_viewport().add_child(tool_panel_instance)
		make_visible(false)
		
		# Driver detection
		var scriptEditor = get_editor_interface().get_script_editor()
		scriptEditor.connect("editor_script_changed",self,"handle_driver")
		scriptEditor.connect("script_close",self,"close_script")
	
	set_physics_process(true)
	
	# Setting up for tooltips
	get_tree().connect("node_added", self, "_on_node_added", [], CONNECT_DEFERRED)
	
	for p in property_handler_plugins:
		var plugin = p.new()
		add_inspector_plugin(plugin)
		inspector_plugins.append(plugin)
	
	add_icon_handler()
	
	


func _exit_tree():
	# Removing tooltips
	get_tree().disconnect("node_added", self, "_on_node_added")
	
	# Removing inspector plugins
	for plugin in inspector_plugins:
		remove_inspector_plugin(plugin)
	
	inspector_plugins = []
	
	remove_icon_handler()
	
	if panel_enabled:
		# Removing main screen panel
		if tool_panel_instance:
			tool_panel_instance.queue_free()
		
		# Removing driver detection
		var scriptEditor = get_editor_interface().get_script_editor()
		scriptEditor.disconnect("editor_script_changed",self,"handle_driver")
		scriptEditor.disconnect("script_close",self,"close_script")
	

# Main screen panel handling

func has_main_screen():
	return panel_enabled

const plugin_name = "ΔV Tools"

func make_visible(visible):
	if tool_panel_instance:
		tool_panel_instance.visible = visible
		if visible:
			get_editor_interface().set_main_screen_editor(plugin_name)

func get_plugin_name():
	return plugin_name

func get_plugin_icon():
	return get_editor_interface().get_base_control().get_icon("Node", "EditorIcons")


var supported_driver_files = PoolStringArray([
	"ADD_EQUIPMENT_ITEMS.gd",
	
])

func handle_driver(script:Script):
	var path = script.resource_path
	make_visible(path.get_file() in supported_driver_files)

func close_script(script:Object):
	make_visible(false)

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
