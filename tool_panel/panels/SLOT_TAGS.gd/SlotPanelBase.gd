tool
extends VBoxContainer

var slot_node_name = ""
var init_data = {}

var panel = null
var can_mark_unsaved = false

func _enter_tree():
	$CONTENT/VBoxContainer/override_additive/tag_handler.parent_container = panel
	$CONTENT/VBoxContainer/override_subtractive/tag_handler.parent_container = panel

func _ready():
	var lv = $CONTENT/VBoxContainer
	$TOGGLE.text = slot_node_name
	$TOGGLE.connect("pressed",self,"toggle_vis")
	lv.get_node("override_additive/tag_handler").thisTagName = slot_node_name
	lv.get_node("override_subtractive/tag_handler").thisTagName = slot_node_name
	load_data(lv)
	yield(get_tree().create_timer(0.1),"timeout")
	if panel:
		lv.get_node("override_additive/tag_handler").connect("changed",self,"make_changed")
		lv.get_node("override_subtractive/tag_handler").connect("changed",self,"make_changed")
		lv.get_node("limit_ships/poolstringarray").connect("changed",self,"make_changed")
		lv.get_node("prevent_ships/poolstringarray").connect("changed",self,"make_changed")
	yield(get_tree().create_timer(0.05),"timeout")
	can_mark_unsaved = true


func make_changed():
	if panel and can_mark_unsaved:
		panel.needs_save = true

func load_data(lv:Node):
	if "override_additive" in init_data:
		lv.get_node("override_additive/tag_handler").set_property_value(PoolStringArray(init_data.get("override_additive",[])))
	if "override_subtractive" in init_data:
		lv.get_node("override_subtractive/tag_handler").set_property_value(PoolStringArray(init_data.get("override_subtractive",[])))
	if "limit_ships" in init_data:
		lv.get_node("limit_ships/poolstringarray").set_property_value(PoolStringArray(init_data.get("limit_ships",[])))
	if "prevent_ships" in init_data:
		lv.get_node("prevent_ships/poolstringarray").set_property_value(PoolStringArray(init_data.get("prevent_ships",[])))

func get_data():
	var lv = $CONTENT/VBoxContainer
	var out = {}
	var override_additive = Array(lv.get_node("override_additive/tag_handler").get_property_value()[0][slot_node_name])
	var override_subtractive = Array(lv.get_node("override_subtractive/tag_handler").get_property_value()[0][slot_node_name])
	var limit_ships = Array(lv.get_node("limit_ships/poolstringarray").get_property_value()[0])
	var prevent_ships = Array(lv.get_node("prevent_ships/poolstringarray").get_property_value()[0])
	if override_additive:
		out["override_additive"] = override_additive
	if override_subtractive:
		out["override_subtractive"] = override_subtractive
	if limit_ships:
		out["limit_ships"] = limit_ships
	if prevent_ships:
		out["prevent_ships"] = prevent_ships
	return out


func toggle_vis():
	var c = $CONTENT
	c.visible = !c.visible
