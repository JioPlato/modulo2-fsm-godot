## Perseguir — agora um SUB-ESTADO de Combat.
##
## Compare com a versão da etapa B: o teste de desistência por tempo sumiu
## daqui. Ele subiu para `combat_state.gd`, escrito uma única vez, e vale
## para este estado e para Attack.
##
## O arquivo ficou com uma responsabilidade só: ir na direção do alvo e
## avisar quando estiver perto o bastante para golpear.
extends State

func enter() -> void:
	agent.set_body_color(LabPalette.PERSEGUIR)

func execute(_delta: float) -> void:
	if agent.sensor.distance() <= agent.attack_radius:
		go(&"attack")
		return
	agent.move_towards(agent.sensor.target_position())
