## Procurar: investiga a última posição em que o jogador foi visto.
##
## Este estado só é possível porque o agente TEM MEMÓRIA. Um agente reativo
## não sabe onde o jogador estava — ele só sabe o que percebe agora, e agora
## não percebe nada. "Ir ao último lugar visto" é o exemplo mais econômico do
## que o estado interno compra em termos de comportamento crível.
##
## A `patience` não é enfeite: sem ela, uma última posição vista atrás de uma
## parede prenderia o guarda para sempre. Todo estado que persegue um ponto
## do mundo precisa de uma saída que não dependa de chegar lá.
extends State

@export var patience: float = 4.0

var _target: Vector2 = Vector2.ZERO
var _elapsed: float = 0.0

func enter() -> void:
	# TODO: cor: LabPalette.PROCURAR; guarde `last_seen_position()`.
	pass

func execute(_delta: float) -> void:
	# TODO: BLOCO B: se voltou a ver, `go(&"chase")`; se chegou ao destino
	#       ou esgotou a paciencia, `go(&"patrol")`; senao, ande ate la.
	#       BLOCO C: troque o destino para `go(&"combat")`.
	pass
