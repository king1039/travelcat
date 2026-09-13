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
var selected_card: PanelContainer = null

# UI 引用
@onready var grid_container: GridContainer = $CenterContainer/GridContainer
@onready var confirm_button: Button = $ConfirmButton

# 卡片样式
const CARD_SIZE := Vector2(195, 210)
const CARD_BG_COLOR := Color(1.0, 0.976, 0.941, 1.0)        # #FFF9F0
const CARD_BORDER_COLOR := Color(0.941, 0.827, 0.647, 1.0)   # #F0D3A5
const CARD_SHADOW_COLOR := Color(0.35, 0.2, 0.1, 0.10)      # 轻微阴影
const SELECTED_BORDER_COLOR := Color(1.0, 0.533, 0.239, 1.0) # #FF8A3D
const LABEL_TEXT_COLOR := Color(0.478, 0.286, 0.204, 1.0)   # #7A4934

# 按钮颜色
const BTN_NORMAL_BG := Color(0.961, 0.541, 0.235, 1.0)    # #F58A3C
const BTN_NORMAL_BORDER := Color(0.91, 0.459, 0.161, 1.0)  # #E87529
const BTN_HOVER_BG := Color(1.0, 0.604, 0.314, 1.0)       # #FF9A50
const BTN_HOVER_BORDER := Color(0.91, 0.459, 0.161, 1.0)  # #E87529
const BTN_PRESSED_BG := Color(0.91, 0.459, 0.161, 1.0)    # #E87529
const BTN_PRESSED_BORDER := Color(0.851, 0.388, 0.114, 1.0)  # #D9631D
const BTN_DISABLED_BG := Color(0.91, 0.722, 0.573, 1.0)   # #E8B892
const BTN_DISABLED_TEXT := Color(1.0, 0.957, 0.91, 1.0)  # #FFF4E8

func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm_pressed)
	confirm_button.button_down.connect(_on_button_down)
	confirm_button.button_up.connect(_on_button_up)
	_create_cat_cards()
	_apply_button_styles()

# 创建猫咪卡片
func _create_cat_cards() -> void:
	for i: int in range(CATS.size()):
		var cat_data: Dictionary = CATS[i]
		var card: PanelContainer = _create_single_card(cat_data, i)
		grid_container.add_child(card)

# 创建单张卡片
func _create_single_card(cat_data: Dictionary, index: int) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = CARD_SIZE
	card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	card.pivot_offset = CARD_SIZE / 2.0
	card.clip_contents = true
	card.set_meta("cat_index", index)

	# 默认卡片样式 - 奶油色背景
	var style_panel := StyleBoxFlat.new()
	style_panel.bg_color = CARD_BG_COLOR
	style_panel.set_corner_radius_all(16)
	style_panel.set_border_width_all(2)
	style_panel.border_color = CARD_BORDER_COLOR
	style_panel.shadow_size = 4
	style_panel.shadow_color = CARD_SHADOW_COLOR
	card.add_theme_stylebox_override("panel", style_panel)

	# VBoxContainer
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(vbox)

	# 猫咪图片区域 - 透明PNG，完整显示
	var img_area := Control.new()
	img_area.name = "CatImageArea"
	img_area.custom_minimum_size = Vector2(180, 165)
	img_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	img_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	img_area.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 猫咪图片
	var texture_rect := TextureRect.new()
	texture_rect.name = "CatImage"
	texture_rect.custom_minimum_size = Vector2(180, 165)
	texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texture_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 加载猫咪图片
	var file_name: String = str(cat_data["file"])
	var img_path: String = CAT_IMAGE_PATH + file_name
	if ResourceLoader.exists(img_path):
		texture_rect.texture = load(img_path)

	img_area.add_child(texture_rect)
	vbox.add_child(img_area)

	# 名称区域 - 占满卡片宽度
	var name_area := Control.new()
	name_area.name = "NameArea"
	name_area.custom_minimum_size = Vector2(0, 36)
	name_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_area.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	name_area.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 猫咪名称 - 填满整个 NameArea，确保水平居中生效
	var cat_name_label := Label.new()
	cat_name_label.name = "CatName"
	cat_name_label.text = cat_data["name"]
	cat_name_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	cat_name_label.offset_left = 0
	cat_name_label.offset_top = 0
	cat_name_label.offset_right = 0
	cat_name_label.offset_bottom = 0
	cat_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cat_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cat_name_label.add_theme_color_override("font_color", LABEL_TEXT_COLOR)
	cat_name_label.add_theme_font_size_override("font_size", 19)
	cat_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	name_area.add_child(cat_name_label)
	vbox.add_child(name_area)

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
	if selected_card != null:
		_reset_card_style(selected_card)

	selected_cat_index = index
	selected_card = grid_container.get_child(index)
	_apply_selected_style(selected_card)

	confirm_button.disabled = false

# 恢复卡片默认样式
func _reset_card_style(card: PanelContainer) -> void:
	# 恢复默认样式
	var style := StyleBoxFlat.new()
	style.bg_color = CARD_BG_COLOR
	style.set_corner_radius_all(16)
	style.set_border_width_all(2)
	style.border_color = CARD_BORDER_COLOR
	style.shadow_size = 4
	style.shadow_color = CARD_SHADOW_COLOR
	card.add_theme_stylebox_override("panel", style)

# 应用选中样式 - 只改边框和阴影，保持猫咪可见
func _apply_selected_style(card: PanelContainer) -> void:
	# 选中样式 - 橙色边框和轻微阴影
	var style := StyleBoxFlat.new()
	style.bg_color = CARD_BG_COLOR
	style.set_corner_radius_all(16)
	style.set_border_width_all(4)
	style.border_color = SELECTED_BORDER_COLOR
	style.shadow_size = 5
	style.shadow_color = Color(1.0, 0.5, 0.2, 0.18)
	card.add_theme_stylebox_override("panel", style)

# 应用按钮所有状态样式
func _apply_button_styles() -> void:
	confirm_button.pivot_offset = confirm_button.size / 2.0

	# NORMAL
	var style_normal := StyleBoxFlat.new()
	style_normal.bg_color = BTN_NORMAL_BG
	style_normal.set_corner_radius_all(40)
	style_normal.set_border_width_all(3)
	style_normal.border_color = BTN_NORMAL_BORDER
	confirm_button.add_theme_stylebox_override("normal", style_normal)

	# HOVER
	var style_hover := StyleBoxFlat.new()
	style_hover.bg_color = BTN_HOVER_BG
	style_hover.set_corner_radius_all(40)
	style_hover.set_border_width_all(3)
	style_hover.border_color = BTN_HOVER_BORDER
	confirm_button.add_theme_stylebox_override("hover", style_hover)

	# PRESSED
	var style_pressed := StyleBoxFlat.new()
	style_pressed.bg_color = BTN_PRESSED_BG
	style_pressed.set_corner_radius_all(40)
	style_pressed.set_border_width_all(3)
	style_pressed.border_color = BTN_PRESSED_BORDER
	confirm_button.add_theme_stylebox_override("pressed", style_pressed)

	# DISABLED
	var style_disabled := StyleBoxFlat.new()
	style_disabled.bg_color = BTN_DISABLED_BG
	style_disabled.set_corner_radius_all(40)
	style_disabled.set_border_width_all(3)
	style_disabled.border_color = BTN_DISABLED_BG
	confirm_button.add_theme_stylebox_override("disabled", style_disabled)
	confirm_button.add_theme_color_override("font_disabled_color", BTN_DISABLED_TEXT)

# 按钮按下
func _on_button_down() -> void:
	confirm_button.scale = Vector2(0.98, 0.98)

# 按钮松开
func _on_button_up() -> void:
	confirm_button.scale = Vector2.ONE

# 确认按钮点击
func _on_confirm_pressed() -> void:
	if selected_cat_index >= 0:
		var cat_name: String = CATS[selected_cat_index]["name"]
		print("Selected cat: ", cat_name)
