tool
extends HBoxContainer

var container_panel

var this_script_path = ""

var needs_save = false

func SAVE():
	if this_script_path:
		if this_script_path.begins_with("new://"):
			container_panel.open_save_as()
		else:
			if self.has_method("save_driver_data"):
				container_panel.save_data(self.call("save_driver_data"),this_script_path)
