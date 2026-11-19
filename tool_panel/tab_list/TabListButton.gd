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
extends MarginContainer

signal pressed

var container

var script_path:String = ""

onready var label = $HBoxContainer/Label
onready var display_button = $DisplayButton
onready var press_button = $PressButton
onready var close_button = $HBoxContainer/CloseButton
onready var confirm_close = $ConfirmationDialog

var confirm_format = ""

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if press_button.get_rect().has_point(event.position - press_button.get_global_transform_with_canvas().get_origin()):
#			if event.button_index == BUTTON_LEFT:
#				_on_selected()
			if event.button_index == BUTTON_MIDDLE:
				_on_close()

func _ready():
	press_button.connect("pressed",self,"_on_selected")
	close_button.connect("pressed",self,"_on_close")
	display_button.set_physics_process(false)
	display_button.set_process(false)
	confirm_close.add_button("Don't save",true,"dont_save")
	confirm_close.get_ok().text = "Save & Close"
	confirm_close.connect("confirmed",self,"save_and_close")
	confirm_close.connect("custom_action",self,"cws")
	confirm_format = confirm_close.dialog_text
	if container:
		container.connect("save_confirmed",self,"save_confirmed")

func SAVE():
	if container and container.has_method("SAVE"):
		container.SAVE()

func _on_selected():
	emit_signal("pressed")

func set_text(text:String):
	label.text = text

func cws(how):
	close_without_saving()

func _on_close():
	if container.tabs[script_path].needs_save:
		confirm_close.dialog_text = confirm_format % script_path
		confirm_close.popup_centered()
	else:
		close_without_saving()

var close_after_save = false

func save_and_close():
	SAVE()
	close_after_save = true

func save_confirmed():
	if close_after_save:
		close_without_saving()

func close_without_saving():
	container.remove(script_path)

var is_active_tab = false

func set_active_tab(how:bool):
	is_active_tab = how
	if how:
		container.active_tab = self
	
func _process(_delta):
	if display_button:
		if is_active_tab:
			display_button.self_modulate = Color.gray
		else:
			display_button.self_modulate = Color.white
