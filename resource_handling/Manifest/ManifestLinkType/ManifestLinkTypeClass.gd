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
		hint_tooltip = "URL for the link. Only required portion of the property."
	})
	properties.append({
		name = "ICON",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_FILE,
		hint_string = "*.stex,*.png ; Image Files",
		hint_tooltip = "Filepath to a .stex or .png file to use as the icon."
	})
	properties.append({
		name = "TOOLTIP",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_PLACEHOLDER_TEXT,
		hint_string = "<nick>name.modname",
		hint_tooltip = "Tooltip for the button.\nCan be a translation string."
	})
	return properties
