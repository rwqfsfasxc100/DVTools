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
extends "res://addons/DVTools/tool_panel/panels/PanelBase.gd"

var panel = self

var can_mark_unsaved = false
func _ready():
	get_equipment_tags()
	$VBoxContainer/ADD.connect("pressed",self,"show_add_panel")
	$ConfirmationDialog.connect("confirmed",self,"create_item")
	$ConfirmationDialog/VBoxContainer/HBoxContainer/OptionButton.connect("item_selected",self,"select_opt")
	$ConfirmationDialog/VBoxContainer/HBoxContainer/LineEdit.text = ""
	if not this_script_path.begins_with("new://"):
		var data = __get_script_constant_map_without_load(this_script_path).get("SLOT_TAGS",{})
		for i in data:
			create_item(i,data.get(i))
	can_mark_unsaved = true

var equipment_types:Array = []

func get_equipment_tags():
	var vanilla_tags = __get_script_constant_map_without_load("res://HevLib/scenes/equipment/vanilla_defaults/slot_tagging.gd")
	equipment_types = vanilla_tags.get("equipment_types",[])
	for tag in fetch_data_from_all_drivers("EQUIPMENT_TAGS.gd"):
		for st in __get_script_constant_map_without_load(tag).get("EQUIPMENT_TAGS",{}).get("equipment_types",[]):
			if not st in equipment_types:
				equipment_types.append(st)

func save_driver_data() -> String:
	needs_save = false
	return convert_to_constant(get_data(),"SLOT_TAGS")

func get_data():
	var out = {}
	for i in $VBoxContainer/ScrollContainer/VBoxContainer.get_children():
		if "slot_node_name" in i and i.slot_node_name:
			out[i.slot_node_name] = i.get_data()
	return out

func curate_tags(tags:Array) -> Array:
	var out:Array = Array()
	for i in tags:
		if i.get_file() == "ADD_EQUIPMENT_SLOTS.gd":
			out.append(i)
	return out

var node_names:Array = Array()
func fetch_tags():
	node_names.clear()
	node_names = __get_script_constant_map_without_load("res://HevLib/scenes/equipment/vanilla_defaults/slot_tagging.gd").vanilla_equipment_defaults_for_reference.keys()
	for tag in fetch_data_from_all_drivers("ADD_EQUIPMENT_SLOTS.gd"):
		var items:Dictionary = __get_script_constant_map_without_load(tag)
		for i in items:
			var id = items[i]
			if "slot_node_name" in id:
				var snn = id.slot_node_name
				if snn and not snn in node_names:
					node_names.append(snn)

var available_opts = []
func show_add_panel():
	var c = $ConfirmationDialog
	var le = $ConfirmationDialog/VBoxContainer/HBoxContainer/LineEdit
	var opt = $ConfirmationDialog/VBoxContainer/HBoxContainer/OptionButton
	opt.clear()
	fetch_tags()
	available_opts.clear()
	var current = get_current_nodes()
	for i in node_names:
		if not i in current:
			available_opts.append(i)
	for i in available_opts:
		opt.add_item(i)
	opt.select(0)
	le.text = available_opts[0]
	c.popup_centered()

func get_current_nodes():
	var out = []
	for i in $VBoxContainer/ScrollContainer/VBoxContainer.get_children():
		if "slot_node_name" in i and i.slot_node_name:
			out.append(i.slot_node_name)
	return out

func select_opt(idx:int):
	$ConfirmationDialog/VBoxContainer/HBoxContainer/LineEdit.text = available_opts[idx]

var slot_base = load("res://addons/DVTools/tool_panel/panels/SLOT_TAGS.gd/SlotPanelBase.tscn")
func create_item(item_name:String = "",data:Dictionary = {}):
	if item_name.empty():
		item_name = $ConfirmationDialog/VBoxContainer/HBoxContainer/LineEdit.text
	var slot = slot_base.instance()
	slot.panel = self
	slot.slot_node_name = item_name
	slot.init_data = data.duplicate(true)
	$VBoxContainer/ScrollContainer/VBoxContainer.add_child(slot)
