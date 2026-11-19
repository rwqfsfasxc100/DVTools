# [license]
# 3-Clause BSD NON-AI License
# 
# Copyright 2026 __hev (Benjamin Buckhurst)
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
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
extends VBoxContainer

signal changed()

const LinkBox = preload("res://addons/DVTools/resource_handling/Manifest/ManifestTagType/TagBox.tscn")

onready var ENTRY = $ENTRY/COUNT
onready var PAGE = $PAGE/COUNT
onready var LIST = $LIST
onready var ADD = $ADD
onready var CONFIRM = $ConfirmationDialog
onready var CONFIRMNAME = $ConfirmationDialog/VBoxContainer/LineEdit
onready var CONFIRMERR = $ConfirmationDialog/VBoxContainer/Label
onready var CONFIRMOPT = $ConfirmationDialog/VBoxContainer/OptionButton

func _ready():
	ADD.connect("pressed",self,"_on_add_open")
	CONFIRM.connect("confirmed",self,"_add_confirmed")
	ENTRY.connect("value_changed",self,"_size_value_changed")
	PAGE.connect("value_changed",self,"_page_value_changed")
	CONFIRMOPT.connect("item_selected",self,"_built_in_selected")
	
	CONFIRMOPT.clear()
	var idx = 1
	CONFIRMOPT.add_item("",0)
	for tag in BUILTIN_TAGS:
		CONFIRMOPT.add_item(tag,idx)
		var tt = BUILTIN_TAGS[tag][2]
		CONFIRMOPT.set_item_tooltip(idx,tt)
		idx += 1
	

func _built_in_selected(idx:int):
	CONFIRMNAME.text = CONFIRMOPT.get_item_text(idx)

var dataStore = {}

func get_data():
	var out = {}
	for i in dataStore:
		out[i] = dataStore[i].get_data()
	return out

func set_data(STATE):
	for i in dataStore:
		delete(i)
	for i in STATE:
		var sd = STATE[i].get("value",null)
		add(i,sd)

func has_changed():
	emit_signal("changed")

func _on_add_open():
	CONFIRMNAME.text = ""
	CONFIRMERR.visible = false
	CONFIRM.popup_centered()
	CONFIRMNAME.grab_focus()

func _add_confirmed():
	var newname = CONFIRMNAME.text
	if not newname in dataStore:
		var init_type = null
		if newname in BUILTIN_TAGS:
			init_type = BUILTIN_TAGS[newname][1]
		add(newname,init_type)
	else:
		CONFIRMERR.visible = true

func add(item_name,init_type = null):
	var box = LinkBox.instance()
	box.boxname = item_name
	dataStore[item_name] = box
	box.CONTAINER = self
	if init_type != null:
		box.initial_type = init_type
	CONFIRM.hide()
	resort()

func delete(which):
	if which in dataStore:
		var box = dataStore[which]
		box.queue_free()
		dataStore.erase(which)
		resort()

func rename(old,new):
	if old in dataStore:
		var ov = dataStore[old]
		ov.boxname = new
		dataStore.erase(old)
		dataStore[new] = ov
		resort()

func resort():
	for i in LIST.get_children():
		LIST.remove_child(i)
	for r in dataStore:
		var i = dataStore[r]
		if is_instance_valid(i) and not i.is_queued_for_deletion():
			LIST.add_child(i)
	has_changed()
	recalculate()

func _draw():
	recalculate()

func get_list():
	var objList = []
	for i in dataStore:
		objList.append(dataStore[i])
	return objList

const page_size = 10
var current_page = 0
func recalculate():
	var size = dataStore.size()
	if LIST and LIST.is_visible_in_tree():
		var objList = get_list()
		ENTRY.value = size
		var offset = (current_page * page_size)
		var max_pages = int(ceil(float(size)/float(page_size))) - 1
		for iv in objList:
			iv.visible = false
		if size > page_size:
			for iv in clamp(size - offset,0,page_size):
				objList[iv + offset].visible = true
			PAGE.get_parent().visible = true
		else:
			for iv in objList:
				iv.visible = true
			PAGE.get_parent().visible = false
			current_page = 0
		PAGE.value = current_page
	else:
		current_page = 0
	

func _size_value_changed(how:float):
	how = int(how)
	var objList = get_list()
	var sz = objList.size()
	if how != sz:
		if how < sz and sz > 0:
			objList[sz - 1].DELETE()
		elif how > sz and not "TAG_EXAMPLE" in dataStore:
			add("TAG_EXAMPLE")
	recalculate()

func _page_value_changed(how:float):
	how = int(how)
	if how != current_page:
		var size = dataStore.size()
		var offset = (current_page * page_size)
		var max_pages = int(ceil(float(size)/float(page_size))) - 1
		if how < current_page and current_page > 0:
			current_page -= 1
		elif how > current_page:
			if current_page < max_pages:
				current_page += 1
	recalculate()

const BUILTIN_TAGS = {
	"TAG_ALLOW_ACHIEVEMENTS":["bool",false,"Whether the mod would permit achievements.\nNot currently functional in-game."],
	"TAG_QOL":["bool",false,"Whether the mod adds QOL features."],
	"TAG_OVERHAUL":["bool",false,"Whether the mod overhauls a part or parts of the game."],
	"TAG_VISUAL":["bool",false,"Whether the mod makes visual adjustments."],
	"TAG_FUN":["bool",false,"Whether the mod is more fun than serious."],
	"TAG_UI":["bool",false,"Whether the mod adds UI elements."],
	"TAG_ADDS_SHIPS":["Array",PoolStringArray(),"Names of ships that the mod adds.\nCan use translation strings."],
	"TAG_ADDS_EQUIPMENT":["Array",PoolStringArray(),"Names of equipment that the mod adds.\nCan use translation strings."],
	"TAG_ADDS_GAMEPLAY_MECHANICS":["Array",PoolStringArray(),"Names of gameplay mechanics that the mod adds.\nCan use translation strings."],
	"TAG_ADDS_EVENTS":["Array",PoolStringArray(),"Names of events that the mod adds.\nCan use translation strings."],
	"TAG_HANDLE_EXTRA_CREW":["int",24,"For ships with very large numbers of crew, prevents derelict dialogue\nbeing broken if the crew count exceeds what the dialogue can handle.\n\nHevLib automatically sets this to 24, so only does anything above that."],
#	"TAG_USING_HEVLIB_RESEARCH":["array",[],""],
}
