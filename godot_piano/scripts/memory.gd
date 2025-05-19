extends Node2D

var memory_chord_notes=[]

signal recall_chord_selected(chord_notes: Array)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_memory_pressed() -> void:
	print("memory")
	
	var test=get_node_or_null("../")

	var temp=test.current_chord_notes

	print(temp)

	memory_chord_notes.append(temp)


func _on_recall_pressed() -> void:

	var selected_notes=memory_chord_notes[0]

	emit_signal("recall_chord_selected",selected_notes)

	memory_chord_notes.remove_at(0)
