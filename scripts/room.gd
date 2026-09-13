extends Node2D

# 房屋背景图片路径
const BACKGROUND_PATH: String = "res://assets/ui/house_main.png"

@onready var background: Sprite2D = $Background
@onready var cat_spawn: Marker2D = $CatSpawn
@onready var cat_container: Node2D = $Cat
@onready var floor1_nav: NavigationRegion2D = $Navigation/Floor1Navigation
@onready var floor2_nav: NavigationRegion2D = $Navigation/Floor2Navigation

func _ready() -> void:
	_setup_background()
	_spawn_cat()

func _setup_background() -> void:
	if ResourceLoader.exists(BACKGROUND_PATH):
		background.texture = load(BACKGROUND_PATH)

		# 设置背景适配屏幕
		var window_size: Vector2 = get_viewport_rect().size
		var texture_size: Vector2 = background.texture.get_size()

		# 计算缩放比例，保持宽高比
		var scale_x: float = window_size.x / texture_size.x
		var scale_y: float = window_size.y / texture_size.y
		var scale: float = max(scale_x, scale_y)

		background.scale = Vector2(scale, scale)

		# 居中背景
		background.position = window_size / 2

func _spawn_cat() -> void:
	# 实例化猫咪场景
	var cat_scene: PackedScene = preload("res://scenes/cat.tscn")
	var cat_instance: Node2D = cat_scene.instantiate()

	# 设置猫咪位置到出生点
	cat_instance.position = cat_spawn.position

	# 添加到 Cat 容器
	cat_container.add_child(cat_instance)
