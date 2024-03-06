
extends CharacterBody3D

@onready var player = get_parent().get_parent().get_node("Player")
@onready var falling_object_scene = preload("res://objects/integral.tscn")

@onready var raycast = $RayCast
@onready var muzzle_a = $MuzzleA
@onready var muzzle_b = $MuzzleB

@onready var nav = $NavigationAgent3D

var health := 100
var time := 0.0
var destroyed := false

var move_speed := 3.0  # 敌人每秒移动的单位数
var move_accel = 30

func _physics_process(delta):
	self.look_at(player.position + Vector3(0, 0, 0), Vector3.UP, true)  # 看向玩家
	# target_position.y += (cos(time * 5) * 1) * delta  # 正弦运动（上下）
	
	# 向玩家移动
	var direction = Vector3()
	nav.target_position = player.position
	
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	
	velocity = velocity.lerp(direction * move_speed, move_accel * delta)
	move_and_slide()

	time += delta

# 受到玩家的伤害

func damage(amount):
	# Audio.play("sounds/enemy_hurt.ogg")

	health -= amount

	if health <= 0 and !destroyed:
		destroy()

# 健康状况不佳时消灭敌人

func destroy():
	Audio.play("sounds/enemy_destroy.ogg")

	destroyed = true
	
	var falling_object = falling_object_scene.instantiate()
	falling_object.position = position
	get_parent().add_child(falling_object)
	
	queue_free()

# 当计时器达到 0 时射击

func _on_timer_timeout():
	raycast.force_raycast_update()

	if raycast.is_colliding():
		var collider = raycast.get_collider()

		if collider.has_method("damage"):  # Raycast 与玩家碰撞
			
			# 播放枪口闪光动画

			muzzle_a.frame = 0
			muzzle_a.play("default")
			muzzle_a.rotation_degrees.z = randf_range(-45, 45)

			muzzle_b.frame = 0
			muzzle_b.play("default")
			muzzle_b.rotation_degrees.z = randf_range(-45, 45)

			Audio.play("sounds/enemy_attack.ogg")

			# collider.damage(3)  # 对玩家造成伤害
			# 增加子弹散布
			# 为射击方向添加随机偏移
			var spread_range = 5.0  # 定义散布范围
			var random_offset = Vector3(randf_range(-spread_range, spread_range), randf_range(-spread_range, spread_range), randf_range(-spread_range, spread_range))

			if raycast.is_colliding():
				var hit_collider = raycast.get_collider()
				if hit_collider.has_method("damage"):
					hit_collider.damage(3)  # 再次对玩家造成伤害，如果仍然是玩家
