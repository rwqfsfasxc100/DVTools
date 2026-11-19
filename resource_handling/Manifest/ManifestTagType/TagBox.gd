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
extends HBoxContainer

onready var TOGGLE = $BOX/BUTTONS/TOGGLE
onready var RENAME = $BOX/BUTTONS/RENAME
onready var DELETE = $BOX/BUTTONS/DELETE
onready var DELETEMENU = $DoDelete
onready var CONTENT = $BOX/CONTENT
onready var RENAMEBOX = $RenameTo
onready var RENAMEEDIT = $RenameTo/LineEdit

var toggled = false

var boxname = ""

var deleteformat = ""

var CONTAINER

var initial_type = null

func _enter_tree():
	if initial_type != null:
		$BOX/CONTENT.initialize(initial_type)

func _ready():
	deleteformat = DELETEMENU.dialog_text
	TOGGLE.connect("pressed",self,"_toggle_pressed")
	DELETE.connect("pressed",self,"_on_delete")
	DELETEMENU.connect("confirmed",self,"DELETE")
	TOGGLE.text = boxname
	RENAME.connect("pressed",self,"_on_rename")
	RENAMEBOX.connect("confirmed",self,"RENAME_CONFIRMED")

func changed(how = null):
	if CONTAINER:
		CONTAINER.has_changed()

func get_data():
	var value = $BOX/CONTENT.get_property_value()[0]
	var out = {
		"value":value,
		"type":property_assignment[typeof(value)].to_lower()
	}
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

const property_assignment = {
	TYPE_NIL:"null",
	TYPE_BOOL:"bool",
	TYPE_INT:"int",
	TYPE_REAL:"float",
	TYPE_STRING:"string",
	TYPE_VECTOR2:"Vector2",
	TYPE_RECT2:"Rect2",
	TYPE_VECTOR3:"Vector3",
	TYPE_TRANSFORM2D:"Transform2D",
	TYPE_COLOR:"Color",
	TYPE_DICTIONARY:"Dictionary",
	TYPE_ARRAY:"Array",
	TYPE_RAW_ARRAY:"PoolByteArray",
	TYPE_INT_ARRAY:"PoolIntArray",
	TYPE_REAL_ARRAY:"PoolRealArray",
	TYPE_STRING_ARRAY:"PoolStringArray",
	TYPE_VECTOR2_ARRAY:"PoolVector2Array",
	TYPE_VECTOR3_ARRAY:"PoolVector3Array",
	TYPE_COLOR_ARRAY:"PoolColorArray",
}
