extends PanelContainer


@onready var panel_style = $%MessagePanelBody.get("theme_override_styles/panel")
@onready var scroll_cont = $%MessageScrollContainer
var message_panel_flash
var counter = 0


func _ready():
	scroll_cont.get_v_scroll_bar().connect("changed", _scrollbar_max_changed)


func _process(delta):
	counter += delta
	if counter >= 0.3:
		message_panel_flash = false
		counter = 0
	if message_panel_flash:
		var color = lerp(Color(0.149, 0.156, 0.172), Color(0.3, 0.34, 0.41), 0.18)
		panel_style.bg_color = color
	else:
		var color = lerp(panel_style.bg_color, Color(0.149, 0.156, 0.172), 0.07)
		panel_style.bg_color = color



func _scrollbar_max_changed():
	if abs(scroll_cont.scroll_vertical - scroll_cont.get_v_scroll_bar().max_value) < 200:
		scroll_cont.scroll_vertical = 999999
