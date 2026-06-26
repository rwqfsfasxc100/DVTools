tool
extends Resource
class_name ManifestResource

var manifest : Dictionary = {} setget set_manifest

var MI_name:String = ""
var MI_id:String = ""
var MI_description:String = "" setget set_desc
var MI_brief:String = ""
var MI_author:String = ""
var MI_credits:PoolStringArray = PoolStringArray()

func set_manifest(value:Dictionary) -> void:
	manifest = value
	emit_changed()

func set_desc(value:String):
	MI_description = value
	property_list_changed_notify()
	emit_changed()

func _get_property_list():
	var properties = []
	properties.append({
		name = "mod_information",
		type = TYPE_NIL,
		hint_string = "MI_",
		usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	properties.append({
		name = "MI_name",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_PLACEHOLDER_TEXT,
		hint_string = "Example Mod",
		hint_tooltip = "The name of your mod and the mod's display name.\nCan be a translation string.",
	})
	properties.append({
		name = "MI_id",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_PLACEHOLDER_TEXT,
		hint_string = "(nick)name.modname",
		hint_tooltip = "The mod's unique ID, used for organization and parenting submods.\nCommon convention is (nick)name.modname",
	})
	properties.append({
		name = "MI_description",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_PLACEHOLDER_TEXT,
		hint_string = "MOD_DESCRIPTION_TRANSLATION",
		hint_tooltip = "The mod's description text.\nCan be a translation string.",
	})
	properties.append({
		name = "MI_brief",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_PLACEHOLDER_TEXT,
		hint_string = "MOD_BRIEF_TRANSLATION",
		hint_tooltip = "A short description of the mod, intended to display below the mod's name in the mod menu list.\nCan be a translation string.",
	})
	properties.append({
		name = "MI_author",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_PLACEHOLDER_TEXT,
		hint_string = "Display <nick>name",
		hint_tooltip = "Your name, or the name you'd prefer to have displayed as the mod's author.\nCan be a translation string.",
	})
	properties.append({
		name = "MI_credits",
		type = TYPE_STRING_ARRAY,
		hint_tooltip = "Credits and/or decorators to be displayed sequentially in the mod menu.\nEach entry can be a translation string.",
	})
	
	
	
	
	
	
	return properties
