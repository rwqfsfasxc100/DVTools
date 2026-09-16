tool
extends VBoxContainer

const type = "action"
var boxname = ""

func get_data() -> Dictionary:
	var out = {}
	var nm = $name/property_editor.get_property_value()[0]
	var dc = $description/property_editor.get_property_value()[0]
	var sc = $script_path/property_editor.get_property_value()[0]
	var bl = $button_label/property_editor.get_property_value()[0]
	var md = $method/property_editor.get_property_value()[0]
	var rb = $requires_bools/property_editor.get_property_value()[0]
	var ibr = $invert_bool_requirement/property_editor.get_property_value()[0]
	var db = $disabled/property_editor.get_property_value()[0]
	if nm:out["name"] = nm
	if dc:out["description"] = dc
	if sc:out["script_path"] = sc
	if bl:out["button_label"] = bl
	if md:out["method"] = md
	if rb:out["requires_bools"] = rb
	if ibr:out["invert_bool_requirement"] = ibr
	if db:out["disabled"] = db
	return out

func set_data(STATE:Dictionary):
	$name/property_editor.set_property_value(STATE.get("name","ACTION_MISSING_NAME"))
	$description/property_editor.set_property_value(STATE.get("description",""))
	$script_path/property_editor.set_property_value(STATE.get("script_path",""))
	$button_label/property_editor.set_property_value(STATE.get("button_label",""))
	$method/property_editor.set_property_value(STATE.get("method","_pressed"))
	$requires_bools/property_editor.set_property_value(STATE.get("requires_bools",PoolStringArray()))
	$invert_bool_requirement/property_editor.set_property_value(STATE.get("invert_bool_requirement",false))
	$disabled/property_editor.set_property_value(STATE.get("disabled",false))

func connect_all(to):
	for i in get_children():
		var r = i.get_node("property_editor")
		r.connect("changed",to,"changed")
		if "emit_update_signal" in r:
			r.emit_update_signal = true
