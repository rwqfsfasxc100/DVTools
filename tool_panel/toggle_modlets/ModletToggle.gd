tool
extends CheckButton

var modlet_path:String = ""

func _ready():
	connect("visibility_changed",self,"change_name")

func change_name():
	text = modlet_path
