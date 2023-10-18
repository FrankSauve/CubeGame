extends Label


func start(point_value: int, pos: Vector2):
	position = pos
	
	if point_value > 0:
		text = "+" + str(point_value)
	else:
		text = str(point_value)
		modulate = Color(Color.RED)
	
	var tween = create_tween()
	tween.tween_property(self, "position", pos + Vector2(0, -50), 0.5)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_callback(queue_free)
