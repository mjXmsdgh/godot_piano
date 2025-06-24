extends Node2D

# --- プロパティ ---

var target_key: String # 生成するコード進行のキー (例: "C")
var target_number: int # 生成するコードの数
var generated_chords: Array[String] = [] # 生成されたコード進行を格納する配列
var diatonic_chord_list: Array[Dictionary] = [] # CSVから読み込んだ全キーのダイアトニックコード情報

# --- Godotライフサイクル関数 ---

## ゲーム開始時に一度だけ呼ばれる初期化関数
func _ready() -> void:
	target_key = "C"
	target_number = 4
	# アプリケーション起動時にコードリストをメモリに読み込む
	load_chord_list()
	# コード進行を生成する
	generate_chord()


# --- データ読み込み ---

## CSVファイルからダイアトニックコードのリストを読み込み、`diatonic_chord_list`に格納する
func load_chord_list() -> void:
	# 複数回呼ばれた場合に備えてリストをクリア
	diatonic_chord_list.clear()
	var file_path = "res://assets/diatonic_chord_list.csv"
	var file = FileAccess.open(file_path, FileAccess.READ)
	# ファイルオープンに失敗した場合は処理を中断
	if FileAccess.get_open_error() != OK:
		return
	# ファイルの終わりまで1行ずつ読み込む
	while not file.eof_reached():
		var line: PackedStringArray = file.get_csv_line()
		# ヘッダー行（#で始まる行）はスキップ
		if is_header_row(line):
			continue
		# データが不正な行はスキップ
		if line.size() < 4:
			continue
		# CSVの各列をパースして辞書としてリストに追加
		var key = line[0]
		var degree = line[1]
		var chord_name = line[2]
		var function_name = line[3]
		diatonic_chord_list.append({ "key": key, "degree": degree, "chord_name": chord_name, "function_name": function_name })
	# ファイルを閉じる
	file.close()

## CSVの行がヘッダー行（コメント行）かどうかを判定する
func is_header_row(line: Array[String]) -> bool:
	return not line.is_empty() and line[0] is String and line[0].begins_with("#")


# --- セッター関数 ---

## UIなど外部からターゲットキーを設定する
func set_target_key(key: String) -> void:
	target_key = key

## UIなど外部から生成するコード数を設定する
func set_target_number(number: int) -> void:
	target_number = number	


# --- ヘルパー関数 ---

## 指定されたキーのダイアトニックコードを機能（T, SD, D）別に分類して辞書として返す
func _get_chords_by_function_for_key(key: String) -> Dictionary:
	var chords_by_function: Dictionary = {
		"T": [] as Array[String],
		"SD": [] as Array[String],
		"D": [] as Array[String]
	}
	for chord_data in diatonic_chord_list:
		# 全コードリストから指定されたキーのものだけを抽出
		if chord_data["key"] == key:
			var function_name: String = chord_data["function_name"]
			if chords_by_function.has(function_name):
				chords_by_function[function_name].append(chord_data["chord_name"])
	return chords_by_function


# --- メイン処理 ---

## コード進行を生成するメインの関数
func generate_chord() -> void:
	# 前回生成したコード進行をクリア
	generated_chords.clear()

	# 1. 現在のキーで使われるコードを機能別に取得
	var chords_in_key: Dictionary = _get_chords_by_function_for_key(target_key)
	var tonic_chords: Array[String] = chords_in_key.get("T", []) as Array[String]
	var subdominant_chords: Array[String] = chords_in_key.get("SD", []) as Array[String]
	var dominant_chords: Array[String] = chords_in_key.get("D", []) as Array[String]
	# トニックコードがない場合は生成を中止
	if tonic_chords.is_empty():
		return

	# 2. 開始コードをトニック(T)の中からランダムに選択
	var start_chord_index = randi_range(0, tonic_chords.size() - 1)
	generated_chords.append(tonic_chords[start_chord_index])

	# 3. 2番目以降のコードを target_number - 1 回生成
	for _i in range(target_number - 1):
		# 直前のコードに基づいて次のコードを決定
		var next_chord: String = _get_next_chord(
			generated_chords.back(), chords_in_key
		)
		generated_chords.append(next_chord)

	# 4. コード進行の最後を安定したトニックコードで終わらせる
	_finalize_chord_progression(generated_chords, target_key, diatonic_chord_list)

	# 5. 結果をコンソールに出力
	display_generated_chords()

## 生成されたコード進行をコンソールに出力する（デバッグ用）
func display_generated_chords() -> void:
	print(generated_chords)

## 現在のコードに基づいて、ルールに従い次のコードを1つ選択する
func _get_next_chord(
	current_chord_name: String,
	chords_by_function: Dictionary # { "T": Array[String], "SD": Array[String], "D": Array[String] }
) -> String:
	# コード進行の基本ルールを定義 (T→SD/D, SD→D, D→T)
	var function_transition: Dictionary = {
		"T": ["SD", "D"],
		"SD": ["D"],
		"D": ["T"]
	}
	# a. 現在のコードの機能(T/SD/D)を、渡された機能別コードリストから調べる
	var current_chord_function: String = ""
	for func_name in chords_by_function:
		if current_chord_name in chords_by_function[func_name]:
			current_chord_function = func_name
			break

	# b. ルールに基づいて、次に進める機能の候補リストを取得
	var next_functions_array = function_transition.get(current_chord_function, [])
	var next_functions: Array[String] = []
	
	for f in next_functions_array:
		next_functions.append(f as String)

	var candidates: Array[String] = []
	# c. 次の機能候補の中から、利用可能な具体的なコードのリストを探す
	for func_name in next_functions:
		var arr: Array[String] = chords_by_function.get(func_name, []) as Array[String]
		if not arr.is_empty():
			candidates = arr
			break
			
	# d. 同じコードが連続しないように、候補から現在のコードを除く
	var filtered_candidates: Array[String] = candidates.filter(func(c): return c != current_chord_name)
	
	# e. 候補の中からランダムに1つ選んで返す
	if not filtered_candidates.is_empty():
		# フィルタリング後の候補があれば、そこから選ぶ
		return filtered_candidates[randi_range(0, filtered_candidates.size() - 1)]
	elif not candidates.is_empty():
		# フィルタリングで候補がなくなった場合（＝全ての候補が現在のコードと同じだった場合）、仕方なく元の候補から選ぶ
		return candidates[randi_range(0, candidates.size() - 1)]
	else:
		# 適切な候補が全く見つからなかった場合は、現在のコードをそのまま返す
		return current_chord_name

## コード進行の最後を、そのキーの主要なトニックコードで解決させる
func _finalize_chord_progression(progression: Array[String], key: String, all_diatonic_chords: Array[Dictionary]) -> void:
	# 進行が空の場合は何もしない
	if progression.is_empty():
		return
	var primary_tonic_chord_name: String = ""
	# a. そのキーのI度（またはIm度）のコードを探す
	for chord_data in all_diatonic_chords:
		if chord_data["key"] == key and (chord_data["degree"] == "I" or chord_data["degree"] == "Im"):
			primary_tonic_chord_name = chord_data["chord_name"]
			break
	# b. I度のコードが見つかり、かつ最後のコードがそれと違う場合、置き換える
	if not primary_tonic_chord_name.is_empty() and progression.back() != primary_tonic_chord_name:
		progression.pop_back()
		progression.append(primary_tonic_chord_name)
