tool
extends "res://addons/DVTools/tool_panel/MenuItemBase.gd"

var this_menu_data = [
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


func _ready():
	base_menu_data = this_menu_data
	handle_menubuttons()
