
extends Resource
class_name Weapon

@export_subgroup("Model")
@export var name: String # 武器名称
@export var model: PackedScene  # 武器模型
@export var position: Vector3  # 屏幕上的位置
@export var rotation: Vector3  # 屏幕上的旋转
@export var muzzle_position: Vector3  # 枪口火焰在屏幕上的位置

@export_subgroup("Properties")
@export_range(0.1, 1) var cooldown: float = 0.1  # 射速
@export_range(1, 1000) var max_distance: int = 10  # 射程
@export_range(0, 100) var damage: float = 25  # 每击伤害
@export_range(0, 5) var spread: float = 0  # 每次散布
@export_range(1, 5) var shot_count: int = 1  # 每次激发数
@export_range(0, 50) var knockback: float = 20  # 每次击退量

@export_subgroup("Sounds")
@export var sound_shoot: String  # 声音文件路径

@export_subgroup("Crosshair")
@export var crosshair: Texture2D  # 屏幕上十字准线的图像
