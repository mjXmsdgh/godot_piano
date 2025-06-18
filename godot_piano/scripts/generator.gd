extends Node2D

# キー
var target_key: String

# コード数
var target_number: int

# 生成されたコード進行
var generated_chords: Array[String] = [] 


var diatonic_chord_list: Array[Dictionary] = [] # 格納するデータ構造に合わせて型を Array[Dictionary] に変更




# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# 仮
	target_key="C"
	target_number=4

	# chord_listを読み込む
	load_chord_list()

	#generate_chord()
	pass # Replace with function body.


func load_chord_list() -> void:
	# 0. diatonic_chord_list をクリアする (もし複数回呼び出される可能性がある場合)
	diatonic_chord_list.clear()

	# 1. CSVファイルのパスを定義する
	var file_path = "res://assets/diatonic_chord_list.csv"

	# 2. FileAccess を使用してCSVファイルを開く
	var file = FileAccess.open(file_path, FileAccess.READ)

	# 3. ファイルが正しく開けたか確認する
	if FileAccess.get_open_error() != OK:
		printerr("Failed to open diatonic_chord_list.csv: ", FileAccess.get_open_error())
		return

	# 4. ファイルを1行ずつ読み込むループ
	while not file.eof_reached():
		
		# CSVの1行を配列として取得
		var line: PackedStringArray = file.get_csv_line() 

		# 5. ヘッダー行をスキップする
		if is_header_row(line):
			continue

		# 6. データ行の列数を確認 (キー, ディグリー, コード名, 機能名の最低4列を期待)
		if line.size() < 4:
			printerr("Skipping malformed CSV data line (expected at least 4 columns, got %s): %s" % [line.size(), str(line)])
			continue

		var key = line[0]
		var degree = line[1]
		var chord_name = line[2]
		var function_name = line[3]
	
		diatonic_chord_list.append({ "key": key, "degree": degree, "chord_name": chord_name, "function_name": function_name })


	# 7. ファイルを閉じる
	file.close()
	

func is_header_row(line: Array[String]) -> bool:

	# lineが空でないこと、かつ最初の要素が文字列で、"#"で始まるかを確認
	if not line.is_empty() and line[0] is String and line[0].begins_with("#"):
		return true
	else:
		return false

	


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
	var tonic_chords = ["C", "Am"] #(I, vi)
	var subdominant_chords = ["Dm", "F"] #(ii, IV)
	var dominant_chords = ["G", "Bm(b5)"] #(V, viiø) ※セブンスも考慮可 G7など
	#    (この部分は別途データ構造やヘルパー関数で管理すると良いでしょう)
	#var _tonic_chords: Array[String] = [] # 仮
	#var _subdominant_chords: Array[String] = [] # 仮
	#var _dominant_chords: Array[String] = [] # 仮

	# (仮のデータ設定 - 実際には target_key に基づいて設定する)
	#if target_key == "C": # この部分は後でちゃんと実装
	#	_tonic_chords = ["C", "Am"]
	#	_subdominant_chords = ["Dm", "F"]
	#	_dominant_chords = ["G", "Bm(b5)"]
	#else:
#		return

	# 2. 最初のコードを設定 (通常はトニック I)
	generated_chords.append(tonic_chords[0]) # 例: "C"

	# 3. 2番目以降のコードを target_number に達するまで生成
	
	#for i in range(1, target_number):
	#	current_function = get_function_of(generated_chords[i-1]) # 前のコードの機能を取得
	#	next_function_candidates = get_next_function_candidates(current_function) # T->SD/D, SD->D/T, D->T
	#	chosen_next_function = next_function_candidates.pick_random()
	#	chosen_chord = get_random_chord_from_function(chosen_next_function, tonic_chords, subdominant_chords, dominant_chords)
	#	generated_chords.append(chosen_chord)

	# 4. (オプション) 最後のコードをトニックにする調整
	#if target_number > 1 and get_function_of(generated_chords.back()) != "T":
	#	generated_chords[target_number-1] = tonic_chords[0] # 例: "C"
	
	print("生成ロジックの骨子です。詳細はこれから実装します。")
	print("ターゲットキー: ", target_key, ", コード数: ", target_number)
	print("生成されたコード（仮）: ", generated_chords)


func get_function_of(chord: String) -> void:
	# 処理の概要: 与えられたコード名が、現在のキーにおいてどのような機能（トニック、サブドミナント、ドミナント）を持つかを判定する。

	# 1. 現在の `target_key` に基づいて、そのキーのダイアトニックコードと各機能（T, SD, D）の対応関係を準備する。
	#    例: `target_key` が "C" の場合
	#        トニック(T)    : ["C", "Am"]
	#        サブドミナント(SD): ["Dm", "F"]
	#        ドミナント(D)  : ["G", "Bm(b5)"]
	#    この対応関係は、`generate_chord` 関数内の `tonic_chords`, `subdominant_chords`, `dominant_chords` のような形で
	#    あらかじめ定義されているか、あるいはキーに応じて動的に生成するヘルパー関数を呼び出して取得する。

	# 2. 引数 `chord` が、ステップ1で準備した各機能のコードリストのいずれに含まれるかを確認する。
	#    - `tonic_chords` に含まれていれば、機能 "T" を返す。
	#    - `subdominant_chords` に含まれていれば、機能 "SD" を返す。
	#    - `dominant_chords` に含まれていれば、機能 "D" を返す。
	# 3. いずれのリストにも含まれない場合（例: ノンダイアトニックコードや予期せぬ入力）、デフォルト値（例: 空文字や "Unknown"）を返すか、エラー処理を行う。
	pass
