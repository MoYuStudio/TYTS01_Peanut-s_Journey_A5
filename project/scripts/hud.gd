
extends CanvasLayer

func _on_health_updated(health):
	$HealthBar.value = health
	$AnimationPlayer.play("HurtFilter")

func _on_player_weapon_change(weapon):
	print(weapon)
	$WeaponSprite.texture = load("res://models/render/"+weapon+".png")
