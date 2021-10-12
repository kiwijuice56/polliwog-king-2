extends Spatial
class_name Player

export var max_run_speed := 2.0
export var max_backward_run_speed := 1.0
export var max_jump_speed := 15.0
export var max_fall_speed := 25.0
export var run_accel := 0.08
export var backward_run_accel := 0.04
export var jump_accel := 2.0
export var fall_accel := 0.6
export var turn_speed := 0.05
export var spit_delay := 1.0
var speed := Vector2()
var dir := Vector3(1,-1,0)
var look_dir := Vector3(1,0,0)
var spitting := false

onready var body = $Collision/KinematicBody
onready var tongue = $PolliwogKing/Skeleton/Body/Tongue
onready var anim = $AnimationTree

func _ready():
	$Timer.connect("timeout", self, "reset_tongue")

func reset_tongue():
	spitting = false

func set_dir():
	dir = Vector3(0, dir.y, 0)
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		dir.x += 1
	if Input.is_action_just_pressed("ui_accept") and body.is_on_floor():
		dir.y = 1
	if Input.is_action_just_pressed("ui_accept2") and not spitting:
		spitting = true
		tongue.spit()
		$Timer.start(spit_delay)

func set_look_dir():
	if not spitting and not dir.x == 0:
		look_dir.x = dir.x

func set_speed():
	# controls x speed when accelerating/deaccelerating
	if not dir.x == 0:
		if spitting and not dir.x == look_dir.x:
			speed.x = clamp(speed.x + backward_run_accel * dir.x, -max_backward_run_speed, max_backward_run_speed)
		else:
			speed.x = clamp(speed.x + run_accel * dir.x, -max_run_speed, max_run_speed)
	else:
		speed.x = max(0, abs(speed.x) - run_accel) * (-1 if speed.x < 0 else 1)
	
	# resets y speed (constant force downard is requires for on_floor() to function)
	if body.is_on_floor():
		speed.y = 0
	if dir.y == 1.0:
		speed.y  = min(max_jump_speed, speed.y + jump_accel)
	elif dir.y == -1.0:
		speed.y  = max(-max_fall_speed, speed.y - fall_accel)
	
	# switches dir.y when jump peak is reached
	if speed.y == max_jump_speed:
		dir.y = -1

func animate():
	# rotates skeleton to dir
	if not dir.x == 0:
		$Tween.stop_all()
		$Tween.interpolate_property($PolliwogKing/Skeleton, "rotation_degrees:y", $PolliwogKing/Skeleton.rotation_degrees.y, (90*look_dir.x)-90 , turn_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
	# switches state in animation tree state machine
	if dir.y == 1.0:
		anim.set("parameters/StateMachine/conditions/falling", false)
		anim.set("parameters/StateMachine/conditions/jumping", true)
	elif dir.y == -1.0:
		anim.set("parameters/StateMachine/conditions/jumping", false)
		anim.set("parameters/StateMachine/conditions/grounded", false)
		anim.set("parameters/StateMachine/conditions/falling", true)
	if body.is_on_floor():
		anim.set("parameters/StateMachine/conditions/falling", false)
		anim.set("parameters/StateMachine/conditions/grounded", true)
	anim.set("parameters/StateMachine/BlendTree/x_speed/blend_amount", abs(speed.x/max_run_speed))

func _physics_process(_delta: float):
	body.move_and_slide(Vector3(speed.x, speed.y, 0), Vector3.UP)
	set_look_dir()
	set_dir()
	set_speed()
	global_transform.origin = body.global_transform.origin
	animate()
