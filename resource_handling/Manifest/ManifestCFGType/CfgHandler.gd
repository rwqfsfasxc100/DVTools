tool
extends EditorInspectorPlugin

const langprop = preload("res://addons/DVTools/resource_handling/Manifest/ManifestCFGType/CfgProperty.gd")
const manifestclass = preload("res://addons/DVTools/resource_handling/Manifest/ModManifestClass.gd")

func can_handle(object):
	if object as manifestclass:
		return true
	return false

func parse_property(object, type, path, hint, hint_text, usage):
	if path == "CFG_configs":
		add_property_editor(path,langprop.new())
		return true
	return false

