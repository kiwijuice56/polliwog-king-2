extends Spatial
class_name Tongue

export var distance := 1.0
export var spit_time := 1.0
export var turn_head_time := 0.25
onready var anim = get_node("../../../../AnimationTree")
onready var skeleton = get_node("../../")

var returning := false

func _ready():
	$Tween.connect("tween_completed", self, "tween_completed")

func tween_completed(_object: Object, key: NodePath):
	if not key == ":translation:z":
		return
	$Tween.stop_all()
	if not returning:
		returning = true
		$Tween.interpolate_property($Tip, "translation:z", $Tip.translation.z, 0, spit_time/2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.interpolate_property($Cylinder, "translation:z", $Cylinder.translation.z, 0, spit_time/2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.interpolate_property($Cylinder, "scale:y", $Cylinder.scale.y, 0, spit_time/2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.start()
	else:
		visible = false
		returning = false
		$Tween.interpolate_property(anim, "parameters/eat_transition/blend_amount", 1, 0, turn_head_time, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.start()

func spit():
	visible = true
	global_transform.origin.x = (skeleton.global_transform * skeleton.get_bone_global_pose(10)).origin.x
	global_transform.origin.z = (skeleton.global_transform * skeleton.get_bone_global_pose(10)).origin.z
	$Tween.stop_all()
	$Tween.interpolate_property($Tip, "translation:z", $Tip.translation.z, distance, spit_time/2, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.interpolate_property($Cylinder, "translation:z", $Cylinder.translation.z, distance/2, spit_time/2, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.interpolate_property($Cylinder, "scale:y", 0, distance, spit_time/2, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.interpolate_property(anim, "parameters/eat_transition/blend_amount", 0, 1, turn_head_time, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()

func _process(_delta):
	if visible:
		global_transform.origin.y = (skeleton.global_transform * skeleton.get_bone_global_pose(10)).origin.y
