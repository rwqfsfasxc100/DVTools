tool
extends VBoxContainer

const type = "display"
var boxname = ""

func get_data() -> Dictionary:
	var out = {}
	var sc = $scene_path/property_editor.get_property_value()[0]
	var lm = $left_margin/property_editor.get_property_value()[0]
	var rm = $right_margin/property_editor.get_property_value()[0]
	var db = $disabled/property_editor.get_property_value()[0]
	if sc:out["scene_path"] = sc
	if lm != 15:out["left_margin"] = lm
	if rm != 15:out["right_margin"] = rm
	if db:out["disabled"] = db
	return out

func set_data(STATE:Dictionary):
	$scene_path/property_editor.set_property_value(STATE.get("scene_path",""))
	$left_margin/property_editor.set_property_value(STATE.get("left_margin",15))
	$right_margin/property_editor.set_property_value(STATE.get("right_margin",15))
	$disabled/property_editor.set_property_value(STATE.get("disabled",false))

func connect_all(to):
	for i in get_children():
		var r = i.get_node("property_editor")
		r.connect("changed",to,"changed")
		if "emit_update_signal" in r:
			r.emit_update_signal = true
