extends EditorInspectorPlugin

const tagprop = preload("res://addons/DVTools/resource_handling/Manifest/ManifestTagType/TagProperty.gd")
const manifestclass = preload("res://addons/DVTools/resource_handling/Manifest/ModManifestClass.gd")

func can_handle(object):
	if object as manifestclass:
		return true
	return false

func parse_property(object, type, path, hint, hint_text, usage):
	if path == "LK_links":
		add_property_editor(path,tagprop.new())
		
		return true
	return false

