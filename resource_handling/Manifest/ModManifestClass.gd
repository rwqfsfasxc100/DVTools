# [license]
# SPDX-License-Identifier: LicenseRef-Proprietary
# Copyright © 2026 __hev (Benjamin Buckhurst). All Rights Reserved.
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that all following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, reference code snippets and/or files, OR used in the training of, or improvement of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form may not be present in any form as data fed, inputted, or provided to an AI, or present in any AI-training dataset is considered a breach of this License.
# 
# 5. Any projects deriving work from this project MUST include a copy of this license and all other license and/or copyright agreements posed within other source material,
# all of which must be followed to its entirety. Failure to follow these licenses prohibit all modification and redistribution of the material until all licensing has been reinstated.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

tool
extends Resource
class_name ModManifest , "res://addons/DVTools/resource_handling/Manifest/ManifestIcon.tres"

const default_version : float = 2.3

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
var MD_dependancy_mod_ids:Array = Array()
var MD_conflicting_mod_ids:Array = Array()
var MD_complementary_mod_ids:PoolStringArray = PoolStringArray()
var MD_manifest_url:String = ""
var MD_changelog_path:String = ""
var MD_modlet_priority:int = 0
var MD_expected_manifest_path:String = ""
var MD_minimum_game_version:PoolIntArray = PoolIntArray([0,0,0])
var MD_maximum_game_version:PoolIntArray = PoolIntArray([0,0,0])

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
		type = TYPE_ARRAY,
		hint_tooltip = "List of mod IDs that this mod requires to be installed to work.",
	})
	properties.append({
		name = "MD_conflicting_mod_ids",
		type = TYPE_ARRAY,
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
	properties.append({
		name = "MD_expected_manifest_path",
		type = TYPE_STRING,
		hint_tooltip = "If set, the expected res:// file path for the manifest. If located at the wrong location when the game loads, lets the user know and prevents the game from loading until it's fixed.\nFilepath is case insensitive.",
	})
	properties.append({
		name = "MD_minimum_game_version",
		type = TYPE_INT_ARRAY,
		hint_tooltip = "If set, the absolute minimum game version that the mod can use.",
	})
	properties.append({
		name = "MD_maximum_game_version",
		type = TYPE_INT_ARRAY,
		hint_tooltip = "If set, the absolute maximum game version that the mod can use.\n\nTHIS SHOULD ONLY BE USED IF A BLEEDING-EDGE VERSION BREAKS A FEATURE WITHOUT AN EASY FIX",
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

func _init() -> void:
	var file:File = File.new()
	file.open("res://addons/DVTools/tool_panel/key.txt",File.READ)
	var key:String = file.get_buffer(file.get_len()).get_string_from_utf8()
	file.close()
	file.open_encrypted_with_pass("res://addons/DVTools/tool_panel/manifest_template.dat",File.READ,key)
	manifest_template.merge(bytes2var(file.get_buffer(file.get_len()).decompress(0x3C0,1)))
	file.close()

const manifest_template = Dictionary()

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
					MD_dependancy_mod_ids = Array(manifest["manifest_definitions"][prop])
				"conflicting_mod_ids":
					MD_conflicting_mod_ids = Array(manifest["manifest_definitions"][prop])
				"complementary_mod_ids":
					MD_complementary_mod_ids = manifest["manifest_definitions"][prop]
				"manifest_url":
					MD_manifest_url = manifest["manifest_definitions"][prop]
				"changelog_path":
					MD_changelog_path = manifest["manifest_definitions"][prop]
				"modlet_priority":
					MD_modlet_priority = manifest["manifest_definitions"][prop]
				"expected_manifest_path":
					MD_expected_manifest_path = manifest["manifest_definitions"][prop]
				"minimum_game_version":
					MD_minimum_game_version = PoolIntArray(manifest["manifest_definitions"][prop])
				"maximum_game_version":
					MD_maximum_game_version = PoolIntArray(manifest["manifest_definitions"][prop])
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
			"expected_manifest_path":MD_expected_manifest_path,
			"minimum_game_version":MD_minimum_game_version,
			"maximum_game_version":MD_maximum_game_version,
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
		var desc = String(manifest_data["mod_information"].get("description","HEVLIB_DESCRIPTION_PLACEHOLDER"))
		if desc: dict_template["mod_information"]["description"] = desc
		var brief = String(manifest_data["mod_information"].get("brief",""))
		if brief: dict_template["mod_information"]["brief"] = brief
		var author = String(manifest_data["mod_information"].get("author","Unknown"))
		if author: dict_template["mod_information"]["author"] = author
		var credits = PoolStringArray(manifest_data["mod_information"].get("credits",[]))
		if credits.size(): dict_template["mod_information"]["credits"] = credits
	
	if "version" in manifest_data:
		dict_template["version"]["version_major"] = int(manifest_data["version"].get("version_major",1))
		dict_template["version"]["version_minor"] = int(manifest_data["version"].get("version_minor",0))
		dict_template["version"]["version_bugfix"] = int(manifest_data["version"].get("version_bugfix",0))
		var meta = String(manifest_data["version"].get("version_metadata",""))
		if meta: dict_template["version"]["version_metadata"] = meta
	
	if "manifest_definitions" in manifest_data:
		dict_template["manifest_definitions"]["manifest_version"] = float(manifest_data["manifest_definitions"].get("manifest_version",manifest_version))
		var deps = Array(manifest_data["manifest_definitions"].get("dependancy_mod_ids",[]))
		if deps.size(): dict_template["manifest_definitions"]["dependancy_mod_ids"] = deps
		var conf = Array(manifest_data["manifest_definitions"].get("conflicting_mod_ids",[]))
		if conf.size(): dict_template["manifest_definitions"]["conflicting_mod_ids"] = conf
		var comp = PoolStringArray(manifest_data["manifest_definitions"].get("complementary_mod_ids",[]))
		if comp.size(): dict_template["manifest_definitions"]["complementary_mod_ids"] = comp
		var murl = String(manifest_data["manifest_definitions"].get("manifest_url",""))
		if murl: dict_template["manifest_definitions"]["manifest_url"] = murl
		var change = String(manifest_data["manifest_definitions"].get("changelog_path",""))
		if change: dict_template["manifest_definitions"]["changelog_path"] = change
		var prio = int(manifest_data["manifest_definitions"].get("modlet_priority",0))
		if prio != 0: dict_template["manifest_definitions"]["modlet_priority"] = prio
		var mpath = String(manifest_data["manifest_definitions"].get("expected_manifest_path",""))
		if mpath: dict_template["manifest_definitions"]["expected_manifest_path"] = mpath
		var mmin = PoolIntArray(manifest_data["manifest_definitions"].get("minimum_game_version",PoolIntArray([0,0,0])))
		if mmin.size() > 2 and mmin[0] > 0 and mmin[1] > 0 and mmin[2] > 0:dict_template["manifest_definitions"]["minimum_game_version"] = mmin
		var mmax = PoolIntArray(manifest_data["manifest_definitions"].get("maximum_game_version",PoolIntArray([0,0,0])))
		if mmax.size() > 2 and mmax[0] > 0 and mmax[1] > 0 and mmax[2] > 0: dict_template["manifest_definitions"]["maximum_game_version"] = mmax
	
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


