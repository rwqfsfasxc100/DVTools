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

onready var TOGGLE = $BOX/BUTTONS/TOGGLE
onready var RENAME = $BOX/BUTTONS/RENAME
onready var DELETE = $BOX/BUTTONS/DELETE
onready var DELETEMENU = $DoDelete
onready var CONTENT = $BOX/CONTENT
onready var URL = $BOX/CONTENT/URL/LineEdit
onready var ICON = $BOX/CONTENT/ICON/LineEdit
onready var DIROPEN = $BOX/CONTENT/ICON/DIR
onready var DIRMENU = EditorFileDialog.new()
onready var TOOLTIP = $BOX/CONTENT/TOOLTIP/LineEdit
onready var RENAMEBOX = $RenameTo
onready var RENAMEEDIT = $RenameTo/LineEdit

var toggled = false

var boxname = ""

var deleteformat = ""

var CONTAINER

var initial_state = {}

func _ready():
	deleteformat = DELETEMENU.dialog_text
	add_child(DIRMENU)
	DIRMENU.mode = EditorFileDialog.MODE_OPEN_FILE
	DIRMENU.add_filter("*.stex, *.png ; Supported icon image files")
	DIRMENU.show_hidden_files = true
	DIRMENU.rect_min_size = get_viewport().size - Vector2(200,200)
	TOGGLE.connect("pressed",self,"_toggle_pressed")
	DIROPEN.connect("pressed",self,"_open_dir")
	DIRMENU.connect("file_selected",self,"_icon_file_selected")
	DELETE.connect("pressed",self,"_on_delete")
	DELETEMENU.connect("confirmed",self,"DELETE")
	TOGGLE.text = boxname
	if "URL" in initial_state:
		URL.text = initial_state["URL"]
	if "ICON" in initial_state:
		ICON.text = initial_state["ICON"]
	if "TOOLTIP" in initial_state:
		TOOLTIP.text = initial_state["TOOLTIP"]
	RENAME.connect("pressed",self,"_on_rename")
	RENAMEBOX.connect("confirmed",self,"RENAME_CONFIRMED")
	URL.connect("text_changed",self,"changed")
	ICON.connect("text_changed",self,"changed")
	TOOLTIP.connect("text_changed",self,"changed")

func changed(how = null):
	if CONTAINER:
		CONTAINER.has_changed()


func _open_dir():
	DIRMENU.popup_centered()

func _icon_file_selected(how):
	ICON.text = how

func get_data():
	var UTXT = $BOX/CONTENT/URL/LineEdit.text
	var ITXT = $BOX/CONTENT/ICON/LineEdit.text
	var TTXT = $BOX/CONTENT/TOOLTIP/LineEdit.text
	var out = {}
	if UTXT:
		out["URL"] = UTXT
		if ITXT:
			out["ICON"] = ITXT
		if TTXT:
			out["TOOLTIP"] = TTXT
	return out

func _toggle_pressed():
	toggled = !toggled
	update()

func _on_delete():
	DELETEMENU.dialog_text = deleteformat % boxname
	DELETEMENU.popup_centered()

func DELETE():
	if CONTAINER:
		CONTAINER.delete(boxname)

func _on_rename():
	RENAMEEDIT.text = boxname
	RENAMEEDIT.caret_position = boxname.length()
	RENAMEBOX.popup_centered()
	RENAMEEDIT.grab_focus()

func RENAME_CONFIRMED():
	if CONTAINER:
		var newname = RENAMEEDIT.text
		if newname:
			if newname != boxname:
				CONTAINER.rename(boxname,newname)
			RENAMEBOX.hide()

func _draw():
	if CONTENT:
		CONTENT.visible = toggled
		TOGGLE.text = boxname
