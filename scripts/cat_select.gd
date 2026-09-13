extends Control

# 猫咪数据：名称 + 文件名
const CATS := [
	{"name": "橘猫", "file": "orange.png"},
	{"name": "白猫", "file": "white.png"},
	{"name": "三花猫", "file": "calico.png"},
	{"name": "狸花猫", "file": "tabby.png"},
	{"name": "银渐层", "file": "silver.png"},
	{"name": "黑猫", "file": "black.png"},
	{"name": "黑白奶牛猫", "file": "tuxedo.png"},
	{"name": "布偶猫", "file": "ragdoll.png"},
	{"name": "暹罗猫", "file": "siamese.png"},
]

const CAT_IMAGE_PATH := "res://assets/cats/"

# 选中状态
var selected_cat_index: int = -1
var selected_card: Control = null

# UI 引用
@onready var grid_container: GridContainer = $ScrollContainer/GridContainer
@onready var confirm_button: Button = $ConfirmButton

# 卡片样式
const CARD_SIZE := Vector2(200, 220)
const CARD_BG_COLOR := Color(1, 1, 1, 1)
const CARD_SELECTED_COLOR := Color(1, 0.8, 0.6, 1)
const CARD_SELECTED_BORDER := 4.0

func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm_pressed)
	_create_cat_cards()

# 创建猫咪卡片
func _create_cat_cards() -> void:
	for i: int in range(CATS.size()):
		var cat_data: Dictionary = CATS[i]
		var card: Control = _create_single_card(cat_data, i)
		grid_container.add_child(card)

# 创建单张卡片
func _create_single_card(cat_data: Dictionary, index: int) -> Control:
	var card := Control.new()
	card.custom_minimum_size = CARD_SIZE
	card.size = CARD_SIZE

	# 卡片背景
	var bg := ColorRect.new()
	bg.name = "CardBG"
	bg.color = CARD_BG_COLOR
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.radius = 16
	card.add_child(bg)

	# 猫咪图片
	var texture_rect := TextureRect.new()
	texture_rect.name = "CatImage"
	texture_rect.custom_minimum_size = Vector2(160, 160)
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.anchors_preset = Control.PRESET_CENTER_TOP
	texture_rect.offset_top = 10
	texture_rect.offset_bottom = 170

	# 尝试加载猫咪图片
	var img_path := CAT_IMAGE_PATH + cat_data["file"]
	if ResourceLoader.exists(img_path):
		texture_rect.texture = load(img_path)
	else:
		# 图片不存在时显示占位背景
		var placeholder := ColorRect.new()
		placeholder.color = Color(0.9, 0.85, 0.8, 1)
		placeholder.set_anchors_preset(Control.PRESET_FULL_RECT)
		texture_rect.add_child(placeholder)

	card.add_child(texture_rect)

	# 猫咪名称标签
	var label := Label.new()
	label.name = "CatName"
	label.text = cat_data["name"]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.anchors_preset = Control.PRESET_CENTER_BOTTOM
	label.offset_top = 180
	label.offset_bottom = 210
	label.theme_override_colors/font_color = Color(0.35, 0.25, 0.2, 1)
	label.theme_override_font_sizes/font_size = 22
	card.add_child(label)

	# 存储猫咪索引
	card.set_meta("cat_index", index)

	# 点击信号
	card.gui_input.connect(_on_card_input.bind(index))

	return card

# 卡片点击处理
func _on_card_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_select_cat(index)

# 选中猫咪
func _select_cat(index: int) -> void:
	# 恢复之前的选中卡片样式
	if selected_card != null:
		_reset_card_style(selected_card)

	# 设置新的选中卡片
	selected_cat_index = index
	selected_card = grid_container.get_child(index)
	_apply_selected_style(selected_card)

	# 启用确认按钮
	confirm_button.disabled = false

# 恢复卡片默认样式
func _reset_card_style(card: Control) -> void:
	var bg: ColorRect = card.get_node_or_null("CardBG")
	if bg != null:
		bg.color = CARD_BG_COLOR
	card.scale = Vector2(1.0, 1.0)

# 应用选中样式
func _apply_selected_style(card: Control) -> void:
	var bg: ColorRect = card.get_node_or_null("CardBG")
	if bg != null:
		bg.color = CARD_SELECTED_COLOR
	card.scale = Vector2(1.1, 1.1)

# 确认按钮点击
func _on_confirm_pressed() -> void:
	if selected_cat_index >= 0:
		var cat_name: String = CATS[selected_cat_index]["name"]
		print("Selected cat: ", cat_name)
