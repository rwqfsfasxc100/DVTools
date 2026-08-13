tool
extends HBoxContainer

func get_data():
	var out = []
	for i in $CONTENT/HB/VB/LIST.get_children():
		var data = i.get_data()
		out.append(data)
	return out

func set_data(STATE):
	for i in $CONTENTVB/LIST.get_children():
		$CONTENT/HB/VB/LIST.remove_child(i)
		i.queue_free()
	for i in Array(STATE):
		match typeof(i):
			TYPE_STRING,TYPE_DICTIONARY:
				add(i)
	refresh_title()

func add(data = null):
	var node = load("res://addons/DVTools/resource_handling/Manifest/ManifestConflictAndRequirementsType/SingleConflictEntry.tscn").instance()
	if data != null and node.has_method("set_data"):
		node.set_data(data)
	$CONTENT/HB/VB/LIST.add_child(node)

func _ready():
	$CONTENT/HB/VB/ADD.connect("pressed",self,"add")

func _on_TOGGLE_pressed():
	$CONTENT/HB.visible = !$CONTENT/HB.visible

func _on_DELETE_pressed():
	get_parent().remove_child(self)
	queue_free()

var toggle_format = "Multiple checks (%d items)"
func refresh_title():
	$CONTENT/TBOX/TOGGLE.text = toggle_format % $CONTENT/HB/VB/LIST.get_child_count()

func _draw():
	refresh_title()
