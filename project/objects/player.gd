extends CharacterBody3D

@export_subgroup("Properties") # 特性组
@export var movement_speed = 6
@export var jump_strength = 9

@export_subgroup("Weapons") # 武器组
@export var weapons: Array[Weapon] = []

var weapon: Weapon
var weapon_index := 1

var mouse_sensitivity = 700
var gamepad_sensitivity := 0.075

var mouse_captured := true

var movement_velocity: Vector3
var rotation_target: Vector3

var input_mouse: Vector2

var health:int = 100
var gravity := 0.0

var previously_floored := false

var jump_single := true
var jump_double := true

var container_offset = Vector3(0, -0.8, -2.9)
# 腰射 Vector3(1.2, -1.1, -2.75) 举镜 Vector3(0, -0.8, -2.75)

var tween:Tween

signal health_updated

signal weapon_change

@onready var camera = $Head/Camera
@onready var raycast = $Head/Camera/RayCast
@onready var muzzle = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/Muzzle
@onready var container = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/Container
@onready var sound_footsteps = $SoundFootsteps
@onready var blaster_cooldown = $Cooldown

@export var crosshair:TextureRect

# 功能

func _ready():
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	weapon = weapons[weapon_index] # 武器绝不能为零
	initiate_change_weapon(weapon_index)

func _physics_process(delta):
	
	# 手柄功能
	
	handle_controls(delta)
	handle_gravity(delta)
	
	# 移动

	var applied_velocity: Vector3
	
	movement_velocity = transform.basis * movement_velocity # Move forward
	
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	
	velocity = applied_velocity
	move_and_slide()
	
	# 旋转
	
	camera.rotation.z = lerp_angle(camera.rotation.z, -input_mouse.x * 25 * delta, delta * 5)	
	
	camera.rotation.x = lerp_angle(camera.rotation.x, rotation_target.x, delta * 25)
	rotation.y = lerp_angle(rotation.y, rotation_target.y, delta * 25)
	
	container.position = lerp(container.position, container_offset - (basis.inverse() * applied_velocity / 30), delta * 10)
	
	# 移动声音
	
	sound_footsteps.stream_paused = true
	
	if is_on_floor():
		if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			sound_footsteps.stream_paused = false
	
	# 跳跃或坠落后着陆
	
	camera.position.y = lerp(camera.position.y, 0.0, delta * 5)
	
	if is_on_floor() and gravity > 1 and !previously_floored: # 着陆
		Audio.play("sounds/land.ogg")
		camera.position.y = -0.1
	
	previously_floored = is_on_floor()
	
	# 掉落/重生
	
	if position.y < -10:
		get_tree().reload_current_scene()

# 鼠标移动

func _input(event):
	if event is InputEventMouseMotion and mouse_captured:
		
		input_mouse = event.relative / mouse_sensitivity
		
		rotation_target.y -= event.relative.x / mouse_sensitivity
		rotation_target.x -= event.relative.y / mouse_sensitivity

func handle_controls(_delta):
	
	# 鼠标捕捉
	
	if Input.is_action_just_pressed("mouse_capture"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse_captured = true
	
	if Input.is_action_just_pressed("mouse_capture_exit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_captured = false
		
		input_mouse = Vector2.ZERO
	
	# 移动
	
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	movement_velocity = Vector3(input.x, 0, input.y).normalized() * movement_speed
	
	# 旋转
	
	var rotation_input := Input.get_vector("camera_right", "camera_left", "camera_down", "camera_up")
	
	rotation_target -= Vector3(-rotation_input.y, -rotation_input.x, 0).limit_length(1.0) * gamepad_sensitivity
	rotation_target.x = clamp(rotation_target.x, deg_to_rad(-90), deg_to_rad(90))
	
	# 射击
	
	action_shoot()
	
	# 跳跃
	
	if Input.is_action_just_pressed("jump"):
		
		if jump_single or jump_double:
			Audio.play("sounds/jump_a.ogg, sounds/jump_b.ogg, sounds/jump_c.ogg")
		
		if jump_double:
			
			gravity = -jump_strength
			jump_double = false
			
		if(jump_single): action_jump()
		
	# 武器切换
	
	action_weapon_toggle()

# 手柄重力

func handle_gravity(delta):
	
	gravity += 20 * delta
	
	if gravity > 0 and is_on_floor():
		
		jump_single = true
		gravity = 0

# 跳跃

func action_jump():
	
	gravity = -jump_strength
	
	jump_single = false;
	jump_double = true;

# 射击

func action_shoot():
	
	if Input.is_action_pressed("shoot"):
	
		if !blaster_cooldown.is_stopped(): return # 射击冷却时间
		
		Audio.play(weapon.sound_shoot)
		
		container.position.z += 0.25 # 武器视觉击退
		camera.rotation.x += 0.025 # 相机的击退
		movement_velocity += Vector3(0, 0, weapon.knockback) # 击退
		
		# 设置枪口闪光位置，播放动画
		
		muzzle.play("default")
		
		muzzle.rotation_degrees.z = randf_range(-45, 45)
		muzzle.scale = Vector3.ONE * randf_range(0.40, 0.75)
		muzzle.position = container.position - weapon.muzzle_position # 火光补偿
		muzzle.position.x -= -0.1
		muzzle.position.y -= -0.1
		
		blaster_cooldown.start(weapon.cooldown)
		
		# 射击武器，数量根据射击次数而定
		
		for n in weapon.shot_count:
		
			raycast.target_position.x = randf_range(-weapon.spread, weapon.spread)
			raycast.target_position.y = randf_range(-weapon.spread, weapon.spread)
			
			raycast.force_raycast_update()
			
			if !raycast.is_colliding(): continue # 当光线投射未击中时不产生影响
			
			var collider = raycast.get_collider()
			
			# 击中敌人
			
			if collider.has_method("damage"):
				collider.damage(weapon.damage)
				Audio.play(weapon.sound_hit)
			
			# 创建冲击动画
			
			var impact = preload("res://objects/impact.tscn")
			var impact_instance = impact.instantiate()
			
			impact_instance.emitting = true
			
			get_tree().root.add_child(impact_instance)
			
			impact_instance.position = raycast.get_collision_point() + (raycast.get_collision_normal() / 10)
			impact_instance.look_at(camera.global_transform.origin, Vector3.UP, true) 

# 在可用武器之间切换（在“武器”中列出）

func action_weapon_toggle():
	
	if Input.is_action_just_pressed("weapon_toggle"):
		
		weapon_index = wrap(weapon_index + 1, 0, weapons.size())
		initiate_change_weapon(weapon_index)
		
		Audio.play("sounds/weapon_change.ogg")

# 启动武器更换动画（渐变）

func initiate_change_weapon(index):
	
	weapon_index = index
	
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(container, "position", container_offset - Vector3(0, 1, 0), 0.1)
	tween.tween_callback(change_weapon) # 改变模型

# 切换武器模型（屏幕外）

func change_weapon():
	
	weapon = weapons[weapon_index]

	# 步骤 1. 从容器中取出以前的武器模型
	
	for n in container.get_children():
		container.remove_child(n)
	
	# 步骤 2. 将新武器模型放入容器中
	
	var weapon_model = weapon.model.instantiate()
	container.add_child(weapon_model)
	
	weapon_model.position = weapon.position
	weapon_model.rotation_degrees = weapon.rotation
	
	# 步骤 3. 将模型设置为仅在第 2 层（武器摄像机）上渲染
	
	for child in weapon_model.find_children("*", "MeshInstance3D"):
		child.layers = 2
		
	# 设置武器数据
	
	raycast.target_position = Vector3(0, 0, -1) * weapon.max_distance
	crosshair.texture = weapon.crosshair
	
	weapon_change.emit(weapon.name)

func damage(amount):
	
	health -= amount
	health_updated.emit(health) # 更新 HUD 上的健康状况
	
	if health < 0:
		get_tree().reload_current_scene() # 健康状况不佳时重置
