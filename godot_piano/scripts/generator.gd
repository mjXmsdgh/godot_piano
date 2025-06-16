extends Node2D

# キー
var target_key: String

# コード数
var target_number: int

# 生成されたコード進行
var generated_chords: Array[String] = [] 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_target_key(key: String) -> void:
	target_key = key


func set_target_number(number: int) -> void:
	target_number = number	


func generate_chord() -> void:
	generated_chords.clear() # 前回生成されたコードをクリア

	# --- ここからコード生成ロジックの骨子 ---

	# 1. キーに応じたダイアトニックコードと機能の準備
	#    例: target_key が "C" の場合
	#    tonic_chords = ["C", "Am"] (I, vi)
	#    subdominant_chords = ["Dm", "F"] (ii, IV)
	#    dominant_chords = ["G", "Bm(b5)"] (V, viiø) ※セブンスも考慮可 G7など
	#    (この部分は別途データ構造やヘルパー関数で管理すると良いでしょう)
	var _tonic_chords: Array[String] = [] # 仮
	var _subdominant_chords: Array[String] = [] # 仮
	var _dominant_chords: Array[String] = [] # 仮

	# (仮のデータ設定 - 実際には target_key に基づいて設定する)
	if target_key == "C": # この部分は後でちゃんと実装
		_tonic_chords = ["C", "Am"]
		_subdominant_chords = ["Dm", "F"]
		_dominant_chords = ["G", "Bm(b5)"]
	else:
		return

	# 2. 最初のコードを設定 (通常はトニック I)
	#    generated_chords.append(tonic_chords[0]) # 例: "C"

	# 3. 2番目以降のコードを target_number に達するまで生成
	#    for i in range(1, target_number):
	#        current_function = get_function_of(generated_chords[i-1]) # 前のコードの機能を取得
	#        next_function_candidates = get_next_function_candidates(current_function) # T->SD/D, SD->D/T, D->T
	#        chosen_next_function = next_function_candidates.pick_random()
	#        chosen_chord = get_random_chord_from_function(chosen_next_function, tonic_chords, subdominant_chords, dominant_chords)
	#        generated_chords.append(chosen_chord)

	# 4. (オプション) 最後のコードをトニックにする調整
	#    if target_number > 1 and get_function_of(generated_chords.back()) != "T":
	#        generated_chords[target_number-1] = tonic_chords[0] # 例: "C"
	
	print("生成ロジックの骨子です。詳細はこれから実装します。")
	print("ターゲットキー: ", target_key, ", コード数: ", target_number)
	# print("生成されたコード（仮）: ", generated_chords)
