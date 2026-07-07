tool
extends VBoxContainer

onready var TOGGLE = $HEADER/TOGGLE
onready var RENAME = $HEADER/RENAME
onready var DELETE = $HEADER/DELETE
onready var DELETEMENU = $DoDelete
onready var BODY = $BUFFER/BODY
onready var CONTENT = $BUFFER/BODY/LIST
onready var RENAMEBOX = $RenameTo
onready var RENAMEEDIT = $RenameTo/LineEdit

onready var ADDENTRY = $BUFFER/BODY/ADD
onready var ADDCONFIRM = $BUFFER/BODY/ConfirmationDialog
onready var ADDEDIT = $BUFFER/BODY/ConfirmationDialog/VBoxContainer/LineEdit
onready var ADDLABEL = $BUFFER/BODY/ConfirmationDialog/VBoxContainer/Label
onready var ADDOPTS = $BUFFER/BODY/ConfirmationDialog/VBoxContainer/OptionButton

onready var ENTRYBOX = $BUFFER/BODY/ENTRY/COUNT
onready var PAGEBOX = $BUFFER/BODY/PAGE/COUNT

onready var UPBTN = $HEADER/UP
onready var DWNBTN = $HEADER/DOWN

var toggled = false

var boxname = ""

var deleteformat = ""

var CONTAINER

var initial_state:Dictionary = {}

func _ready():
	deleteformat = DELETEMENU.dialog_text
	TOGGLE.connect("pressed",self,"_toggle_pressed")
	DELETE.connect("pressed",self,"_on_delete")
	DELETEMENU.connect("confirmed",self,"DELETE")
	TOGGLE.text = boxname
	RENAME.connect("pressed",self,"_on_rename")
	RENAMEBOX.connect("confirmed",self,"RENAME_CONFIRMED")
	
	ADDENTRY.connect("pressed",self,"_on_add_open")
	ADDCONFIRM.connect("confirmed",self,"_add_confirmed")
	
	ENTRYBOX.connect("value_changed",self,"_size_value_changed")
	PAGEBOX.connect("value_changed",self,"_page_value_changed")
	
	UPBTN.connect("pressed",self,"_on_up_pressed")
	DWNBTN.connect("pressed",self,"_on_down_pressed")
	
	var addOrder = {}
	
	var noOrder = []
	
	var isKeys = initial_state.keys()
	for idx in range(isKeys.size()):
		var i = isKeys[idx]
		var state = initial_state[i]
		if "display_order_position" in state:
			var ido = state.display_order_position
			while ido in addOrder:
				ido += 1
			addOrder[ido] = [i,state]
		else:
			noOrder.append([i,state])
	var ctr = 0
	var aoKeys = addOrder.keys()
	aoKeys.sort()
	for r in aoKeys:
		var i = addOrder[r]
		add(i[0],i[1])
		ctr += 1
	for i in noOrder:
		i[1]["display_order_position"] = ctr
		add(i[0],i[1])
		ctr += 1
	yield(get_tree(),"idle_frame")
	_on_down_pressed()

func _on_up_pressed():
	if CONTAINER:
		CONTAINER.move_id_up(boxname,get_position_in_parent())
func _on_down_pressed():
	if CONTAINER:
		CONTAINER.move_id_down(boxname,get_position_in_parent())

var dataStore = {}

const config_types = PoolStringArray([
	"bool",
	"int",
	"float",
	"string",
	"optionbutton",
	"input",
	"action",
])

func _on_add_open():
	ADDOPTS.clear()
	for i in config_types:
		ADDOPTS.add_item(i)
	ADDOPTS.select(0)
	ADDEDIT.text = ""
	ADDLABEL.visible = false
	ADDCONFIRM.popup_centered()
	ADDEDIT.grab_focus()

func _add_confirmed():
	var newname = ADDEDIT.text
	if not newname in dataStore:
		var type = config_types[ADDOPTS.selected]
		add(newname,{"type":type})
	else:
		ADDLABEL.visible = true
const CfgEntryBox = preload("res://addons/DVTools/resource_handling/Manifest/ManifestCFGType/CfgEntryBox.tscn")

func add(item_name,state = {}):
	var box = CfgEntryBox.instance()
	box.boxname = item_name
	box.initial_state = state
	dataStore[item_name] = box
	box.CONTAINER = self
	ADDCONFIRM.hide()
	changed()
	resort()

func has_changed():
	changed()

func delete(which):
	if which in dataStore:
		var box = dataStore[which]
		box.queue_free()
		dataStore.erase(which)
		changed()
		resort()

func rename(old,new):
	if old in dataStore:
		var ov = dataStore[old]
		ov.boxname = new
		dataStore.erase(old)
		dataStore[new] = ov
		changed()
		resort()

func resort():
	for i in CONTENT.get_children():
		CONTENT.remove_child(i)
	for r in dataStore:
		var i = dataStore[r]
		if is_instance_valid(i) and not i.is_queued_for_deletion():
			CONTENT.add_child(i)
	recalculate()

func get_list():
	var objList = []
	for i in dataStore:
		objList.append(dataStore[i])
	return objList

var order = []
func move_id_up(bn:String,idx:int):
	if not bn in order:
		order.append(bn)
	if not bn in dataStore:
		dataStore[bn] = get_child(idx)
	if idx > 0:
		order.remove(idx)
		order.insert(idx - 1,bn)
		recalculate()
func move_id_down(bn:String,idx:int):
	if not bn in order:
		order.append(bn)
	if not bn in dataStore:
		dataStore[bn] = get_child(idx)
	if idx < (order.size() - 1):
		order.remove(idx)
		order.insert(idx + 1,bn)
		recalculate()

const page_size = 10
var current_page = 0
func recalculate():
	var size = dataStore.size()
	if CONTENT and CONTENT.is_visible_in_tree():
		var objList = get_list()
		ENTRYBOX.value = size
		var offset = (current_page * page_size)
		var max_pages = int(ceil(float(size)/float(page_size))) - 1
		for iv in objList:
			iv.visible = false
		if size > page_size:
			for iv in range(clamp(size - offset,0,page_size)):
				objList[iv + offset].visible = true
			PAGEBOX.get_parent().visible = true
		else:
			for iv in objList:
				iv.visible = true
			PAGEBOX.get_parent().visible = false
			current_page = 0
		PAGEBOX.value = current_page
	else:
		current_page = 0
	for i in order:
		CONTENT.move_child(dataStore[i],size)

func _size_value_changed(how:float):
	how = int(how)
	var objList = get_list()
	var sz = objList.size()
	if how != sz:
		if how < sz and sz > 0:
			objList[sz - 1].DELETE()
		elif how > sz and not "example_string_name" in dataStore:
			add("example_string_name",{"type":"bool"})
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





func changed(how = null):
	if CONTAINER:
		CONTAINER.has_changed()


func get_data():
	var out = {}
	for i in $BUFFER/BODY/LIST.get_children():
		var data = i.get_data()
		out[i.boxname] = data
	boxname = $HEADER/TOGGLE.text
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
				toggled = false
			RENAMEBOX.hide()

func _draw():
	if BODY:
		BODY.visible = toggled
		TOGGLE.text = boxname
