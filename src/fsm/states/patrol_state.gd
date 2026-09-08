## Patrulhar: percorre a rota de Marker2D, em ciclo.
##
## O índice do ponto corrente vive DENTRO do estado. Ele não polui o guarda,
## e é justamente esse encapsulamento que torna o estado uma unidade
## isolável — e, portanto, testável.
extends State

var _index: int = 0

func enter() -> void:
	# TODO: defina a cor do corpo (LabPalette.PATRULHAR).
	pass

func execute(_delta: float) -> void:
	# TODO: BLOCO B: se o sensor enxerga o jogador, peca `go(&"chase")`.
	#       senao, ande ate `agent.patrol_points[_index]` e avance o
	#       indice ciclicamente ao chegar.
	#       BLOCO C: troque o destino para `go(&"combat")`.
	pass
