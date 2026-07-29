tool
extends OptionButton

const hold_types = PoolStringArray([
	"",
	"divided",
	"amorphic",
	"mono",
])

func _ready():
	clear()
	for i in hold_types:
		add_item(i)
	select(0)

func set_hold_type(how:String):
	if how and how in hold_types:
		select(hold_types.find(how))
	else:
		select(0)

func get_hold_type():
	if selected > -1 and selected < hold_types.size():
		return hold_types[selected]
	return ""
