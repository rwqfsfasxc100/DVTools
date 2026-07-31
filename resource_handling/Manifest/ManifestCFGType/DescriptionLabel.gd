tool
extends Button

func get_property_tooltip(property:String) -> String:
	match property:
		"name":
			return "The display name for the config.\nCan be a translation string."
		"description":
			return "The description tooltip for the config.\nCan be a translation string."
		"default":
			return "The default value for the config."
		"requires_bools":
			return "Config paths to boolean configs required for this config to be editable.\nIf a config is not a bool, it is ignored, and all configs must be true.\n\nConfigs follow the format of \"Identifier/Section/Config\",\ni.e. \"VelocityPlus/VP_ENCELADUS/enable_achievements\"\n\nConfig names cannot have spaces or forward slashes,\nuse ConfigDriver.__truncate_to_setting_entry to help format."
		"invert_bool_requirement":
			return "All configs listed in requires_bools now need to be false to make this editable."
		"require_restart":
			return "Whether changing the config will require and \nstart prompting the user for a game restart."
		"disabled":
			return "Whether the config setting is disabled and will be prevented from being parsed with the manifest.\nA mod needs to implement a custom parser to be able to read manifests with disabled configs."
		"min":
			return "The minimum value of the display."
		"max":
			return "The maximum value of the display."
		"step":
			return "How much the value is allowed to be incremented by."
		"style":
			return "The style of the value display.\nAccepts \"slider\" and \"spinbox\"."
		"placeholder":
			return "Placeholder text used when there is nothing in the string."
		"max_length":
			return "The maximum amount of characters allowed in the box."
		"secret":
			return "Whether the text should be hidden."
		"clear_button":
			return "Whether a button to clear the text should be displayed."
		"options":
			return "The names for the options to display."
		"store_method":
			return "Whether the index of the selected option or the name of the selected option is stored by the config.\n\nAccepts \"int\" and \"string\"."
		"always_binds":
			return "Keybindss that will always be available for this config, and will not be displayed as options."
		"script_path":
			return "Filepath for the script that the action button uses."
		"button_label":
			return "String that the action button displays.\nCan be a translation string."
		"method":
			return "Method that the button script would be connected to."
		"edit_alpha":
			return "Whether the color can make use of the alpha channel"
		"scene_path":
			return "The file path to the scene which this display represents.\nAs this is stored within a margin container, make sure you properly size this scene with code, rect_size/rect_min)_size, or through size flags.\n\nProperties for scene script:\n - display_container - If added to your scene's topmost node, sets this as the node added to the config list.\n\nMethods for scene script:\n - get_label(direction = 0) - If added, handles which node would be the adjacent nameplate node for other configs.\n   direction - whether the config below (-1) or above (1) is asking for the label node.\n    Direction is used for special handling where the name label is not focused.\n    All configs have this method, and this should never be zero if called correctly.\n - get_focusable(direction = 0) - If added, handles which node would be the adjacent content button for other configs.\n   direction - whether the config below (-1) or above (1) is asking for the content button node.\n    Direction is used for special handling where the content button is not focused.\n    All configs have this method, and this should never be zero if called correctly.\n - get_reset(direction = 0) - If added, handles which node would be the adjacent reset button node for other configs.\n   direction - whether the config below (-1) or above (1) is asking for the reset node.\n    Direction is used for special handling where the reset button is not focused.\n    All configs have this method, and this should never be zero if called correctly."
	return ""


func _on_DescriptionLabel_visibility_changed():
	if is_visible_in_tree():
		var nm = get_parent().name
		text = nm
		var tt = get_property_tooltip(nm)
		if tt:
			nm += "\n\n" + tt
		hint_tooltip = "Property: " + nm
		
