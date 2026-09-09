## Ataque: para, respeita a cadência e só aplica dano com visão livre.
## enter prepara a recarga uma vez. A saída por tempo é duplicada no bloco B
## e passa a ser responsabilidade de Combat no bloco C.
extends State

@export var damage: int = 8
@export var interval: float = 0.8

var _cooldown: float = 0.0

func enter() -> void:
	# TODO: cor: LabPalette.ATACAR, e zere o cronometro.
	#       E AQUI que vai o som de investida — uma unica vez.
	pass

func execute(_delta: float) -> void:
	# TODO: pare o agente.
	#       BLOCO B: a MESMA desistencia por tempo de chase_state.gd.
	#       Sim, copiada. E esse o incomodo que o bloco C resolve.
	#       Se o alvo saiu do alcance, `go(&"chase")`; senao, desconte
	#       `delta` do cronometro e golpeie no zero.
	#       BLOCO C: APAGUE a desistencia por tempo daqui tambem.
	pass

func exit() -> void:
	# TODO: limpeza simetrica: zere o cronometro.
	pass

func _strike() -> void:
	# TODO: só golpeie se agent.sensor.can_see() e o alvo
	#       possuir take_damage. A solução detalhada está em docs/SOLUCOES.md.
	pass
