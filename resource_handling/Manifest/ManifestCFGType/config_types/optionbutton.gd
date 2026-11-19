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

const type = "optionbutton"
var boxname = ""

func get_data() -> Dictionary:
	var out = {}
	var nm = $name/property_editor.get_property_value()[0]
	var dc = $description/property_editor.get_property_value()[0]
	var op = $options/property_editor.get_property_value()[0]
	var sm = get_store_method()
	var df = get_default()
	var rb = $requires_bools/property_editor.get_property_value()[0]
	var ibr = $invert_bool_requirement/property_editor.get_property_value()[0]
	var rr = $require_restart/property_editor.get_property_value()[0]
	var db = $disabled/property_editor.get_property_value()[0]
	if nm:out["name"] = nm
	if dc:out["description"] = dc
	out["options"] = op
	out["store_method"] = sm
	out["default"] = df
	if rb:out["requires_bools"] = rb
	if ibr:out["invert_bool_requirement"] = ibr
	if rr:out["require_restart"] = rr
	if db:out["disabled"] = db
	return out

func set_data(STATE:Dictionary):
	$name/property_editor.set_property_value(STATE.get("name","OPTION_MISSING_NAME"))
	$description/property_editor.set_property_value(STATE.get("description",""))
	$options/property_editor.set_property_value(STATE.get("options",PoolStringArray(["EXAMPLE_OPTION"])))
	set_store_method(STATE.get("store_method","int"))
	set_default(STATE.get("default",0))
	$requires_bools/property_editor.set_property_value(STATE.get("requires_bools",PoolStringArray()))
	$invert_bool_requirement/property_editor.set_property_value(STATE.get("invert_bool_requirement",false))
	$require_restart/property_editor.set_property_value(STATE.get("require_restart",false))
	$disabled/property_editor.set_property_value(STATE.get("disabled",false))

var store_methods = PoolStringArray(["int","string"])

func _ready():
	$options/property_editor.connect("draw",self,"_update_default")
	$options/property_editor.connect("changed",self,"_update_default")
	$default/property_editor.connect("pressed",self,"_update_default")
	defaults = []
	$store_method/property_editor.clear()
	for i in store_methods:
		$store_method/property_editor.add_item(i)
	$store_method/property_editor.select(0)

var defaults = []

func _update_default():
	var oldSelection = $default/property_editor.selected
	$default/property_editor.clear()
	defaults = []
	var opts = $options/property_editor.get_property_value()[0]
	if not opts.size():
		opts = PoolStringArray(["EXAMPLE_OPTION"])
		$options/property_editor.set_property_value(opts)
	for i in opts:
		defaults.append(i)
	for i in defaults:
		$default/property_editor.add_item(i)
	if (oldSelection + 1 > defaults.size()) or (oldSelection < 0):
		oldSelection = 0
	$default/property_editor.select(oldSelection)

func get_default():
	var val = $default/property_editor.selected
	if val >= 0:
		match get_store_method():
			"string":
				val = defaults[val]
	else:
		val = 0
	return val

func get_store_method():
	return store_methods[$store_method/property_editor.selected]

func set_default(how):
	if typeof(how) == TYPE_STRING:
		if how in defaults:
			how = defaults.find(how)
		else:
			how = 0
	$default/property_editor.select(how)

func set_store_method(how:String):
	if how in store_methods:
		$store_method/property_editor.select(store_methods.find(how))
	else:
		$store_method/property_editor.select(0)

func connect_all(to):
	for i in get_children():
		var r = i.get_node("property_editor")
		r.connect("changed",to,"changed")
		if "emit_update_signal" in r:
			r.emit_update_signal = true
	add_child(load("res://addons/DVTools/resource_handling/Manifest/ManifestCFGType/clipboard.tscn").instance())
