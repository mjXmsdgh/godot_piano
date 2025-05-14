extends Node2D

var code_manager=null
var current_chord=null
var current_chord_notes=[]
var pressed_chord=[]
var kenban=null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	code_manager=get_node_or_null("../CodeManager")

	kenban=get_node_or_null("../kenban")

	for key_child in kenban.get_children():
		if key_child.has_signal("key_pressed"):
			key_child.key_pressed.connect(Callable(self,"_on_key_pressed_received"))



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
	current_chord_notes=chord_data_pair[1]["notes"]



# Question Buttonが押されたとき
func _on_button_pressed() -> void:
	select_chord()
	$Question.text=str(current_chord)

	pressed_chord.clear()



func check():
	
	if pressed_chord.size()<3:
		return


	var sorted_pressed=pressed_chord.duplicate()
	sorted_pressed.sort()
	var sorted_target=current_chord_notes.duplicate()
	sorted_target.sort()

	if sorted_pressed==sorted_target:
		print("OK")
	else:
		print("NG")


			


# key.gd から key_pressed シグナルを受信したときに呼び出される関数
func _on_key_pressed_received(pressed_key_name: String) -> void:

	pressed_chord.append(pressed_key_name)

	check()


func _on_answer_pressed() -> void:
	print("answer")
	pass # Replace with function body.
