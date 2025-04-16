extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Key_A3.set_freq(220.00)   # A3 (ラ) - A4の1オクターブ下
	$Key_As3.set_freq(233.08)  # A#3 / Bb3 (ラ# / シ♭)
	$Key_B3.set_freq(246.94)   # B3 (シ)
	$Key_C4.set_freq(261.63)   # C4 (ド)
	$Key_Cs4.set_freq(277.18)  # C#4 / Db4 (ド# / レ♭)
	$Key_D4.set_freq(293.66)   # D4 (レ)
	$Key_Ds4.set_freq(311.13)  # D#4 / Eb4 (レ# / ミ♭)
	$Key_E4.set_freq(329.63)   # E4 (ミ)
	$Key_F4.set_freq(349.23)   # F4 (ファ)
	$Key_Fs4.set_freq(369.99)  # F#4 / Gb4 (ファ# / ソ♭)
	$Key_G4.set_freq(392.00)   # G4 (ソ)
	$Key_Gs4.set_freq(415.30)  # G#4 / Ab4 (ソ# / ラ♭)
	$Key_A4.set_freq(440.00)   # A4 (ラ) - 基準周波数
	$Key_As4.set_freq(466.16)  # A#4 / Bb4 (ラ# / シ♭)
	$Key_B4.set_freq(493.88)   # B4 (シ)
	$Key_C5.set_freq(523.25)   # C5 (ド) - 中央ド


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
