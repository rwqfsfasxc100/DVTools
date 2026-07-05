tool
extends Resource
class_name ManifestResource , "res://addons/DVTools/resource_handling/Manifest/ManifestIcon.tres"

var manifest : Dictionary = {} setget set_manifest , get_manifest

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
var TG_tags:Dictionary = {}

# links
var LK_links:Dictionary = {}

# languages
var LG_languages:Dictionary = {}

# configs
var CFG_configs:Dictionary = {}



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
		type = TYPE_BOOL,
		hint_tooltip = "Whether the mod should be treated as a library. Should be used only on mods distributing code and/or tools for other mods.",
	})
	properties.append({
		name = "library_always_display",
		type = TYPE_BOOL,
		hint_tooltip = "If the mod is to be treated as a library, whether it should be shown in mod lists as a regular mod.",
	})
	
	
	# Manifest definitions group
	properties.append({
		name = "manifest_definitions",
		type = TYPE_NIL,
		hint_string = "MD_",
		usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	
	# Manifest definitions properties
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
		hint_tooltip = "The URL to a raw text copy of the manifest used for update handling. \nFor example, 'https://raw.githubusercontent.com/rwqfsfasxc100/HevLib/main/Mod.manifest'",
	})
	properties.append({
		name = "MD_changelog_path",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_PLACEHOLDER_TEXT,
		hint_string = "e.g. changelog.txt",
		hint_tooltip = "Path to the changelog file, relative to the manifest's directory. \nFor example, 'changelog.txt' equates to a filepath at 'res://Example Mod/changelog.txt', if the manifest was at 'res://Example Mod/mod.manifest'",
	})
	properties.append({
		name = "MD_modlet_priority",
		type = TYPE_INT,
		hint_tooltip = "The priority for a modlet to load. Only works for modlet-based mods (no ModMain.gd)",
	})
	
	
	# Links group
	properties.append({
		name = "links",
		type = TYPE_NIL,
		hint_string = "LK_",
		usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	
	# Links properties
	properties.append({
		name = "LK_links",
		type = TYPE_DICTIONARY,
		hint_tooltip = "Links available from the mod manifest.",
	})
	
	# Tags group
	properties.append({
		name = "tags",
		type = TYPE_NIL,
		hint_string = "TG_",
		usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	
	# Tags properties
	properties.append({
		name = "TG_tags",
		type = TYPE_DICTIONARY,
		hint_tooltip = "Tags available from the manifest.",
	})
	
	# Languages group
	properties.append({
		name = "languages",
		type = TYPE_NIL,
		hint_string = "LG_",
		usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	
	# Languages properties
	properties.append({
		name = "LG_languages",
		type = TYPE_DICTIONARY,
		hint_tooltip = "Language percentages displayed if the mod doesn't have a compatible translation driver.\nIf you use REPLACE_TRANSLATIONS.gd, you can ignore this as it's completely overwritten by that driver's data.",
	})
	
	# Configs group
	properties.append({
		name = "configs",
		type = TYPE_NIL,
		hint_string = "CFG_",
		usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	
	# Configs properties
	properties.append({
		name = "CFG_configs",
		type = TYPE_DICTIONARY,
		hint_tooltip = "Configs provided by the manifest and displayed in the mod menu's settings menu",
	})
	
	return properties

const default_version : float = 2.2

const manifest_template = {
	"mod_information":{
		"name":"",
		"id":"",
		"description":"",
		"brief":"",
		"author":"",
		"credits":PoolStringArray()
	},
	"version":{
		"version_major":1,
		"version_minor":0,
		"version_bugfix":0,
		"version_metadata":"",
		"version_string":"1.0.0"
	},
	"tags":{
		
	},
	"links":{
		
	},
	"configs":{
		
	},
	"languages":{
		
	},
	"library":{
		"is_library":false,
		"always_display":false,
	},
	"manifest_definitions":{
		"manifest_version":default_version,
		"dependancy_mod_ids":PoolStringArray(),
		"conflicting_mod_ids":PoolStringArray(),
		"complementary_mod_ids":PoolStringArray(),
		"manifest_url":"", # EXAMPLE: https://raw.githubusercontent.com/rwqfsfasxc100/HevLib/main/Mod.manifest
		"changelog_path":"", # This is relative to the ModMain.gd file. EXAMPLE: for a file at 'res://Example Mod/data/folder/changelogs.txt', you would put 'data/folder/changelogs.txt'
		"modlet_priority":0, # SPECIFIC TO MODLETS! The order at which the modlet would be loaded. Most modlets load before other mods, but this will affect load order within the list of installed modlets
	}
}

const always_save = {"mod_information":{"name":"Example Mod","id":"example.mod"},"version":{"version_major":1,"version_minor":0,"version_bugfix":0,},"manifest_definitions":{"manifest_version":default_version,},}

func set_manifest(value:Dictionary) -> void:
	manifest = value
	if "mod_information" in manifest:
		for prop in manifest["mod_information"]:
			match prop:
				"name":
					MI_name = manifest["mod_information"][prop]
				"id":
					MI_id = manifest["mod_information"][prop]
				"description":
					MI_description = manifest["mod_information"][prop]
				"brief":
					MI_brief = manifest["mod_information"][prop]
				"author":
					MI_author = manifest["mod_information"][prop]
				"credits":
					MI_credits = manifest["mod_information"][prop]
	if "version" in manifest:
		for prop in manifest["version"]:
			match prop:
				"version_major":
					version_major = manifest["version"][prop]
				"version_minor":
					version_minor = manifest["version"][prop]
				"version_bugfix":
					version_bugfix = manifest["version"][prop]
				"version_metadata":
					version_metadata = manifest["version"][prop]
				"version_string":
					version_string = manifest["version"][prop]
	if "library" in manifest:
		for prop in manifest["library"]:
			match prop:
				"is_library":
					library_is_library = manifest["library"][prop]
				"always_display":
					library_always_display = manifest["library"][prop]
	if "manifest_definitions" in manifest:
		for prop in manifest["manifest_definitions"]:
			match prop:
				"dependancy_mod_ids":
					MD_dependancy_mod_ids = manifest["manifest_definitions"][prop]
				"conflicting_mod_ids":
					MD_conflicting_mod_ids = manifest["manifest_definitions"][prop]
				"complementary_mod_ids":
					MD_complementary_mod_ids = manifest["manifest_definitions"][prop]
				"manifest_url":
					MD_manifest_url = manifest["manifest_definitions"][prop]
				"changelog_path":
					MD_changelog_path = manifest["manifest_definitions"][prop]
				"modlet_priority":
					MD_modlet_priority = manifest["manifest_definitions"][prop]
	if "tags" in manifest:
		TG_tags = manifest["tags"]
	if "links" in manifest:
		LK_links = manifest["links"]
	if "configs" in manifest:
		CFG_configs = manifest["configs"]
	if "languages" in manifest:
		LG_languages = manifest["languages"]
	emit_changed()

signal about_to_save()

func get_manifest() -> Dictionary:
	emit_signal("about_to_save")
	var initDict = {
		"mod_information":{
			"name":MI_name,
			"id":MI_id,
			"description":MI_description,
			"brief":MI_brief,
			"author":MI_author,
			"credits":MI_credits
		},
		"version":{
			"version_major":version_major,
			"version_minor":version_minor,
			"version_bugfix":version_bugfix,
			"version_metadata":version_metadata,
			"version_string":version_string
		},
		"tags":TG_tags,
		"links":LK_links,
		"configs":CFG_configs,
		"languages":LG_languages,
		"library":{
			"is_library":library_is_library,
			"always_display":library_always_display,
		},
		"manifest_definitions":{
			"manifest_version":default_version,
			"dependancy_mod_ids":MD_dependancy_mod_ids,
			"conflicting_mod_ids":MD_conflicting_mod_ids,
			"complementary_mod_ids":MD_complementary_mod_ids,
			"manifest_url":MD_manifest_url,
			"changelog_path":MD_changelog_path,
			"modlet_priority":MD_modlet_priority,
		},
	}
	var out = format(initDict)
	return out

static func format(manifest_data : Dictionary) -> Dictionary:
	var dict_template = manifest_template.duplicate(true)
	var manifest_version = manifest_data.get("manifest_definitions",{}).get("manifest_version",default_version)
	if "mod_information" in manifest_data:
		dict_template["mod_information"]["id"] = String(manifest_data["mod_information"].get("id",""))
		dict_template["mod_information"]["name"] = String(manifest_data["mod_information"].get("name",""))
		dict_template["mod_information"]["description"] = String(manifest_data["mod_information"].get("description","HEVLIB_DESCRIPTION_PLACEHOLDER"))
		dict_template["mod_information"]["brief"] = String(manifest_data["mod_information"].get("brief",""))
		dict_template["mod_information"]["author"] = String(manifest_data["mod_information"].get("author","Unknown"))
		dict_template["mod_information"]["credits"] = PoolStringArray(manifest_data["mod_information"].get("credits",[]))
	
	if "version" in manifest_data:
		dict_template["version"]["version_major"] = int(manifest_data["version"].get("version_major",1))
		dict_template["version"]["version_minor"] = int(manifest_data["version"].get("version_minor",0))
		dict_template["version"]["version_bugfix"] = int(manifest_data["version"].get("version_bugfix",0))
		dict_template["version"]["version_metadata"] = String(manifest_data["version"].get("version_metadata",""))
	
	if "manifest_definitions" in manifest_data:
		dict_template["manifest_definitions"]["manifest_version"] = float(manifest_data["manifest_definitions"].get("manifest_version",manifest_version))
		dict_template["manifest_definitions"]["dependancy_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("dependancy_mod_ids",[]))
		dict_template["manifest_definitions"]["conflicting_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("conflicting_mod_ids",[]))
		dict_template["manifest_definitions"]["complementary_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("complementary_mod_ids",[]))
		dict_template["manifest_definitions"]["manifest_url"] = String(manifest_data["manifest_definitions"].get("manifest_url",""))
		dict_template["manifest_definitions"]["changelog_path"] = String(manifest_data["manifest_definitions"].get("changelog_path",""))
		dict_template["manifest_definitions"]["modlet_priority"] = int(manifest_data["manifest_definitions"].get("modlet_priority",0))
	
	if "links" in manifest_data:
		var links = manifest_data["links"]
		var ovLinks = {}
		for link in links:
			var ld = links[link]
			if typeof(ld) == TYPE_DICTIONARY:
				if "URL" in ld and typeof(ld.URL) == TYPE_STRING:
					ovLinks[link] = ld
		if ovLinks:
			dict_template["links"] = ovLinks
	if "tags" in manifest_data:
		var tags = manifest_data["tags"]
		var ovTags = {}
		for tag in tags:
			var td = tags[tag]
			if typeof(td) == TYPE_DICTIONARY:
				if "type" in td and "value" in td and typeof(td.type) == TYPE_STRING:
					ovTags[tag] = td
		if ovTags:
			dict_template["tags"] = ovTags
	if "languages" in manifest_data:
		var languages = manifest_data["languages"]
		for language in languages:
			var ld = languages[language]
			var tld = typeof(ld)
			if tld == TYPE_STRING:
				dict_template["languages"][language] = ld
			elif tld == TYPE_INT or tld == TYPE_REAL:
				dict_template["languages"][language] = str(ld) + "%"
	if "library" in manifest_data:
		dict_template["library"]["is_library"] = manifest_data["library"].get("is_library",false)
		dict_template["library"]["always_display"] = manifest_data["library"].get("always_display",false)
		
	if "configs" in manifest_data:
		var configs = manifest_data["configs"]
		var ovConfigs = {}
		for section in configs:
			var sec_data = configs[section]
			for cfname in sec_data:
				var cfdata = sec_data[cfname]
				if not cfdata.get("disabled",false):
					if not section in ovConfigs:
						ovConfigs[section] = {}
					ovConfigs[section][cfname] = cfdata
		if ovConfigs:
			dict_template["configs"] = ovConfigs
	var out = {}
	
	for section in dict_template:
		var always = always_save.get(section,{})
		for key in dict_template[section]:
			var value = dict_template[section].get(key)
			if (value != null):
				if (not key in manifest_template[section]) or (hash(value) != hash(manifest_template[section][key])):
					if not section in out:
						out[section] = {}
					out[section][key] = value
				elif key in always:
					if not section in out:
						out[section] = {}
					out[section][key] = always[key]
	
	return out


