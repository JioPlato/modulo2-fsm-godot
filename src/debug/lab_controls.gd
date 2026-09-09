## F é um gatilho didático de dano, disponível quando a cena contém Flee.
extends Node

var guard: Node
var supports_flee: bool = false

func _ready() -> void:
	guard = get_parent().get_node("Guard")
	supports_flee = guard.get_node_or_null("StateMachine/Flee") != null
	var help: Label = Label.new()
	help.position = Vector2(36, 30)
	help.add_theme_color_override("font_color", Color(0.15, 0.15, 0.15))
	help.text = "Setas: mover o jogador"
	if supports_flee:
		help.text += "   F: causar 80 de dano ao guarda e testar a fuga"
	add_child(help)

func _unhandled_key_input(event: InputEvent) -> void:
	if supports_flee and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F:
		guard.take_damage(80)
