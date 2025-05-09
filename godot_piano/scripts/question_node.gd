extends Node2D

var code_manager=null

var current_chord=null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	code_manager=get_node_or_null("../CodeManager")

	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func select_chord() -> void:
	
	# 0から23の中から数字をランダムに選ぶ
	var random_index: int = randi() % 24

	# code_managerからコードを選んでくる

	if code_manager.has_method("get_chord_by_index")  == false:
		current_chord=null
		return


	var chord_data_pair=code_manager.get_chord_by_index(random_index)

	# コード名
	current_chord=chord_data_pair[0]

	# 音
	print(chord_data_pair[1]["notes"])

# Question Buttonが押されたとき
func _on_button_pressed() -> void:
	select_chord()
	$Question.text=str(current_chord)
