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
extends HBoxContainer

var panel
var stored_state:Dictionary = {}

onready var mainbutton = $MainButton
onready var deletebutton = $DELETE
onready var confirmation = $ConfirmationDialog

var confirm_format = ""

var saved_hash = 0

func calc_hash():
	var nh = hash(stored_state)
	if saved_hash and panel and saved_hash != nh:
		panel.needs_save = true
	else:
		saved_hash = nh

func _ready():
	orig_state = stored_state
	mainbutton.connect("pressed",self,"_on_pressed")
	deletebutton.connect("pressed",self,"_check_delete")
	confirmation.connect("confirmed",self,"_on_delete")
	confirm_format = confirmation.dialog_text
	_change_system_display()

var orig_state = {}

func _on_pressed():
	if panel and panel.has_method("_safe_open_from_button"):
		panel._safe_open_from_button(self)

func _on_delete():
	if panel and panel.has_method("_delete_this_button"):
		panel._delete_this_button(self)

func _change_system_display():
	if stored_state and "system" in stored_state:
		var sys = stored_state.get("system","SYSTEM_EXAMPLE")
		mainbutton.text = sys
		mainbutton.hint_tooltip = sys

func _check_delete():
	confirmation.dialog_text = confirm_format % stored_state.get("system","SYSTEM_EXAMPLE")
	confirmation.popup_centered()
