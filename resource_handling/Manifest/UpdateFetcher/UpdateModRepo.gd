tool
extends EditorInspectorPlugin

const manifestclass = preload("res://addons/DVTools/resource_handling/Manifest/ModManifestClass.gd")

func can_handle(object):
	if object as manifestclass:
		return true
	return false


func parse_end():
	var button = load("res://addons/DVTools/resource_handling/Manifest/UpdateFetcher/UpdateFetchButton.tscn").instance()
	
	add_custom_control(button)
	
	pass
