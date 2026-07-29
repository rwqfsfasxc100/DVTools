tool
extends OptionButton

const hold_types = PoolStringArray([
	"",
	"divided",
	"amorphic",
	"mono",
])

const tooltips = {
	"":"",
	"divided":"Storage is equally split among all mineral types",
	"amorphic":"Storage is total maximum for all minerals combined",
	"mono":"Storage can only be used for one mineral type",
}

func _ready():
	clear()
	for r in range(hold_types.size()):
		var i = hold_types[r]
		add_item(i)
		set_item_tooltip(r,tooltips.get(i,""))
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
