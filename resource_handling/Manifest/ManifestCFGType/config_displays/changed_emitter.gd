extends Node

signal changed()

func emit_changed(a = null,b = null,c = null,d = null,e = null,g = null,f = null):
	emit_signal("changed")

