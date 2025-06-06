extends Node2D

var chord_data: Dictionary = {}


# JSONファイルのプロジェクト内パス
const CHORD_DATA_PATH = "res://assets/chord_data.json"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_chord_data()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# コードデータを読み込むメイン関数
func load_chord_data():
	# 1. ファイルからJSON文字列を読み込む
	var json_content: String = _read_json_file(CHORD_DATA_PATH)

	# 2. 読み込みに失敗した場合は処理を中断
	if json_content == null:
		chord_data = {} # 念のため空にしておく
		return

	# 3. JSON文字列をパースしてDictionaryを取得する
	chord_data = _parse_json_string(json_content)


# 指定されたパスのファイルを開き、内容を文字列として読み込んで返す関数
# 成功した場合はファイル内容の文字列、失敗した場合は null を返す
func _read_json_file(file_path: String):

	# 1. ファイルが存在するか確認
	if not FileAccess.file_exists(file_path):
		printerr("エラー: 指定されたパスにファイルが見つかりません: ", file_path)
		return null

	# 2. FileAccess を使ってファイルを開く (読み取りモード)
	var file = FileAccess.open(file_path, FileAccess.READ)

	# 3. ファイルオープンに成功したか確認
	if file == null:
		var error_code = FileAccess.get_open_error()
		printerr("エラー: ファイルを開けませんでした。パス: ", file_path, " エラーコード: ", error_code)
		return null

	# 4. ファイルの内容を全てテキストとして読み込む
	#   try-finally のような構文はないため、読み込み後に必ず close する
	var content: String = file.get_as_text()

	# 5. ファイルを閉じる (重要！)
	file.close()

	# 6. 読み込んだ内容を返す
	return content


# JSON文字列をパースしてDictionaryを返す関数
# 成功した場合はパース結果のDictionary、失敗した場合は空のDictionaryを返す
func _parse_json_string(json_string: String) -> Dictionary:

	# 1. JSONクラスのインスタンスを作成
	var json = JSON.new()

	# 2. 読み込んだテキストをパース（解析）する
	var error = json.parse(json_string)

	# 3. パースエラーの確認
	if error != OK:
		printerr("エラー: JSONデータのパースに失敗しました。")
		printerr("  エラーメッセージ: ", json.get_error_message())
		printerr("  エラー発生行: ", json.get_error_line())
		return {} # パースに失敗した場合は空のDictionaryを返す

	# 4. パース結果を取得
	var data = json.get_data()

	# 5. 取得したデータがDictionaryであることを確認
	if typeof(data) == TYPE_DICTIONARY:
		return data # Dictionaryならそのまま返す
	else:
		printerr("エラー: JSONデータが期待されるDictionary形式ではありません。実際の型: ", typeof(data))
		return {} # 期待する型でない場合は空のDictionaryを返す


# 指定されたインデックスに対応するコードデータを返す関数
func get_chord_by_index(index: int):
	var chord_keys = chord_data.keys() # Dictionaryのキーの配列を取得

	var selected_key = chord_keys[index] # インデックスに対応するキーを取得

	return [selected_key,chord_data[selected_key]]      # キーを使ってコードデータを取得して返す


# 指定されたコード名に対応する音(ノート)の配列を返す関数
# 例: "C" を渡すと ["C4", "E4", "G4"] のような配列を返す
# コード名が見つからない場合や、データが期待する形式でない場合は空の配列を返す
func get_notes_by_chord_name(chord_name: String) -> Array:
	if not chord_data.has(chord_name):
		printerr("エラー: コード名 '%s' が chord_data に見つかりません。" % chord_name)
		return []

	var chord_entry_data  = chord_data[chord_name]

	var notes_array=chord_entry_data["notes"]
	
	return notes_array
