extends Node3D

@export var player: Node3D

@onready var raycast = $RayCast
@onready var muzzle_a = $MuzzleA
@onready var muzzle_b = $MuzzleB

var health := 100
var time := 0.0
var target_position: Vector3
var destroyed := false

# 准备好后，保存初始位置

func _ready():
	target_position = position


func _process(delta):
	self.look_at(player.position + Vector3(0, 0.5, 0), Vector3.UP, true)  # 看向玩家
	target_position.y += (cos(time * 5) * 1) * delta  # 正弦运动（上下）

	time += delta

	position = target_position

# 受到玩家的伤害

func damage(amount):
	Audio.play("sounds/enemy_hurt.ogg")

	health -= amount

	if health <= 0 and !destroyed:
		destroy()

# 健康状况不佳时消灭敌人

func destroy():
	Audio.play("sounds/enemy_destroy.ogg")

	destroyed = true
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

			collider.damage(3)  # 对玩家造成伤害
