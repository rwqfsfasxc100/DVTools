tool
extends EditorPlugin


const MainPanel = preload("res://addons/DVTools/main_panel.tscn")
const ManifestClass = preload("res://addons/DVTools/resource_handling/Manifest/ModManifestClass.gd")
const ManifestTagTypeClass = preload("res://addons/DVTools/resource_handling/ManifestTagType/ManifestTagTypeClass.gd")

var main_panel_instance

func _enter_tree():
	main_panel_instance = MainPanel.instance()
	
	get_editor_interface().get_editor_viewport().add_child(main_panel_instance)
	make_visible(false)
	
	# Setting up for tooltips
	get_tree().connect("node_added", self, "_on_node_added", [], CONNECT_DEFERRED)
	
	
	


func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()
	# Removing tooltips
	get_tree().disconnect("node_added", self, "_on_node_added")


func has_main_screen():
	return true


func make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible


# If your plugin doesn't handle any node types, you can remove this method.
func handles(obj):
	return obj is preload("res://addons/DVTools/handled_by_main_screen.gd")


func get_plugin_name():
	return "ΔV Tools"


func get_plugin_icon():
#	var th :Theme= get_editor_interface().get_base_control().theme
#	ResourceSaver.save("user://theme.tres",th)
	# Must return some kind of Texture for the icon.
	return get_editor_interface().get_base_control().get_icon("Node", "EditorIcons")

func _on_node_added(node: Node):
	if node:
		var cls = node.get_class()
		if cls == "TooltipPanel":
			pass
		elif cls == "EditorHelpBit":
			# Tooltip for hints and properties
			var inspector = get_editor_interface().get_inspector()
			var obj = inspector.get_edited_object()
			if obj.has_method("_get_property_list"):
				var properties = obj._get_property_list()
				var np = node.get_parent()
				var pname = np.hint_tooltip
				for p in properties:
					if p.name == pname and "hint_tooltip" in p:
						var tt = p.hint_tooltip
						np.hint_tooltip = pname + "\n" + tt
						np.update()
						inspector.refresh()


















var useful_links = PoolStringArray([
	"https://forum.godotengine.org/t/how-do-i-modify-tooltip-for-editorproperty-from-editorplugin/139911",
	"https://github.com/AnidemDex/Godot-CustomResource",
	
])
