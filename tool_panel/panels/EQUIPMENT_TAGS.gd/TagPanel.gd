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
extends "res://addons/DVTools/tool_panel/panels/PanelBase.gd"

onready var lc = get_node("ScrollContainer/VBoxContainer")

var can_mark_unsaved = false
func _ready():
	if not this_script_path.begins_with("new://"):
		var data = __get_script_constant_map_without_load(this_script_path).get("EQUIPMENT_TAGS",{})
		set_properties_from_dict(data)
	yield(get_tree().create_timer(0.1),"timeout")
	lc.get_node("slot_types/property_editor").connect("changed",self,"mark_for_saving")
	lc.get_node("equipment_types/property_editor").connect("changed",self,"mark_for_saving")
	lc.get_node("hardpoint_types/property_editor").connect("changed",self,"mark_for_saving")
	lc.get_node("alignments/property_editor").connect("changed",self,"mark_for_saving")
	lc.get_node("slot_defaults/default_handler").connect("changed",self,"mark_for_saving")
	yield(get_tree().create_timer(0.05),"timeout")
	can_mark_unsaved = true

func mark_for_saving():
	needs_save = true

func save_driver_data() -> String:
	needs_save = false
	return convert_to_constant(get_these_tags(),"EQUIPMENT_TAGS")

func update_available_tags():
	if container_panel:
		fetch_tags()

var slot_types:Array = []
var equipment_types:Array = []
var alignments:Array = []
var hardpoint_types:Array = []
var slot_defaults:Dictionary = {}

func fetch_tags():
	var vanilla_tags = __get_script_constant_map_without_load("res://HevLib/scenes/equipment/vanilla_defaults/slot_tagging.gd")
	slot_types = vanilla_tags.get("slot_types",[])
	equipment_types = vanilla_tags.get("equipment_types",[])
	alignments = vanilla_tags.get("alignments",[])
	hardpoint_types = vanilla_tags.get("hardpoint_types",[])
	slot_defaults = vanilla_tags.get("slot_defaults",{})
	for tag in fetch_data_from_all_drivers("EQUIPMENT_TAGS.gd"):
		if tag == this_script_path:
			var SlotTypes = $ScrollContainer/VBoxContainer/slot_types/property_editor.get_property_value()[0]
			var EquipmentTypes = $ScrollContainer/VBoxContainer/equipment_types/property_editor.get_property_value()[0]
			var HardpointTypes = $ScrollContainer/VBoxContainer/hardpoint_types/property_editor.get_property_value()[0]
			var AlignmentDefs = $ScrollContainer/VBoxContainer/alignments/property_editor.get_property_value()[0]
			var SlotDefaults:Dictionary = $ScrollContainer/VBoxContainer/slot_defaults/default_handler.get_property_value()[0]
			for st in SlotTypes:
				if st and not st in slot_types:
					slot_types.append(st)
			for st in EquipmentTypes:
				if st and not st in equipment_types:
					equipment_types.append(st)
			for st in AlignmentDefs:
				if st and not st in alignments:
					alignments.append(st)
			for st in HardpointTypes:
				if st and not st in hardpoint_types:
					hardpoint_types.append(st)
			for st in SlotDefaults:
				if st in slot_defaults:
					for item in SlotDefaults[st]:
						if not item in slot_defaults[st]:
							slot_defaults[st].append(item)
				else:
					slot_defaults[st] = SlotDefaults[st]
			continue
		var nodes = __get_script_constant_map_without_load(tag).get("EQUIPMENT_TAGS",{})
		var slotTypes : Array = nodes.get("slot_types",[])
		var equipmentItems : Array = nodes.get("equipment_types",[])
		var AL : Array = nodes.get("alignments",[])
		var hardpointTypes : Array = nodes.get("hardpoint_types",[])
		var slotDefaults : Dictionary = nodes.get("slot_defaults",{})
		if slotTypes:
			for st in slotTypes:
				if not st in slot_types:
					slot_types.append(st)
		if equipmentItems:
			for st in equipmentItems:
				if not st in equipment_types:
					equipment_types.append(st)
		if AL:
			for st in AL:
				if not st in alignments:
					alignments.append(st)
		if hardpointTypes:
			for st in hardpointTypes:
				if not st in hardpoint_types:
					hardpoint_types.append(st)
		if slotDefaults:
			for st in slotDefaults:
				if st in slot_defaults:
					for item in slotDefaults[st]:
						if not item in slot_defaults[st]:
							slot_defaults[st].append(item)
				else:
					slot_defaults[st] = slotDefaults[st]

func get_these_tags() -> Dictionary:
	if not lc:
		lc = get_node("ScrollContainer/VBoxContainer")
	var out = {
		"slot_types":[],
		"equipment_types":[],
		"alignments":[],
		"hardpoint_types":[],
		"slot_defaults":{}
	}
	out["slot_types"].append_array(lc.get_node("slot_types/property_editor").get_property_value()[0])
	out["equipment_types"].append_array(lc.get_node("equipment_types/property_editor").get_property_value()[0])
	out["alignments"].append_array(lc.get_node("alignments/property_editor").get_property_value()[0])
	out["hardpoint_types"].append_array(lc.get_node("hardpoint_types/property_editor").get_property_value()[0])
	out["slot_defaults"].merge(lc.get_node("slot_defaults/default_handler").get_property_value()[0])
	return out

func set_properties_from_dict(dict:Dictionary):
	if not lc:
		lc = get_node("ScrollContainer/VBoxContainer")
	lc.get_node("slot_types/property_editor").set_property_value(PoolStringArray(dict.get("slot_types",[])))
	lc.get_node("equipment_types/property_editor").set_property_value(PoolStringArray(dict.get("equipment_types",[])))
	lc.get_node("alignments/property_editor").set_property_value(PoolStringArray(dict.get("alignments",[])))
	lc.get_node("hardpoint_types/property_editor").set_property_value(PoolStringArray(dict.get("hardpoint_types",[])))
	lc.get_node("slot_defaults/default_handler").set_property_value(dict.get("slot_defaults",{}))

