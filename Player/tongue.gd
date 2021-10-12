extends Spatial
class_name Tongue

export var distance := 1.0
export var spit_time := 1.0

var returning := false

func _ready():
	$Tween.connect("tween_completed", self, "tween_completed")

func tween_completed(_object: Object, _key: NodePath):
	$Tween.stop_all()
	if not returning:
		returning = true
		$Tween.interpolate_property($Tip, "translation:z", $Tip.translation.z, 0, spit_time/2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.interpolate_property($Cylinder, "translation:z", $Cylinder.translation.z, 0, spit_time/2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.interpolate_property($Cylinder, "scale:y", $Cylinder.scale.y, 0, spit_time/2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.start()
	else:
		returning = false
		visible = false

func spit():
	visible = true
	$Tween.stop_all()
	$Tween.interpolate_property($Tip, "translation:z", $Tip.translation.z, distance, spit_time/2, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.interpolate_property($Cylinder, "translation:z", $Cylinder.translation.z, distance/2, spit_time/2, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.interpolate_property($Cylinder, "scale:y", 0, distance, spit_time/2, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()
