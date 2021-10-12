extends Spatial
class_name Player

export var max_run_speed := 2.0
export var max_jump_speed := 15.0
export var max_fall_speed := 25.0
export var x_accel := 0.08
export var jump_accel := 2.0
export var fall_accel := 0.6
export var turn_speed := 0.05
var x_speed := 0.0
var y_speed := 0.0
var dir := Vector3(0,-1,0)

onready var body = $Collision/KinematicBody

func get_dir():
	dir = Vector3(0, dir.y, 0)
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		dir.x += 1
	if Input.is_action_just_pressed("ui_accept") and body.is_on_floor():
		dir.y = 1

func set_current_speed():
	# controls x speed when accelerating/deaccelerating
	if not dir.x == 0:
		x_speed = max(-1.0, min(1.0, x_speed + x_accel * dir.x))
	else:
		x_speed = max(0, abs(x_speed) - x_accel) * (1 if x_speed > 0 else -1)
	
	# resets y speed (constant force downard is requires for on floor to function)
	if body.is_on_floor():
		y_speed = 0
	
	if dir.y == 1.0:
		y_speed = min(max_jump_speed, y_speed + jump_accel)
	elif dir.y == -1.0:
		y_speed = max(-max_fall_speed, y_speed - fall_accel)
	
	# switches dir when jump peak is reached
	if y_speed == max_jump_speed:
		dir.y = -1

func animate():
	print(dir)
	# rotates skeleton to dir
	if not dir.x == 0:
		$Tween.stop_all()
		$Tween.interpolate_property($PolliwogKing/Skeleton, "rotation_degrees:y", $PolliwogKing/Skeleton.rotation_degrees.y, (90*dir.x)-90 , turn_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
	if dir.y == 1.0:
		$AnimationTree.set("parameters/StateMachine/conditions/falling", false)
		$AnimationTree.set("parameters/StateMachine/conditions/grounded", false)
		$AnimationTree.set("parameters/StateMachine/conditions/jumping", true)
	elif dir.y == -1.0:
		$AnimationTree.set("parameters/StateMachine/conditions/jumping", false)
		$AnimationTree.set("parameters/StateMachine/conditions/grounded", false)
		$AnimationTree.set("parameters/StateMachine/conditions/falling", true)
	if body.is_on_floor():
		$AnimationTree.set("parameters/StateMachine/conditions/jumping", false)
		$AnimationTree.set("parameters/StateMachine/conditions/falling", false)
		$AnimationTree.set("parameters/StateMachine/conditions/grounded", true)
	$AnimationTree.set("parameters/StateMachine/BlendTree/x_speed/blend_amount", abs(x_speed))

func _physics_process(delta: float):
	body.move_and_slide(Vector3(max_run_speed * x_speed, y_speed, 0), Vector3.UP)
	get_dir()
	set_current_speed()
	global_transform.origin = body.global_transform.origin
	animate()
