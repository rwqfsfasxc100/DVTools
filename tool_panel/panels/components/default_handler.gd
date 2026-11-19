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

export (bool) var emit_update_signal = false

signal changed()

func get_property_value():
	var value = {}
	var string = ""
	match tag_type:
		"slot_and_hardpoint_tags":
			for i in get_list():
				value.merge(i.get_property_value()[0])
		"equipment_tags":
			var list = []
			for i in get_list():
				list.append(i.get_property_value()[0])
			value = {thisTagName:list}
	return [value,string]

var parent_container = null
var thisTagName = ""

func set_property_value(property):
	match tag_type:
		"slot_and_hardpoint_tags":
			if property is Dictionary:
				for i in property:
					self.currently_selected = i
					var btn = _add_entry()
					if btn:
						btn.set_property_value(property[i])
					self.currently_selected = ""
		"equipment_tags":
			if property is String:
				thisTagName = property
			elif property is Array or property is PoolStringArray:
				for i in property:
					self.currently_selected = i
					_add_entry()
					self.currently_selected = ""
	queue_recalc()

export var toggle_text = "Slot Defaults (size %d)"

export (String,"slot_and_hardpoint_tags","equipment_tags") var tag_type = "slot_and_hardpoint_tags"

var equipment_tag_container = load("res://addons/DVTools/tool_panel/panels/EQUIPMENT_TAGS.gd/tag_container.tscn")
var slot_tag_container = load("res://addons/DVTools/tool_panel/panels/EQUIPMENT_TAGS.gd/equipment_tag_handler.tscn")

func _ready():
	$Collapsable.visible = false
	if not $Toggle/Button.is_connected("toggled",self,"_toggle_collapsed"):
		$Toggle/Button.connect("toggled",self,"_toggle_collapsed")
	match tag_type:
		"slot_and_hardpoint_tags":
			$Toggle/Button.text = toggle_text % 0
		"equipment_tags":
			$Toggle/Button.text = toggle_text % [thisTagName,0]
	if not $Collapsable/NEW/VBoxContainer/H/Add.is_connected("pressed",self,"_add_entry"):
		$Collapsable/NEW/VBoxContainer/H/Add.connect("pressed",self,"_add_entry")
	if not $Collapsable/Info/VBoxContainer/PAGE.is_connected("value_changed",self,"_page_value_changed"):
		$Collapsable/Info/VBoxContainer/PAGE.connect("value_changed",self,"_page_value_changed")
	if not $Collapsable/NEW/VBoxContainer/OPT/OptionButton.is_connected("item_selected",self,"_addopt_selected"):
		$Collapsable/NEW/VBoxContainer/OPT/OptionButton.connect("item_selected",self,"_addopt_selected")
	if parent_container:
		panel = parent_container.panel
	var del = get_node_or_null("Toggle/DELETE")
	var cfr = get_node_or_null("ConfirmationDialog")
	if del and not del.is_connected("pressed",self,"_on_delete"):
		del.connect("pressed",self,"_on_delete")
	if cfr and not cfr.is_connected("confirmed",self,"_do_delete"):
		cfr.connect("confirmed",self,"_do_delete")
	connect("visibility_changed",self,"recalculate")
	recalculate()

func _on_changed():
	if emit_update_signal:
		emit_signal("changed")

func _toggle_collapsed(how:bool):
	var stream = StreamTexture.new()
	if how:stream.load_path = "res://addons/DVTools/property_editor/icons/expanded.stex"
	else:stream.load_path = "res://addons/DVTools/property_editor/icons/collapsed.stex"
	$Toggle/Button.icon = stream
	$Collapsable.visible = how
	recalculate()

func _add_entry():
	var cv = null
	if currently_selected:
		var items = []
		for i in get_list():
			items.append(i.get_property_value()[0])
		if currently_selected in items:
			return
		match tag_type:
			"slot_and_hardpoint_tags":
				cv = slot_tag_container.instance()
				cv.connect("changed",self,"_on_changed")
				cv.set_property_value(currently_selected)
				cv.parent_container = self
				cv.emit_update_signal = emit_update_signal
				$Collapsable/Buffer/List.add_child(cv)
				_on_changed()
			"equipment_tags":
				cv = equipment_tag_container.instance()
				cv.set_property_value(currently_selected)
				cv.parent_container = self
				cv.emit_update_signal = emit_update_signal
				$Collapsable/Buffer/List.add_child(cv)
				_on_changed()
#		$Collapsable/NEW/VBoxContainer/Key/property_editor.set_property_value(null)
#		$Collapsable/NEW/VBoxContainer/Value/property_editor.set_property_value(null)
		recalculate()
	if panel and panel.can_mark_unsaved:
		panel.needs_save = true
	return cv

const page_size = 20
var current_page = 0

func get_list():
	var out = []
	for i in $Collapsable/Buffer/List.get_children():
		if is_instance_valid(i) and not i.is_queued_for_deletion():
			out.append(i)
	return out

export var panel_path = NodePath("../../../..")
onready var panel = get_node_or_null(panel_path)

var currently_selected:String = "" setget _set_curr , _get_curr
var available_selections:Array = Array()

func _set_curr(how:String):
	$Collapsable/NEW/VBoxContainer/OPT/LineEdit.text = currently_selected
	currently_selected = how
	if panel and panel.can_mark_unsaved:
		panel.needs_save = true
func _get_curr():
	currently_selected = $Collapsable/NEW/VBoxContainer/OPT/LineEdit.text
	return currently_selected

func _addopt_selected(how:int):
	var sz = available_selections.size()
	if sz > how:
		self.currently_selected = available_selections[how]
	else:
		self.currently_selected = ""
	$Collapsable/NEW/VBoxContainer/OPT/LineEdit.text = currently_selected
	if panel and panel.can_mark_unsaved:
		panel.needs_save = true

func get_available_equipment_tags() -> Array:
	var out = [""]
	if panel:
		if panel.has_method("update_available_tags"):
			panel.update_available_tags()
		match tag_type:
			"slot_and_hardpoint_tags":
				if "slot_types" in panel:
					var nr = panel.slot_types
					if "HARDPOINT" in nr and "hardpoint_types" in panel:
						nr.erase("HARDPOINT")
						var hp = panel.hardpoint_types
						out.append_array(hp)
					out.append_array(nr)
			"equipment_tags":
				if "equipment_types" in panel:
					var et = panel.equipment_types
					out.append_array(et)
	for i in get_list():
		if i.has_method("get_property_value"):
			var this = i.get_property_value()[0]
			for t in this:
				if t in out:
					out.erase(t)
	return out

var queue_timer = 0.0
func queue_recalc():
	queue_timer = 0.25

func _physics_process(delta):
	if queue_timer > 0.0:
		queue_timer -= delta
		if queue_timer <= 0.0:
			recalculate()

var objList = []
func recalculate():
	if is_visible_in_tree():
		objList = get_list()
		for i in objList:
			i.visible = false
		var size = objList.size()
		match tag_type:
			"slot_and_hardpoint_tags":
				$Toggle/Button.text = toggle_text % size
			"equipment_tags":
				$Toggle/Button.text = toggle_text % [thisTagName,size]
		$Collapsable/Info/VBoxContainer/SIZE.value = size
		if $Collapsable/Buffer/List.is_visible_in_tree():
			var offset = (current_page * page_size)
			var max_pages = int(ceil(float(size)/float(page_size))) - 1
			if size > page_size:
				for iv in clamp(size - offset,0,page_size):
					objList[iv + offset].visible = true
				$Collapsable/Info/VBoxContainer/PAGE.visible = true
			else:
				for iv in objList:
					iv.visible = true
				$Collapsable/Info/VBoxContainer/PAGE.visible = false
				current_page = 0
			$Collapsable/Info/VBoxContainer/PAGE.value = current_page
	else:
		current_page = 0
	var opt = $Collapsable/NEW/VBoxContainer/OPT/OptionButton
	if opt.is_visible_in_tree():
		opt.clear()
		available_selections = get_available_equipment_tags()
		for i in available_selections:
			opt.add_item(i)
		opt.select(0)
		self.currently_selected = ""
		$Collapsable/NEW/VBoxContainer/OPT/LineEdit.text = currently_selected
	

func _page_value_changed(how:float):
	how = int(how)
	if how != current_page:
		var size = objList.size()
		var offset = (current_page * page_size)
		var max_pages = int(ceil(float(size)/float(page_size))) - 1
		if how < current_page and current_page > 0:
			current_page -= 1
		elif how > current_page:
			if current_page < max_pages:
				current_page += 1
	recalculate()
#
#func _draw():
#	recalculate()

func _on_delete():
	$ConfirmationDialog.popup_centered()

func _do_delete():
	queue_free()
	_on_changed()
	if parent_container:
		parent_container.recalculate()
