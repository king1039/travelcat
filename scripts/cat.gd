extends CharacterBody2D

# 猫咪显示高度（可在 Inspector 调整）
@export var desired_cat_height: float = 70.0

# 移动速度
@export var move_speed: float = 45.0

# 等待时间范围
@export var min_idle_time: float = 1.5
@export var max_idle_time: float = 4.0

# 临时测试移动区域
@export var test_walk_area: Rect2 = Rect2(100, 650, 520, 350)

# 状态
enum State { IDLE, WALKING }
var current_state: State = State.IDLE
var idle_timer: float = 0.0
var target_position: Vector2 = Vector2.ZERO

# 组件引用
@onready var sprite: AnimatedSprite2D = $CatSprite

func _ready() -> void:
	# 根据猫咪类型设置动画
	var cat_id: String = GameState.selected_cat_id
	if cat_id.is_empty():
		cat_id = "orange"

	if cat_id == "tabby":
		_setup_tabby_animations()
	else:
		_setup_default_animations(cat_id)

	# 开始等待
	_start_idle()

func _setup_tabby_animations() -> void:
	var frames := SpriteFrames.new()

	# idle 动画 - 使用静态狸花猫图片
	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 1.0)
	var idle_texture: Texture2D = load("res://assets/cats/tabby.png")
	if idle_texture != null:
		frames.add_frame("idle", idle_texture)

	# walk_side 动画 - 加载 8 帧横向走路
	frames.add_animation("walk_side")
	frames.set_animation_loop("walk_side", true)
	frames.set_animation_speed("walk_side", 8.0)

	# 依次加载 8 帧动画
	for i in range(1, 9):
		var path: String = "res://assets/tabby_move/tabby_move_%d.png" % i
		var texture: Texture2D = load(path)
		if texture != null:
			frames.add_frame("walk_side", texture)

	# 设置 SpriteFrames
	sprite.sprite_frames = frames
	sprite.animation = "idle"

	# 统一缩放 - 使用第一帧计算
	var first_texture: Texture2D = load("res://assets/tabby_move/tabby_move_1.png")
	if first_texture != null:
		var texture_height: float = first_texture.get_size().y
		var visual_scale: float = desired_cat_height / texture_height
		sprite.scale = Vector2(visual_scale, visual_scale)

	# 固定 position，避免动画播放时位置抖动
	sprite.position = Vector2(0, desired_cat_height / 2.0)

func _setup_default_animations(cat_id: String) -> void:
	var frames := SpriteFrames.new()

	# idle 动画 - 使用单帧静态图片
	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 1.0)

	var sprite_path: String = "res://assets/cats/" + cat_id + ".png"
	if ResourceLoader.exists(sprite_path):
		var texture: Texture2D = load(sprite_path)
		frames.add_frame("idle", texture)

	# walk_side 暂时使用同一张图
	frames.add_animation("walk_side")
	frames.set_animation_loop("walk_side", true)
	frames.set_animation_speed("walk_side", 8.0)
	if ResourceLoader.exists(sprite_path):
		frames.add_frame("walk_side", load(sprite_path))

	# walk_up / walk_down 暂时也用同一张
	frames.add_animation("walk_up")
	frames.set_animation_loop("walk_up", true)
	frames.set_animation_speed("walk_up", 8.0)
	if ResourceLoader.exists(sprite_path):
		frames.add_frame("walk_up", load(sprite_path))

	frames.add_animation("walk_down")
	frames.set_animation_loop("walk_down", true)
	frames.set_animation_speed("walk_down", 8.0)
	if ResourceLoader.exists(sprite_path):
		frames.add_frame("walk_down", load(sprite_path))

	sprite.sprite_frames = frames
	sprite.animation = "idle"

	# 根据纹理高度计算缩放
	if ResourceLoader.exists(sprite_path):
		var texture: Texture2D = load(sprite_path)
		if texture != null:
			var texture_height: float = texture.get_size().y
			var visual_scale: float = desired_cat_height / texture_height
			sprite.scale = Vector2(visual_scale, visual_scale)
			sprite.position = Vector2(0, desired_cat_height / 2.0)

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			_update_idle(delta)
		State.WALKING:
			_update_walking(delta)

	# 更新动画
	_update_animation()

func _update_idle(delta: float) -> void:
	idle_timer -= delta
	if idle_timer <= 0:
		_start_walking()

func _update_walking(delta: float) -> void:
	# 计算朝向目标的方向
	var direction: Vector2 = global_position.direction_to(target_position)
	var distance: float = global_position.distance_to(target_position)

	# 到达目标（距离小于约 8px）
	if distance < 8.0:
		velocity = Vector2.ZERO
		position = target_position
		_start_idle()
		return

	# 移动
	velocity = direction * move_speed
	move_and_slide()

func _start_idle() -> void:
	current_state = State.IDLE
	velocity = Vector2.ZERO
	idle_timer = randf_range(min_idle_time, max_idle_time)

func _start_walking() -> void:
	current_state = State.WALKING
	# 在测试区域内随机选择目标点
	target_position = _get_random_target()
	# 确保目标有效
	if not _is_inside_walk_area(target_position):
		target_position = _get_walk_area_center()

func _get_random_target() -> Vector2:
	var x: float = randf_range(
		test_walk_area.position.x,
		test_walk_area.position.x + test_walk_area.size.x
	)
	var y: float = randf_range(
		test_walk_area.position.y,
		test_walk_area.position.y + test_walk_area.size.y
	)
	return Vector2(x, y)

func _get_walk_area_center() -> Vector2:
	return test_walk_area.position + test_walk_area.size / 2.0

func _is_inside_walk_area(pos: Vector2) -> bool:
	return test_walk_area.has_point(pos)

func _update_animation() -> void:
	var cat_id: String = GameState.selected_cat_id
	if cat_id.is_empty():
		cat_id = "orange"

	# 如果不是 tabby，保持原有逻辑
	if cat_id != "tabby":
		if velocity.length() < 2.0:
			_play_animation("idle")
			return
		if abs(velocity.x) > abs(velocity.y):
			sprite.flip_h = velocity.x < 0
			_play_animation("walk_side")
		elif velocity.y > 0:
			sprite.flip_h = false
			_play_animation("walk_down")
		else:
			sprite.flip_h = false
			_play_animation("walk_up")
		return

	# tabby 专用动画逻辑
	if velocity.length() < 2.0:
		# 停止时播放 idle
		_play_animation("idle")
	else:
		# 移动时播放 walk_side
		# 左右翻转由 velocity.x 决定
		if velocity.x < -2:
			sprite.flip_h = true
		elif velocity.x > 2:
			sprite.flip_h = false
		_play_animation("walk_side")

func _play_animation(anim_name: String) -> void:
	# 只有当目标动画和当前动画不同时才切换，避免重新播放
	if sprite.animation != anim_name:
		sprite.play(anim_name)
