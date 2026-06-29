tool
extends EditorPlugin

const counter_maximum : float = 0.25 # Time in seconds between refreshes of the FileSystem modification

const MainPanel = preload("res://addons/DVTools/main_panel.tscn")
const classes = [
	preload("res://addons/DVTools/resource_handling/Manifest/ModManifestClass.gd"),
	preload("res://addons/DVTools/resource_handling/Manifest/ManifestLinkType/ManifestLinkTypeClass.gd"),
	preload("res://addons/DVTools/resource_handling/Manifest/ManifestTagType/ManifestTagTypeClass.gd"),
	
]

const property_handler_plugins = [
	preload("res://addons/DVTools/resource_handling/Manifest/ManifestLinkType/LinkHandler.gd"),
	preload("res://addons/DVTools/resource_handling/Manifest/ManifestVersionLock/MVLockHandler.gd"),
	preload("res://addons/DVTools/resource_handling/Manifest/ManifestTagType/TagHandler.gd"),
	
]


var main_panel_instance


# Inspector plugins
var tag_inspectorplugin
var manifest_version_lock_inspectorplugin

var inspector_plugins = []

var icon_handler:Node

func _enter_tree():
	main_panel_instance = MainPanel.instance()
	set_physics_process(true)
	get_editor_interface().get_editor_viewport().add_child(main_panel_instance)
	make_visible(false)
	
	# Setting up for tooltips
	get_tree().connect("node_added", self, "_on_node_added", [], CONNECT_DEFERRED)
	
	for p in property_handler_plugins:
		var plugin = p.new()
		add_inspector_plugin(plugin)
		inspector_plugins.append(plugin)
	
	add_icon_handler()
	
	


func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()
	# Removing tooltips
	get_tree().disconnect("node_added", self, "_on_node_added")
	for plugin in inspector_plugins:
		remove_inspector_plugin(plugin)
	
	inspector_plugins = []
	
	remove_icon_handler()
	

func has_main_screen():
	return true


func make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible


func get_plugin_name():
	return "ΔV Tools"


func get_plugin_icon():
	return get_editor_interface().get_base_control().get_icon("Node", "EditorIcons")

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
	var file_tree: Tree
	var file_list: ItemList
	for node in get_editor_interface().get_file_system_dock().get_children():
	# Only the parent of the file tree and file list is a VSplit
		if node is VSplitContainer:
			file_tree = node.get_child(0)
			file_list = node.get_child(1).get_child(1)
			break
	
	icon_handler.change_tree_appearance(file_tree)
	var interface := get_editor_interface()
	connect("redraw",self,"recheck_icon_handler",[file_tree])
#	var file_system := interface.get_resource_filesystem()
#	file_system.connect("filesystem_changed", self, "recheck_icon_handler", [file_tree])
#	file_system.connect("filesystem_changed", icon_handler, "change_tree_appearance", [file_tree])


signal redraw()

var ctr:float = 0.0

func _physics_process(delta):
	ctr += delta
	if ctr > counter_maximum:
		ctr = 0.0
		emit_signal("redraw")

func recheck_icon_handler(file_tree):
	if not icon_handler or not is_instance_valid(icon_handler) or icon_handler.is_queued_for_deletion():
		icon_handler = load("res://addons/DVTools/icon_handler.gd").new()
		
		icon_handler.change_tree_appearance(file_tree)
#		var file_system := get_editor_interface().get_resource_filesystem()
#		file_system.connect("filesystem_changed", icon_handler, "change_tree_appearance", [file_tree])
	else:
		icon_handler.change_tree_appearance(file_tree)
	
func remove_icon_handler():
	var file_system := get_editor_interface().get_resource_filesystem()
#	file_system.disconnect("filesystem_changed", icon_handler, "change_tree_appearance")
	disconnect("redraw",self,"recheck_icon_handler")
	file_system.scan()
	icon_handler = null
















var useful_links = PoolStringArray([
	"https://forum.godotengine.org/t/how-do-i-modify-tooltip-for-editorproperty-from-editorplugin/139911",
	"https://github.com/AnidemDex/Godot-CustomResource",
	"https://gist.github.com/Qubus0/4f0077675647a986cb9e83b9cb9e0d87",
	
])
