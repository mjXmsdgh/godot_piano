extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Key_A.set_freq(440)
	$Key_B.set_freq(493.88)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
