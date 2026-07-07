tool
extends MenuButton

signal selected(identifier)

var base_menu_data = [
	{
		"name":"Save",
	},
	{
		"name":"Save As",
	},
	{
		"name":"Open",
	},
	{
		"name":"",
		"separator":true,
	},
	{
		"name":"New",
		"children":[
			{
				"name":"EquipmentDriver",
				"separator":true,
			},
			{
				"name":"ADD_EQUIPMENT_ITEMS.gd"
			}
		]
	},
]

var menu_store = {}

func _ready():
	handle_menubuttons()

func handle_menubuttons():
	var popupmenu = get_popup()
	popupmenu.allow_search = true
	add_menu_buttons(base_menu_data,popupmenu)
	

func add_menu_buttons(menu_data: Array,popupmenu:PopupMenu,path:String = "root"):
	for idx in range(menu_data.size()):
		var i = menu_data[idx]
		var iname = i.get("name","")
		var children = i.get("children",[])
		var separator = i.get("separator",false)
		if separator:
			popupmenu.add_separator(iname)
		elif children:
			var pm = PopupMenu.new()
			pm.name = iname + "_submenu"
			pm.allow_search = true
			popupmenu.add_child(pm)
			popupmenu.add_submenu_item(iname,iname + "_submenu")
		else:
			popupmenu.add_item(iname)
			if not path in menu_store:
				menu_store[path] = {}
			menu_store[path][idx] = iname
			if not popupmenu.is_connected("index_pressed",self,"_menu_pressed"):
				popupmenu.connect("index_pressed",self,"_menu_pressed",[path])
		if children:
			add_menu_buttons(children,popupmenu.get_node_or_null(iname + "_submenu"),path + "/" + iname)

func _menu_pressed(idx:int,actual:String):
	var iName = menu_store[actual][idx]
	var identifier = "%s/%s" % [actual,iName]
	emit_signal("selected",identifier)
