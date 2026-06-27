tool
extends VBoxContainer

signal changed()

const LinkBox = preload("res://addons/DVTools/resource_handling/Manifest/ManifestLinkType/LinkBox.tscn")

onready var ENTRY = $ENTRY/COUNT
onready var PAGE = $PAGE/COUNT
onready var LIST = $LIST
onready var ADD = $ADD
onready var CONFIRM = $ConfirmationDialog
onready var CONFIRMNAME = $ConfirmationDialog/VBoxContainer/LineEdit
onready var CONFIRMERR = $ConfirmationDialog/VBoxContainer/Label

func _ready():
	ADD.connect("pressed",self,"_on_add_open")
	CONFIRM.connect("confirmed",self,"_add_confirmed")
	ENTRY.connect("value_changed",self,"_size_value_changed")
	PAGE.connect("value_changed",self,"_page_value_changed")

var dataStore = {}

func get_data():
	var out = {}
	for i in dataStore:
		out[i] = dataStore[i].get_data()
	return out

func set_data(STATE):
	for i in dataStore:
		delete(i)
	for i in STATE:
		var sd = STATE[i]
		add(i,sd.get("URL",""),sd.get("ICON",""),sd.get("TOOLTIP",""))

func has_changed():
	emit_signal("changed")

func _on_add_open():
	CONFIRMNAME.text = ""
	CONFIRMERR.visible = false
	CONFIRM.popup_centered()
	CONFIRMNAME.grab_focus()

func _add_confirmed():
	var newname = CONFIRMNAME.text
	if not newname in dataStore:
		add(newname)
	else:
		CONFIRMERR.visible = true

func add(item_name,url="",icon="",tooltip=""):
	var box = LinkBox.instance()
	box.boxname = item_name
	var init_state = {}
	if url:
		init_state["URL"] = url
	if icon:
		init_state["ICON"] = icon
	if tooltip:
		init_state["TOOLTIP"] = tooltip
	box.initial_state = init_state
	dataStore[item_name] = box
	box.CONTAINER = self
	CONFIRM.hide()
	has_changed()
	resort()

func delete(which):
	if which in dataStore:
		var box = dataStore[which]
		box.queue_free()
		dataStore.erase(which)
		has_changed()
		resort()

func rename(old,new):
	if old in dataStore:
		var ov = dataStore[old]
		ov.boxname = new
		dataStore.erase(old)
		dataStore[new] = ov
		has_changed()
		resort()

func resort():
	for i in LIST.get_children():
		LIST.remove_child(i)
	for r in dataStore:
		var i = dataStore[r]
		if is_instance_valid(i) and not i.is_queued_for_deletion():
			LIST.add_child(i)
	recalculate()

func _draw():
	recalculate()

func get_list():
	var objList = []
	for i in dataStore:
		objList.append(dataStore[i])
	return objList

const page_size = 10
var current_page = 0
func recalculate():
	var size = dataStore.size()
	if LIST and LIST.is_visible_in_tree():
		var objList = get_list()
		ENTRY.value = size
		var offset = (current_page * page_size)
		var max_pages = int(ceil(float(size)/float(page_size))) - 1
		for iv in objList:
			iv.visible = false
		if size > page_size:
			for iv in range(clamp(size - offset,0,page_size)):
				objList[iv + offset].visible = true
			PAGE.get_parent().visible = true
		else:
			for iv in objList:
				iv.visible = true
			PAGE.get_parent().visible = false
			current_page = 0
		PAGE.value = current_page
	else:
		current_page = 0

func _size_value_changed(how:float):
	how = int(how)
	var objList = get_list()
	var sz = objList.size()
	if how != sz:
		if how < sz and sz > 0:
			objList[sz - 1].DELETE()
		elif how > sz:
			add("LINK_EXAMPLE")
	recalculate()

func _page_value_changed(how:float):
	how = int(how)
	if how != current_page:
		var size = dataStore.size()
		var offset = (current_page * page_size)
		var max_pages = int(ceil(float(size)/float(page_size))) - 1
		if how < current_page and current_page > 0:
			current_page -= 1
		elif how > current_page:
			if current_page < max_pages:
				current_page += 1
	recalculate()

