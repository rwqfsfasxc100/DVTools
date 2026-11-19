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
extends VBoxContainer

signal changed()

func _ready():
	$HB/CONTENT/ADD.connect("pressed",self,"_on_add_open")
	$ConfirmationDialog.connect("confirmed",self,"_add_confirmed")

func get_data():
	var out = []
	for i in $HB/CONTENT/LIST.get_children():
		var data = i.get_data()
		out.append(data)
	return out

func set_data(STATE):
	for i in $HB/CONTENT/LIST.get_children():
		$HB/CONTENT/LIST.remove_child(i)
		i.queue_free()
	for i in Array(STATE):
		match typeof(i):
			TYPE_STRING,TYPE_DICTIONARY:
				add(0,i)
			TYPE_ARRAY,TYPE_STRING_ARRAY:
				add(1,i)
	refresh_title()

func has_changed():
	emit_signal("changed")

func _on_add_open():
	$ConfirmationDialog/VBoxContainer/OptionButton.clear()
	for i in ["Singular mod (only item checked)","Multiple mods (any number can exist to trigger the check)"]:
		$ConfirmationDialog/VBoxContainer/OptionButton.add_item(i)
	$ConfirmationDialog/VBoxContainer/OptionButton.select(0)
	$ConfirmationDialog.popup_centered()
	$ConfirmationDialog/VBoxContainer/OptionButton.grab_focus()

func _add_confirmed():
	add($ConfirmationDialog/VBoxContainer/OptionButton.selected)
	

func add(type:int = 0,data = null):
	var node = null
	match type:
		0:
			node = load("res://addons/DVTools/resource_handling/Manifest/ManifestConflictAndRequirementsType/SingleConflictEntry.tscn").instance()
		1:
			node = load("res://addons/DVTools/resource_handling/Manifest/ManifestConflictAndRequirementsType/MultiConflictEntry.tscn").instance()
	if node != null:
		if data != null and node.has_method("set_data"):
			node.set_data(data)
		$HB/CONTENT/LIST.add_child(node)

func _draw():
	refresh_title()

func refresh_title():
	$TBOX/TOGGLE.text = "Toggle visibility (%d checks)" % $HB/CONTENT/LIST.get_child_count()


func _on_TOGGLE_pressed():
	$HB/CONTENT.visible = !$HB/CONTENT.visible
