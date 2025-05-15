extends Node2D

# 各鍵盤ノードを音名と関連付けて格納するための辞書
var notes: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Key_A3.set_freq(220.00)   # A3 (ラ) - A4の1オクターブ下
	$Key_A3.set_keyname("A3")
	notes["A3"] = $Key_A3

	$Key_As3.set_freq(233.08)  # A#3 / Bb3 (ラ# / シ♭)
	$Key_As3.set_keyname("A#3")
	notes["A#3"] = $Key_As3

	$Key_B3.set_freq(246.94)   # B3 (シ)
	$Key_B3.set_keyname("B3")
	notes["B3"] = $Key_B3
	
	$Key_C4.set_freq(261.63)   # C4 (ド)
	$Key_C4.set_keyname("C4")
	notes["C4"] = $Key_C4

	$Key_Cs4.set_freq(277.18)  # C#4 / Db4 (ド# / レ♭)
	$Key_Cs4.set_keyname("C#4")
	notes["C#4"] = $Key_Cs4

	$Key_D4.set_freq(293.66)   # D4 (レ)
	$Key_D4.set_keyname("D4")
	notes["D4"] = $Key_D4

	$Key_Ds4.set_freq(311.13)  # D#4 / Eb4 (レ# / ミ♭)
	$Key_Ds4.set_keyname("D#4")
	notes["D#4"] = $Key_Ds4

	$Key_E4.set_freq(329.63)   # E4 (ミ)
	$Key_E4.set_keyname("E4")
	notes["E4"] = $Key_E4

	$Key_F4.set_freq(349.23)   # F4 (ファ)
	$Key_F4.set_keyname("F4")
	notes["F4"] = $Key_F4

	$Key_Fs4.set_freq(369.99)  # F#4 / Gb4 (ファ# / ソ♭)
	$Key_Fs4.set_keyname("F#4")
	notes["F#4"] = $Key_Fs4

	$Key_G4.set_freq(392.00)   # G4 (ソ)
	$Key_G4.set_keyname("G4")
	notes["G4"] = $Key_G4

	$Key_Gs4.set_freq(415.30)  # G#4 / Ab4 (ソ# / ラ♭)
	$Key_Gs4.set_keyname("G#4")
	notes["G#4"] = $Key_Gs4

	$Key_A4.set_freq(440.00)   # A4 (ラ) - 基準周波数
	$Key_A4.set_keyname("A4")
	notes["A4"] = $Key_A4


	$Key_As4.set_freq(466.16)  # A#4 / Bb4 (ラ# / シ♭)
	$Key_As4.set_keyname("A#4")
	notes["A#4"] = $Key_As4

	$Key_B4.set_freq(493.88)   # B4 (シ)
	$Key_B4.set_keyname("B4")
	notes["B4"] = $Key_B4

	$Key_C5.set_freq(523.25)   # C5 (ド) - 中央ド
	$Key_C5.set_keyname("C5")
	notes["C5"] = $Key_C5

	$Key_Cs5.set_freq(554.37)  # C#5 / Db5 (ド# / レ♭)
	$Key_Cs5.set_keyname("C#5")
	notes["C#5"] = $Key_Cs5

	$Key_D5.set_freq(587.33)   # D5 (レ)
	$Key_D5.set_keyname("D5")
	notes["D5"] = $Key_D5


	$Key_Ds5.set_freq(622.25)  # D#5 / Eb5 (レ# / ミ♭)
	$Key_Ds5.set_keyname("D#5")
	notes["D#5"] = $Key_Ds5

	$Key_E5.set_freq(659.26)   # E5 (ミ)
	$Key_E5.set_keyname("E5")
	notes["E5"] = $Key_E5

	$Key_F5.set_freq(698.46)   # F5 (ファ)
	$Key_F5.set_keyname("F5")
	notes["F5"] = $Key_F5

	$Key_Fs5.set_freq(739.9)
	$Key_Fs5.set_keyname("F#5")
	notes["F#5"] = $Key_Fs5

	$Key_G5.set_freq(783.99)   # G5 (ソ) - 中央ソ
	$Key_G5.set_keyname("G5")
	notes["G5"] = $Key_G5

	

func play_note(note_name: String) -> void:
	var key_nodes=notes[note_name]
	key_nodes.play_sound()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
