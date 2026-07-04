tool
extends EditorInspectorPlugin

const manifestclass = preload("res://addons/DVTools/resource_handling/Manifest/ModManifestClass.gd")
const mvprop = preload("res://addons/DVTools/resource_handling/Manifest/ManifestVersionLock/MVLockProperty.gd")

func can_handle(object):
	if object as manifestclass:
		return true
	return false

func parse_property(object, type, path, hint, hint_text, usage):
	if path == "MD_manifest_version":
		add_property_editor(path,mvprop.new())
		
		return true
	return false
