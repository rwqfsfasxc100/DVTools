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
extends ConfirmationDialog

export (NodePath) var settings_button_path = NodePath("../VBoxContainer/Menu/License")
onready var settings_button = get_node_or_null(settings_button_path)
export (NodePath) var tool_panel_path = NodePath("..")
onready var tool_panel = get_node_or_null(tool_panel_path)

var tab_container

func _ready():
	if tool_panel and settings_button:
		yield(get_tree(),"idle_frame")
		settings_button.connect("pressed",self,"show")
		connect("confirmed",self,"saveSettings")
		tab_container = tool_panel.tab_container

func show():
	rect_min_size = Vector2(200,get_viewport().size.y - 200)
#	yield(get_tree().create_timer(0.2),"timeout")
	if is_tab_valid():
		var panel = tab_container.tabs[tab_container.active_tab.script_path]
		if panel != null and is_instance_valid(panel):
			var license = panel.fetch_license_from_other_drivers()
			$PanelContainer/TextEdit.text = license
			popup_centered()

func is_tab_valid():
	return tab_container.active_tab != null and is_instance_valid(tab_container.active_tab)

func saveSettings():
	if is_tab_valid():
		var panel = tab_container.tabs[tab_container.active_tab.script_path]
		if panel != null and is_instance_valid(panel):
			panel.current_license = $PanelContainer/TextEdit.text
