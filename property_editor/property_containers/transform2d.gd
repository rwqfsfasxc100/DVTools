tool
extends VBoxContainer

signal changed()

func get_property_value():
	var X = $X/vec2.get_property_value()
	var Y = $Y/vec2.get_property_value()
	var O = $ORIGIN/vec2.get_property_value()
	var string = "Transform2D( %s , %s , %s )" % [X[1],Y[1],O[1]]
	return [Transform2D(X[0],Y[0],O[0]),string]

func set_property_value(property):
	if property is Transform2D:
		$X/vec2.set_property_value(property.x)
		$Y/vec2.set_property_value(property.y)
		$ORIGIN/vec2.set_property_value(property.origin)

func _ready():
	$ORIGIN/vec2.connect("changed",self,"_on_changed")
	$X/vec2.connect("changed",self,"_on_changed")
	$Y/vec2.connect("changed",self,"_on_changed")

func _on_changed():
	emit_signal("changed")
