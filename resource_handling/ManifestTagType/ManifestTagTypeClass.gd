tool
extends Resource
class_name ManifestTagTypeResource

var URL:String = "" setget set_url
var ICON:String = "" setget set_icon
var TOOLTIP:String = "" setget set_tooltip

func set_url(value:String) -> void:
	URL = value
	emit_changed()

func set_icon(value:String) -> void:
	ICON = value
	emit_changed()

func set_tooltip(value:String) -> void:
	TOOLTIP = value
	emit_changed()

func _get_property_list():
	var properties = []
	properties.append({
		name = "URL",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_PLACEHOLDER_TEXT,
		hint_string = "https://example.com",
	})
	properties.append({
		name = "ICON",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_FILE,
		hint_string = "*.stex;*.png",
	})
	properties.append({
		name = "TOOLTIP",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_PLACEHOLDER_TEXT,
		hint_string = "<nick>name.modname",
	})
	return properties
