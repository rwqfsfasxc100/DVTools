tool
extends Button

export (String,MULTILINE) var property_tooltip = ""

func _on_DescriptionLabel_visibility_changed():
	if is_visible_in_tree():
		var nm = get_parent().name
		text = nm
		var tt = property_tooltip
		if tt:
			nm += "\n\n" + tt
		hint_tooltip = "Property: " + nm
		
