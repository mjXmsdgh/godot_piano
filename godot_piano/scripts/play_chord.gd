extends Node2D

@onready var code_manager: Node = get_node_or_null("../CodeManager")
@onready var piano_player: Node = get_node_or_null("../")
@onready var chord_option_button = get_node_or_null("../chord_OptionButton")

# _ready() はノード取得以外の初期化処理がなければ削除できます
func _ready() -> void:
	pass # 他に初期化処理がなければこの行も不要


func _on_play_chord_pressed() -> void:

	var chord_to_play=chord_option_button.get_chord()

	#var chord_to_play:String="C"
	var chord_data=code_manager.chord_data
	var chord_info=chord_data[chord_to_play]

	var notes_array=chord_info["notes"]

	for note in notes_array:

		piano_player.play_note(note)
