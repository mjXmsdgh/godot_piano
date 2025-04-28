extends OptionButton


var code_manager:Node=null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	code_manager=get_node_or_null("../CodeManager")

	var chord_data:Dictionary=code_manager.chord_data

	clear()

	for chord_name in chord_data:
		add_item(str(chord_name))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func get_chord() -> String:
	var index: int=get_selected()

	var text: String=get_item_text(index)

	return text
