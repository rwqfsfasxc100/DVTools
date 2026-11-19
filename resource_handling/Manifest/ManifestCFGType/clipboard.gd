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
extends VBoxContainer

var p:Node

onready var entry_box = get_node_or_null("../../../../..")
onready var section_box = entry_box.get_node_or_null("../../../..")
onready var mod_box = section_box.get_node_or_null("../../..")

var format:Array = ["","",""]

func _ready() -> void:
	reformat()
	var set_button:Button = $CopySetGet/Button
	var get_button:Button = $CopySetGet/Button2
	var sub_button:Button = $CopySubscribe/Button
	var unsub_button:Button = $CopySubscribe/Button2
	
	set_button.connect("pressed",self,"_copy_set")
	get_button.connect("pressed",self,"_copy_get")
	sub_button.connect("pressed",self,"_copy_sub")
	unsub_button.connect("pressed",self,"_copy_unsub")

func reformat():
	format[0] = mod_box.manifest_name
	format[1] = section_box.boxname
	format[2] = entry_box.boxname


func _copy_set():
	reformat()
	OS.set_clipboard(get_set())
func _copy_get():
	reformat()
	OS.set_clipboard(get_get())
func _copy_sub():
	reformat()
	OS.set_clipboard(get_sub())
func _copy_unsub():
	reformat()
	OS.set_clipboard(get_unsub())

func get_set():return "__store_value(\"%s\",\"%s\",\"%s\")" % format
func get_get():return "__get_value(\"%s\",\"%s\",\"%s\")" % format
func get_sub():return "__subscribe_to_setting_change(\"function_name\",null,\"%s\",\"%s\",\"%s\")" % format
func get_unsub():return "__disconnect_subscription(\"function_name\",null,\"%s\",\"%s\",\"%s\")" % format
