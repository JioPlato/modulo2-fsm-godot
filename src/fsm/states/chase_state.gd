## Perseguir: vai em linha reta até a última posição conhecida do alvo.
##
## Em linha reta — e por isso ele trava em quinas. Isso não é um defeito do
## laboratório: é exatamente a lacuna que o Módulo III preenche, com
## *steering behaviours* e busca de caminho.
extends State

func enter() -> void:
	agent.set_body_color(LabPalette.PERSEGUIR)

func execute(_delta: float) -> void:
	# >>> DESISTÊNCIA POR TEMPO — cópia nº 1 <<<
	# A mesma regra está escrita, palavra por palavra, em attack_state.gd.
	# Guarde este incômodo: a etapa C existe para eliminá-lo.
	if agent.sensor.time_since_seen() > agent.give_up_time:
		go(&"search")
		return

	if agent.sensor.distance() <= agent.attack_radius:
		go(&"attack")
		return
	agent.move_towards(agent.sensor.target_position())
