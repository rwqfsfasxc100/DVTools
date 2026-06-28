tool
extends VBoxContainer

# This tool is to provide an editor-like property editor available from in-game UI
# It's relatively limited, but should work for the most part
# Properties can be set or fetched with the set_property_value(property) and get_property_value() methods respectively.


# If enabled, allows the user to change the property type
export (bool) var can_edit_type = true

# Sets the initial propert type for the box
export (String,"null","bool","int","float","string","Vector2","Rect2","Vector3","Transform2D","Color","Dictionary","Array","PoolByteArray","PoolIntArray","PoolRealArray","PoolStringArray","PoolVector2Array","PoolVector3Array","PoolColorArray") var property_type = "null"

# Defines defaults for each variable type
export (Dictionary) var defaults_for_type = {
	"null":null,
	"bool":false,
	"int":0,
	"float":0.0,
	"string":"",
	"Vector2":Vector2.ZERO,
	"Rect2":Rect2(),
	"Vector3":Vector3.ZERO,
	"Transform2D":Transform2D(),
	"Color":Color.black,
	"Dictionary":{},
	"Array":[],
	"PoolByteArray":PoolByteArray(),
	"PoolIntArray":PoolIntArray(),
	"PoolRealArray":PoolRealArray(),
	"PoolStringArray":PoolStringArray(),
	"PoolVector2Array":PoolVector2Array(),
	"PoolVector3Array":PoolVector3Array(),
	"PoolColorArray":PoolColorArray(),
}

var init_variable = null
var byte_init = false

var selected_property_type = "null"
var property_box = null

func get_property_value():
	if property_box and property_box.has_method("get_property_value"):
		return property_box.get_property_value()

func set_property_value(property):
	_change_property_to(supported_property_types.find(match_property_to_typestring(property)))
	if property_box:
		property_box.set_property_value(property)

func clear():
	_change_property_to(supported_property_types.find("null"))


func initialize(how):
	init_variable = how

onready var edit_button = $box_alignment/EDIT
onready var type_select_popup = $TypeSelect
onready var type_selector = $TypeSelect/PanelContainer/OptionButton
onready var property_container = $box_alignment/property

func _ready():
	edit_button.visible = can_edit_type
	edit_button.connect("pressed",self,"_open_property_selector")
	type_select_popup.connect("confirmed",self,"_change_property_to")
	var lowType = []
	for i in supported_property_types:
		lowType.append(i.to_lower())
	property_type = supported_property_types[lowType.find(property_type.to_lower())]
	_change_property_to(supported_property_types.find(property_type))
	if init_variable != null:
		set_property_value(init_variable)
	$box_alignment/RESET.connect("pressed",self,"reset")

func _open_property_selector():
	type_selector.clear()
	for i in supported_property_types:
		type_selector.add_item(i)
	
	
	type_select_popup.popup_centered()

func _change_property_to(idx : int = -1):
	if idx < 0:
		idx = type_selector.selected
	if idx < 0:
		idx = 0
	var property = supported_property_types[idx]
	if property in property_nodes:
		var node = property_nodes[property].instance()
		property_box = node
		selected_property_type = property
		if property == "int":
			node.bytes = byte_init
		for i in $box_alignment/property.get_children():
			i.queue_free()
		node.set_property_value(defaults_for_type[property_type])
		$box_alignment/property.add_child(node)

func match_property_to_typestring(property) -> String:
	var to = typeof(property)
	if to in property_assignment:
		return property_assignment[to] 
	return "null"

func reset():
	set_property_value(defaults_for_type[property_type])

func _draw():
	if property_box:
		property_box.update()

const supported_property_types = [
	"null",
	"bool",
	"int",
	"float",
	"string",
	"Vector2",
	"Rect2",
	"Vector3",
	"Transform2D",
	"Color",
	"Dictionary",
	"Array",
	"PoolByteArray",
	"PoolIntArray",
	"PoolRealArray",
	"PoolStringArray",
	"PoolVector2Array",
	"PoolVector3Array",
	"PoolColorArray",
]

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

const property_nodes = {
	"null":preload("res://addons/DVTools/property_editor/property_containers/null.tscn"),
	"bool":preload("res://addons/DVTools/property_editor/property_containers/bool.tscn"),
	"int":preload("res://addons/DVTools/property_editor/property_containers/int.tscn"),
	"float":preload("res://addons/DVTools/property_editor/property_containers/float.tscn"),
	"string":preload("res://addons/DVTools/property_editor/property_containers/string.tscn"),
	"Vector2":preload("res://addons/DVTools/property_editor/property_containers/vec2.tscn"),
	"Vector3":preload("res://addons/DVTools/property_editor/property_containers/vec3.tscn"),
	"Rect2":preload("res://addons/DVTools/property_editor/property_containers/rect2.tscn"),
	"Transform2D":preload("res://addons/DVTools/property_editor/property_containers/transform2d.tscn"),
	"Color":preload("res://addons/DVTools/property_editor/property_containers/color.tscn"),
	"Dictionary":preload("res://addons/DVTools/property_editor/property_containers/dict.tscn"),
	"Array":preload("res://addons/DVTools/property_editor/property_containers/array.tscn"),
	"PoolByteArray":preload("res://addons/DVTools/property_editor/property_containers/poolbytearray.tscn"),
	"PoolIntArray":preload("res://addons/DVTools/property_editor/property_containers/poolintarray.tscn"),
	"PoolRealArray":preload("res://addons/DVTools/property_editor/property_containers/poolrealarray.tscn"),
	"PoolStringArray":preload("res://addons/DVTools/property_editor/property_containers/poolstringarray.tscn"),
	"PoolVector2Array":preload("res://addons/DVTools/property_editor/property_containers/poolvector2array.tscn"),
	"PoolVector3Array":preload("res://addons/DVTools/property_editor/property_containers/poolvector3array.tscn"),
	"PoolColorArray":preload("res://addons/DVTools/property_editor/property_containers/poolcolorarray.tscn"),
}
