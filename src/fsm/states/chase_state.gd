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
	# TODO: cor: LabPalette.PERSEGUIR.
	pass

func execute(_delta: float) -> void:
	# TODO: BLOCO B: se `time_since_seen() > give_up_time`, `go(&"search")`.
	#       Depois: se a distancia <= attack_radius, `go(&"attack")`;
	#       senao, mova-se para `agent.sensor.target_position()`.
	#       BLOCO C: APAGUE a desistencia por tempo daqui — ela sobe
	#       para o combat_state.gd, escrita uma unica vez.
	pass
