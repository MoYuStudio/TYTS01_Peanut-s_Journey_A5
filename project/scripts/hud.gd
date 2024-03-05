
extends CanvasLayer

func _on_health_updated(health):
	$HealthBar.value = health
	# 假设血条的最大值是100
	var max_health = $HealthBar.max_value
	var health_percentage = health / max_health

	# 定义颜色
	var start_color = Color(0, 1, 0)  # 绿色
	var mid_color = Color(1, 1, 0)    # 黄色
	var end_color = Color(1, 0, 0)    # 红色

	var current_color = Color()

	# 根据血量百分比确定颜色
	if health_percentage > 0.5:
		# 当血量大于50%，从绿色过渡到黄色
		var adjusted_percentage = (health_percentage - 0.5) * 2  # 重新映射到0-1的范围
		current_color = start_color.lerp(mid_color, 1 - adjusted_percentage)
	else:
		# 当血量低于或等于50%，从黄色过渡到红色
		var adjusted_percentage = health_percentage * 2  # 重新映射到0-1的范围
		current_color = mid_color.lerp(end_color, 1 - adjusted_percentage)

	# 使用linear_interpolate进行颜色插值
	$HealthBar.set_tint_progress(Color(current_color))
	
	$AnimationPlayer.play("HurtFilter")

func _on_player_weapon_change(weapon):
	print(weapon)
	$WeaponSprite.texture = load("res://models/render/"+weapon+".png")
