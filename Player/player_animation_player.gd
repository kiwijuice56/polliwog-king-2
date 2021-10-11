extends AnimationPlayer
class_name PlayerAnimationPlayer

func set_animation(dir: Vector3):
	if dir.length() == 0:
		current_animation = "[stop]"
	else:
		current_animation = "run-loop"
