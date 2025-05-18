extends Control

signal ready_go_end()

func init_ready_go() -> void:
	show()
	%ReadyGoTimer.start()
	%AnimationPlayer.play("ReadyGoAnim")

func _process(_delta: float) -> void:
	%ReadyProgress.value = %ReadyGoTimer.time_left / %ReadyGoTimer.wait_time

func _on_ready_go_timer_timeout() -> void:
	ready_go_end.emit()
	hide()
