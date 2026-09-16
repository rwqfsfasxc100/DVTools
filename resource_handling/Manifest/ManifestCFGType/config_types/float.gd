tool
extends VBoxContainer

const type = "float"
var boxname = ""

func get_data() -> Dictionary:
	var out = {}
	var nm = $name/property_editor.get_property_value()[0]
	var dc = $description/property_editor.get_property_value()[0]
	var df = $default/property_editor.get_property_value()[0]
	var mn = $min/property_editor.get_property_value()[0]
	var mx = $max/property_editor.get_property_value()[0]
	var sp = $step/property_editor.get_property_value()[0]
	var st = get_style_val()
	var rb = $requires_bools/property_editor.get_property_value()[0]
	var ibr = $invert_bool_requirement/property_editor.get_property_value()[0]
	var rr = $require_restart/property_editor.get_property_value()[0]
	var db = $disabled/property_editor.get_property_value()[0]
	if nm:out["name"] = nm
	if dc:out["description"] = dc
	out["default"] = df
	if mn:out["min"] = mn
	if mx:out["max"] = mx
	if sp:out["step"] = sp
	if st:out["style"] = st
	if rb:out["requires_bools"] = rb
	if ibr:out["invert_bool_requirement"] = ibr
	if rr:out["require_restart"] = rr
	if db:out["disabled"] = db
	return out

func set_data(STATE:Dictionary):
	$name/property_editor.set_property_value(STATE.get("name","INTFLOAT_MISSING_NAME"))
	$description/property_editor.set_property_value(STATE.get("description",""))
	$default/property_editor.set_property_value(STATE.get("default",10.0))
	$min/property_editor.set_property_value(STATE.get("min",0.0))
	$max/property_editor.set_property_value(STATE.get("max",10.0))
	$step/property_editor.set_property_value(STATE.get("step",1.0))
	set_style_val(STATE.get("style","slider"))
	$requires_bools/property_editor.set_property_value(STATE.get("requires_bools",PoolStringArray()))
	$invert_bool_requirement/property_editor.set_property_value(STATE.get("invert_bool_requirement",false))
	$require_restart/property_editor.set_property_value(STATE.get("require_restart",false))
	$disabled/property_editor.set_property_value(STATE.get("disabled",false))

var styles = PoolStringArray(["slider","spinbox"])
func _ready():
	$style/property_editor.clear()
	for i in styles:
		$style/property_editor.add_item(i)
	$style/property_editor.select(0)

func get_style_val():
	return styles[$style/property_editor.selected]

func set_style_val(how:String):
	$style/property_editor.clear()
	for i in styles:
		$style/property_editor.add_item(i)
	if how in styles:
		$style/property_editor.select(styles.find(how))
	else:
		$style/property_editor.select(0)

func connect_all(to):
	for i in get_children():
		var r = i.get_node("property_editor")
		r.connect("changed",to,"changed")
		if "emit_update_signal" in r:
			r.emit_update_signal = true
