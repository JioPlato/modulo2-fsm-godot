## Atacar — agora um SUB-ESTADO de Combat.
##
## Como em Chase, o teste de desistência por tempo saiu deste arquivo. O que
## sobrou é o comportamento próprio do estado, e nada mais.
##
## Observe o uso de `enter()`: o som e a mudança de cor acontecem UMA vez, no
## instante da troca. Se estivessem em `execute()`, tocariam sessenta vezes
## por segundo. É a diferença entre a saída "à Mealy" e a "à Moore".
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
	# TODO: cause dano ao alvo, se ele tiver `take_damage`.
	pass
