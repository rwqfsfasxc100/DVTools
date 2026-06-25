tool
extends Resource
class_name ManifestResource

export (Dictionary) var manifest = {} setget set_manifest

func set_manifest(value:Dictionary) -> void:
	manifest = value
	emit_changed()
