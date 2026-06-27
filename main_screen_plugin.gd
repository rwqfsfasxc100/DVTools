tool
extends EditorPlugin


const MainPanel = preload("res://addons/DVTools/main_panel.tscn")
const ManifestClass = preload("res://addons/DVTools/resource_handling/Manifest/ModManifestClass.gd")
const ManifestTagTypeClass = preload("res://addons/DVTools/resource_handling/Manifest/ManifestLinkType/ManifestLinkTypeClass.gd")

var main_panel_instance


# Inspector plugins
var tag_inspectorplugin
var manifest_version_lock_inspectorplugin


func _enter_tree():
	main_panel_instance = MainPanel.instance()
	
	get_editor_interface().get_editor_viewport().add_child(main_panel_instance)
	make_visible(false)
	
	# Setting up for tooltips
	get_tree().connect("node_added", self, "_on_node_added", [], CONNECT_DEFERRED)
	tag_inspectorplugin = preload("res://addons/DVTools/resource_handling/Manifest/ManifestLinkType/LinkHandler.gd").new()
	add_inspector_plugin(tag_inspectorplugin)
	manifest_version_lock_inspectorplugin = preload("res://addons/DVTools/resource_handling/Manifest/ManifestVersionLock/MVLockHandler.gd").new()
	add_inspector_plugin(manifest_version_lock_inspectorplugin)


func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()
	# Removing tooltips
	get_tree().disconnect("node_added", self, "_on_node_added")
	remove_inspector_plugin(tag_inspectorplugin)
	remove_inspector_plugin(manifest_version_lock_inspectorplugin)
	
	
	


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


















var useful_links = PoolStringArray([
	"https://forum.godotengine.org/t/how-do-i-modify-tooltip-for-editorproperty-from-editorplugin/139911",
	"https://github.com/AnidemDex/Godot-CustomResource",
	
])
