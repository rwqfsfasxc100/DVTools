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

onready var slot_order_list = get_node_or_null(NodePath("VBoxContainer/Slot Order/VBoxContainer/ScrollContainer/VBoxContainer"))
onready var slot_order_relative_list = get_node_or_null(NodePath("VBoxContainer/Relative Slot Order/VBoxContainer/ScrollContainer/VBoxContainer"))
onready var slot_order_add = get_node_or_null(NodePath("VBoxContainer/Slot Order/VBoxContainer/Button"))
onready var slot_order_relative_add = get_node_or_null(NodePath("VBoxContainer/Relative Slot Order/VBoxContainer/Button"))

onready var regular_container = load("res://addons/DVTools/tool_panel/panels/SLOT_ORDER.gd/regular_order/RegularOrderEntry.tscn")

func _ready():
	if not this_script_path.begins_with("new://"):
		var data = __get_script_constant_map_without_load(this_script_path)
		
		print(JSON.print(data,"\t"))
	get_available_slot_node_names()






















func get_available_slot_node_names():
	var panel_settings = container_panel.tool_panel.plugin_settings
	var node_names:PoolStringArray = panel_settings.get_upgrades_slots()
	for i in fetch_data_from_all_drivers("ADD_EQUIPMENT_SLOTS.gd"):
		var data:Dictionary = __get_script_constant_map_without_load(i)
		for slot in data:
			var d = data[slot]
			if "slot_node_name" in d:
				node_names.append(d["slot_node_name"])
	print(node_names)
	


