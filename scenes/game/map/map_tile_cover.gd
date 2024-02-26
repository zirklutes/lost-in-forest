extends Area2D


func _on_body_entered(_body):
	var tween = create_tween()
	
	tween.tween_property(self, 'modulate:a', 0, 0.5).set_ease(Tween.EASE_OUT)
	await tween.finished
	queue_free()
