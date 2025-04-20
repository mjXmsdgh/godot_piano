extends Node2D


var key_nodes: Dictionary={ }


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	key_nodes["A3"] = $kenban/Key_A3
	key_nodes["B3"] = $kenban/Key_B3
	key_nodes["C4"] = $kenban/Key_C4
	key_nodes["D4"] = $kenban/Key_D4
	key_nodes["E4"] = $kenban/Key_E4
	key_nodes["F4"] = $kenban/Key_F4
	key_nodes["G4"] = $kenban/Key_G4
	key_nodes["A4"] = $kenban/Key_A4
	key_nodes["B4"] = $kenban/Key_B4
	key_nodes["C5"] = $kenban/Key_C5


	key_nodes["A#3"] = $kenban/Key_As3 # Or Key_Bb3 
	key_nodes["C#4"] = $kenban/Key_Cs4 # Or Key_Db4
	key_nodes["D#4"] = $kenban/Key_Ds4 # Or Key_Eb4
	key_nodes["F#4"] = $kenban/Key_Fs4 # Or Key_Gb4
	key_nodes["G#4"] = $kenban/Key_Gs4 # Or Key_Ab4
	key_nodes["A#4"] = $kenban/Key_As4 # Or Key_Bb4

	#test_play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# 登録されている鍵盤を順番に再生するテスト関数
func test_play() -> void:

	for item in key_nodes.keys():

		# 現在のキー (音名) をコンソールに出力
		print(item)


		play_note(item)

		# 1秒待機してから次の音へ (非同期処理
		await get_tree().create_timer(1).timeout


# 指定された音名の鍵盤ノードの再生処理を呼び出す関数
# note_name: 再生したい音名 (例: "C4", "A#3")
func play_note(note_name: String) -> void:

	var key_node=key_nodes[note_name]

	key_node.play_sound()
