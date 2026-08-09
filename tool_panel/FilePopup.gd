tool
extends "res://addons/DVTools/tool_panel/MenuItemBase.gd"

var this_menu_data = [
	{
		"name":"Save",
		"tooltip":"",
	},
	{
		"name":"Save As",
		"tooltip":"",
	},
	{
		"name":"Open",
		"tooltip":"",
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
				"tooltip":"Drivers that interact with equipment or equipment slots",
				"separator":true,
			},
			{
				"name":"ADD_EQUIPMENT_ITEMS.gd",
				"tooltip":"Handles items to be added to equipment slots in Enceladus's Equipment menu",
			},
			{
				"name":"ADD_EQUIPMENT_SLOTS.gd",
				"tooltip":"Handles equipment slots to be added to Enceladus's Equipment menu",
			},
			{
				"name":"EQUIPMENT_TAGS.gd",
				"tooltip":"Manages tags that handle which equipment can be added to specific slots",
			},
			{
				"name":"SLOT_TAGS.gd",
				"tooltip":"Modifies equipment and slot availability of specific slots",
			},
		]
	},
]


func _ready():
	base_menu_data = this_menu_data
	handle_menubuttons()
