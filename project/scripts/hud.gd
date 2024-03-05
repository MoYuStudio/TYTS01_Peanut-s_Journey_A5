
extends CanvasLayer

func _on_health_updated(health):
	$HealthBar.value = health
	# 假设血条的最大值是100
	var max_health = $HealthBar.max_value
	var health_percentage = health / max_health

	# 从绿色（健康）到红色（危险）的线性过渡
	var start_color = Color(0, 1, 0)  # 绿色
	var end_color = Color(1, 0, 0)  # 红色
	
	var current_color = start_color.lerp(end_color, 1 - health_percentage)

	# 使用linear_interpolate进行颜色插值
	$HealthBar.set_tint_progress(Color(current_color))
	
	$AnimationPlayer.play("HurtFilter")

func _on_player_weapon_change(weapon):
	print(weapon)
	$WeaponSprite.texture = load("res://models/render/"+weapon+".png")
