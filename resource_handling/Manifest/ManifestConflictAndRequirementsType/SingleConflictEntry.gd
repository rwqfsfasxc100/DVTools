tool
extends HBoxContainer

func set_data(how):
	match typeof(how):
		TYPE_STRING:
			var is_modmain = how.begins_with("res://")
			_on_CheckTypeSwap_toggled(is_modmain)
			$CONTENT/HB/OPTS/IDorModMain/CheckButton.pressed = is_modmain
			if is_modmain:
				$CONTENT/HB/OPTS/ModMainPath/LineEdit.text = how
			else:
				$CONTENT/HB/OPTS/ModID/LineEdit.text = how
		TYPE_DICTIONARY:
			if "mod_id" in how and how.mod_id:
				$CONTENT/HB/OPTS/IDorModMain/CheckButton.pressed = false
				_on_CheckTypeSwap_toggled(false)
				$CONTENT/HB/OPTS/ModID/LineEdit.text = str(how.mod_id)
				if "minimum_version" in how or "min_version" in how:
					var minimum = how.get("minimum_version",how.get("min_version",[0,0,0]))
					var mnm = null
					match typeof(minimum):
						TYPE_ARRAY,TYPE_INT_ARRAY:
							if minimum.size() > 2:
								mnm = minimum
						TYPE_VECTOR3:
							mnm = minimum
						TYPE_DICTIONARY:
							var minarr = Vector3.ZERO
							minarr[0] = int(minimum.get("major",0))
							minarr[1] = int(minimum.get("minor",0))
							minarr[2] = int(minimum.get("bugfix",0))
							mnm = minarr
					if mnm != null:
						$CONTENT/HB/OPTS/MinMajor/SpinBox.value = int(mnm[0])
						$CONTENT/HB/OPTS/MinMinor/SpinBox.value = int(mnm[1])
						$CONTENT/HB/OPTS/MinBugfix/SpinBox.value = int(mnm[2])
				if "maximum_version" in how or "max_version" in how:
					var minimum = how.get("maximum_version",how.get("max_version",[0,0,0]))
					var mnm = null
					match typeof(minimum):
						TYPE_ARRAY,TYPE_INT_ARRAY:
							if minimum.size() > 2:
								mnm = minimum
						TYPE_VECTOR3:
							mnm = minimum
						TYPE_DICTIONARY:
							var minarr = Vector3.ZERO
							minarr[0] = int(minimum.get("major",0))
							minarr[1] = int(minimum.get("minor",0))
							minarr[2] = int(minimum.get("bugfix",0))
							mnm = minarr
					if mnm != null:
						$CONTENT/HB/OPTS/MaxMajor/SpinBox.value = int(mnm[0])
						$CONTENT/HB/OPTS/MaxMinor/SpinBox.value = int(mnm[1])
						$CONTENT/HB/OPTS/MaxBugfix/SpinBox.value = int(mnm[2])
				if "blocking" in how:
					$CONTENT/HB/OPTS/Blocking/CheckButton.pressed = bool(how.blocking)
			elif "mod_main" in how and how.mod_main:
				$CONTENT/HB/OPTS/IDorModMain/CheckButton.pressed = true
				_on_CheckTypeSwap_toggled(true)
				$CONTENT/HB/OPTS/ModMainPath/LineEdit.text = str(how.mod_main)

func get_data():
	if $CONTENT/HB/OPTS/IDorModMain/CheckButton.pressed:
		return str($CONTENT/HB/OPTS/ModMainPath/LineEdit.text)
	var mod_id = str($CONTENT/HB/OPTS/ModID/LineEdit.text)
	var min_major = int($CONTENT/HB/OPTS/MinMajor/SpinBox.value)
	var min_minor = int($CONTENT/HB/OPTS/MinMinor/SpinBox.value)
	var min_bugfix = int($CONTENT/HB/OPTS/MinBugfix/SpinBox.value)
	var max_major = int($CONTENT/HB/OPTS/MaxMajor/SpinBox.value)
	var max_minor = int($CONTENT/HB/OPTS/MaxMinor/SpinBox.value)
	var max_bugfix = int($CONTENT/HB/OPTS/MaxBugfix/SpinBox.value)
	var blocking = bool($CONTENT/HB/OPTS/Blocking/CheckButton.pressed)
	if min_major > 0 or min_minor > 0 or min_bugfix > 0 or max_major > 0 or max_minor > 0 or max_bugfix > 0 or blocking:
		var out = {"mod_id":mod_id}
		if min_major > 0 or min_minor > 0 or min_bugfix > 0:
			out["minimum_version"] = [min_major,min_minor,min_bugfix]
		if max_major > 0 or max_minor > 0 or max_bugfix > 0:
			out["maximum_version"] = [max_major,max_minor,max_bugfix]
		if blocking:
			out["blocking"] = true
		return out
	return mod_id

var toggle_format = "%s check for '%s'"
func _ready():
	yield(get_tree(),"idle_frame")
	refresh_title()

func _on_CheckTypeSwap_toggled(button_pressed):
	$CONTENT/HB/OPTS/ModID.visible = !button_pressed
	$CONTENT/HB/OPTS/ModMainPath.visible = button_pressed
	$CONTENT/HB/OPTS/MinMajor.visible = !button_pressed
	$CONTENT/HB/OPTS/MinMinor.visible = !button_pressed
	$CONTENT/HB/OPTS/MinBugfix.visible = !button_pressed
	$CONTENT/HB/OPTS/MaxMajor.visible = !button_pressed
	$CONTENT/HB/OPTS/MaxMinor.visible = !button_pressed
	$CONTENT/HB/OPTS/MaxBugfix.visible = !button_pressed
	$CONTENT/HB/OPTS/Blocking.visible = !button_pressed


func _on_TOGGLE_pressed():
	$CONTENT/HB/OPTS.visible = !$CONTENT/HB/OPTS.visible

func refresh_title():
	var item = ""
	var type = ""
	if $CONTENT/HB/OPTS/IDorModMain/CheckButton.pressed:
		item = $CONTENT/HB/OPTS/ModMainPath/LineEdit.text
		type = "ModMain path"
	else:
		item = $CONTENT/HB/OPTS/ModID/LineEdit.text
		type = "Mod ID"
	$CONTENT/TBOX/TOGGLE.text = toggle_format % [type,item]

func _draw():
	refresh_title()


func _on_DELETE_pressed():
	get_parent().remove_child(self)
	queue_free()
