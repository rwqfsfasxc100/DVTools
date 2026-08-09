tool
extends MenuButton

signal selected(identifier)

export (String) var menu_root_name = ""

var base_menu_data:Array = []

var menu_store:Dictionary = {}

func handle_menubuttons():
	var popupmenu = get_popup()
	popupmenu.clear()
	popupmenu.allow_search = true
	add_menu_buttons(base_menu_data,popupmenu)
	

func add_menu_buttons(menu_data: Array,popupmenu:PopupMenu,path:String = menu_root_name):
	for idx in range(menu_data.size()):
		var i = menu_data[idx]
		var iname = i.get("name","")
		var children = i.get("children",[])
		var separator = i.get("separator",false)
		var checkbox = i.get("checkbox",false)
		var tooltip = i.get("tooltip","")
		if separator:
			popupmenu.add_separator(iname)
		elif checkbox:
			popupmenu.add_check_item(iname)
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
		if tooltip:
			popupmenu.set_item_tooltip(idx,tooltip)
		if children:
			add_menu_buttons(children,popupmenu.get_node_or_null(iname + "_submenu"),path + "/" + iname)

func _menu_pressed(idx:int,actual:String):
	var iName = menu_store[actual][idx]
	var identifier = "%s/%s" % [actual,iName]
	emit_signal("selected",identifier)
