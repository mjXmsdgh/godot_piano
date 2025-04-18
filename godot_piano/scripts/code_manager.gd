extends Node2D

var chord_data: Dictionary = {}


# JSONファイルのプロジェクト内パス
const CHORD_DATA_PATH = "res://assets/chord_data.json"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_chord_data()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# JSONファイルからコードデータを読み込む関数
func load_chord_data():
	# 1. ファイルが存在するか確認
	if not FileAccess.file_exists(CHORD_DATA_PATH):
		printerr("エラー: 指定されたパスにファイルが見つかりません: ", CHORD_DATA_PATH)
		return # ファイルがない場合は処理を中断

	# 2. FileAccess を使ってファイルを開く (読み取りモード)
	var file = FileAccess.open(CHORD_DATA_PATH, FileAccess.READ)

	# 3. ファイルオープンに成功したか確認
	if file == null:
		# エラーコードを取得して表示
		var error_code = FileAccess.get_open_error()
		printerr("エラー: ファイルを開けませんでした。パス: ", CHORD_DATA_PATH, " エラーコード: ", error_code)
		return # ファイルが開けない場合は処理を中断

	# 4. ファイルの内容を全てテキストとして読み込む
	var content = file.get_as_text()

	# 5. ファイルを閉じる (重要！)
	#   ファイルを使い終わったら必ず閉じてください。
	file.close()

	# 6. JSONクラスのインスタンスを作成
	var json = JSON.new()

	# 7. 読み込んだテキストをパース（解析）する
	var error = json.parse(content)

	# 8. パースエラーの確認
	if error != OK:
		printerr("エラー: JSONデータのパースに失敗しました。")
		printerr("エラーメッセージ: ", json.get_error_message())
		printerr("エラー発生行: ", json.get_error_line())
		return # パースに失敗した場合は処理を中断

	# 9. パース結果（GDScriptのデータ型、この場合はDictionary）を取得
	var data = json.get_data()

	# 10. 取得したデータがDictionaryであることを念のため確認
	if typeof(data) == TYPE_DICTIONARY:
		# メンバー変数に格納
		chord_data = data
	else:
		printerr("エラー: JSONデータが期待されるDictionary形式ではありません。")
		# 必要であれば chord_data を空にするなどの処理
		chord_data = {}
