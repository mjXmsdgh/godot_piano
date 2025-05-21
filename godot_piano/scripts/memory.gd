extends Node2D

var memory_chord_notes=[]

signal recall_chord_selected(chord_name:String,chord_notes: Array)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_memory_pressed() -> void:
	
	var test=get_node_or_null("../")

	var temp_chord=test.current_chord

	var temp_notes=test.current_chord_notes

	$ItemList.add_item(temp_chord)


	memory_chord_notes.append([temp_chord,temp_notes])


func _on_recall_pressed() -> void:

	var selected_chord=memory_chord_notes[0][0]
	var selected_notes=memory_chord_notes[0][1]

	emit_signal("recall_chord_selected",selected_chord,selected_notes)

	memory_chord_notes.remove_at(0)
