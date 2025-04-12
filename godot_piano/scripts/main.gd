extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Key_A3.set_freq(220.00)   # A3 (ラ) - A4の1オクターブ下
	$Key_As3.set_freq(233.08)  # A#3 / Bb3 (ラ# / シ♭)
	$Key_B3.set_freq(246.94)   # B3 (シ)
	$Key_C4.set_freq(261.63)   # C4 (ド)
	$Key_D4.set_freq(293.66)   # D4 (レ)
	$Key_E4.set_freq(329.63)   # E4 (ミ)
	$Key_F4.set_freq(349.23)   # F4 (ファ)
	$Key_G4.set_freq(392.00)   # G4 (ソ)
	$Key_A4.set_freq(440.00)   # A4 (ラ) - 基準周波数
	$Key_B4.set_freq(493.88)   # B4 (シ)
	$Key_C5.set_freq(523.25)   # C5 (ド) - 中央ド (既に設定済み)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
