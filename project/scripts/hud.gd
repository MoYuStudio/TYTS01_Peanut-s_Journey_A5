
extends CanvasLayer

func _on_health_updated(health):
	$HealthBar.value = health
