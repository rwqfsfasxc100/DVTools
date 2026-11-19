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
extends ConfirmationDialog

export (NodePath) var settings_button_path = NodePath("../VBoxContainer/Menu/ToggleModlets")
onready var settings_button = get_node_or_null(settings_button_path)
export (NodePath) var tool_panel_path = NodePath("..")
onready var tool_panel = get_node_or_null(tool_panel_path)

onready var list = $PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer

func _ready():
	if tool_panel and settings_button:
		settings_button.connect("pressed",self,"show")
		connect("confirmed",self,"saveSettings")

func show():
	loadCurrentConfigs()
	popup_centered()

var file:File = File.new()
var config_path:String = "user://cfg/Mod_Configurations.cfg"
var modlets_in_fs:Dictionary = {}

func loadCurrentConfigs():
	for i in list.get_children():
		list.remove_child(i)
		i.queue_free()
	modlets_in_fs.clear()
	if file.file_exists(config_path):
		var cfg = ConfigFile.new()
		cfg.load(config_path)
		if cfg.has_section("HevLib/modlets") and cfg.has_section_key("HevLib/modlets","seen_modlets"):
			var all_modlets = cfg.get_value("HevLib/modlets","seen_modlets")
			for modlet in all_modlets:
				if file.file_exists(modlet):
					modlets_in_fs[modlet] = all_modlets[modlet]
	for modlet in modlets_in_fs:
		var button = load("res://addons/DVTools/tool_panel/toggle_modlets/ModletToggle.tscn").instance()
		button.modlet_path = modlet
		button.pressed = modlets_in_fs[modlet]
		list.add_child(button)

func saveSettings():
	for button in list.get_children():
		var path = button.modlet_path
		if path:
			modlets_in_fs[path] = button.pressed
	var cfg = ConfigFile.new()
	cfg.load(config_path)
	cfg.set_value("HevLib/modlets","seen_modlets",modlets_in_fs)
	cfg.save(config_path)
