tool
extends Resource
class_name ManifestResource

var manifest : Dictionary = {} setget set_manifest

# mod_information
var MI_name:String = ""
var MI_id:String = ""
var MI_description:String = ""
var MI_brief:String = ""
var MI_author:String = ""
var MI_credits:PoolStringArray = PoolStringArray()

# version
var version_major:int = 1
var version_minor:int = 0
var version_bugfix:int = 0
var version_metadata:String = ""
var version_string:String = "1.0.0"

# library
var library_is_library:bool = false
var library_always_display:bool = false

# manifest_definitions
var MD_manifest_version:float = 2.2
var MD_dependancy_mod_ids:PoolStringArray = PoolStringArray()
var MD_conflicting_mod_ids:PoolStringArray = PoolStringArray()
var MD_complementary_mod_ids:PoolStringArray = PoolStringArray()
var MD_manifest_url:String = ""
var MD_changelog_path:String = ""
var MD_modlet_priority:int = 0

# tags
var TG_tags:Array = []

# links
var LK_links:Array = []

# languages
var LG_languages:Array = []

# configs
var CFG_configs:Dictionary = {}


func set_manifest(value:Dictionary) -> void:
	manifest = value
	emit_changed()

func _get_property_list():
	var properties = []
	
	# Mod information group
	properties.append({
		name = "mod_information",
		type = TYPE_NIL,
		hint_string = "MI_",
		usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	
	# Mod information properties
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
	
	
	# Version group
	properties.append({
		name = "version",
		type = TYPE_NIL,
		hint_string = "version_",
		usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	
	# Version properties
	properties.append({
		name = "version_major",
		type = TYPE_INT,
		hint_tooltip = "The mod's major version (first number in semantics)",
	})
	properties.append({
		name = "version_minor",
		type = TYPE_INT,
		hint_tooltip = "The mod's minor version (second number in semantics)",
	})
	properties.append({
		name = "version_bugfix",
		type = TYPE_INT,
		hint_tooltip = "The mod's bugfix version (third number in semantics)",
	})
	properties.append({
		name = "version_metadata",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_PLACEHOLDER_TEXT,
		hint_string = "",
		hint_tooltip = "Additional information to be added to printable versions. Does not affect version checks",
	})
	properties.append({
		name = "version_string",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_PLACEHOLDER_TEXT,
		hint_string = "1.0.0",
		hint_tooltip = "Used for mods that don't work with semantic versioning. Used only for backwards compatibility.",
	})
	
	
	# Library group
	properties.append({
		name = "library",
		type = TYPE_NIL,
		hint_string = "library_",
		usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	
	# Library properties
	properties.append({
		name = "library_is_library",
		type = TYPE_INT,
		hint_tooltip = "Whether the mod should be treated as a library. Should be used only on mods distributing code and/or tools for other mods.",
	})
	properties.append({
		name = "library_always_display",
		type = TYPE_INT,
		hint_tooltip = "If the mod is to be treated as a library, whether it should be shown in mod lists as a regular mod.",
	})
	
	
	# Manifest definitions group
	properties.append({
		name = "manifest_definitions",
		type = TYPE_NIL,
		hint_string = "MD_",
		usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	
	# Library properties
	properties.append({
		name = "MD_manifest_version",
		type = TYPE_REAL,
		hint_tooltip = "The manifest's version. Defaults to newest available version.",
	})
	properties.append({
		name = "MD_dependancy_mod_ids",
		type = TYPE_STRING_ARRAY,
		hint_tooltip = "List of mod IDs that this mod requires to be installed to work.",
	})
	properties.append({
		name = "MD_conflicting_mod_ids",
		type = TYPE_STRING_ARRAY,
		hint_tooltip = "List of mod IDs that this mod will have issues with.",
	})
	properties.append({
		name = "MD_complementary_mod_ids",
		type = TYPE_STRING_ARRAY,
		hint_tooltip = "List of mod IDs that this mod will gain additional functionality by having installed.",
	})
	properties.append({
		name = "MD_manifest_url",
		type = TYPE_STRING,
		hint_tooltip = "The URL to a raw text copy of the manifest used for update handling. e.g.: 'https://raw.githubusercontent.com/rwqfsfasxc100/HevLib/main/Mod.manifest'",
	})
	properties.append({
		name = "MD_changelog_path",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_PLACEHOLDER_TEXT,
		hint_string = "e.g. changelog.txt",
		hint_tooltip = "Path to the changelog file, relative to the manifest's directory. e.g.: 'changelog.txt' equates to a filepath at 'res://Example Mod/changelog.txt', if the manifest was at 'res://Example Mod/mod.manifest'",
	})
	properties.append({
		name = "MD_modlet_priority",
		type = TYPE_INT,
		hint_tooltip = "The priority for a modlet to load. Only works for modlet-based mods (no ModMain.gd)",
	})
	
	
	# Manifest definitions group
	properties.append({
		name = "links",
		type = TYPE_NIL,
		hint_string = "LK_",
		usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	
	# Library properties
	properties.append({
		name = "LK_links",
		type = TYPE_ARRAY,
		hint_string = "%s/%s:ManifestTagTypeResource" % [TYPE_OBJECT,TYPE_OBJECT],
		hint_tooltip = "Links available from the mod manifest. ",
	})
	
	
	
	
	
	
	
	return properties
