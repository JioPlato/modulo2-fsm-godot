## O ESTADO GLOBAL, no sentido de Buckland (2005).
##
## Executa a TODO quadro, em paralelo ao estado corrente, e concentra as
## regras que valem em qualquer situação. Sem ele, a regra "fugir com vida
## baixa" teria de ser repetida dentro de Patrol, Chase, Attack e Search —
## quatro edições, e mais uma a cada estado novo. Esta é a explosão de
## transições Θ(n²) da teoria, resolvida em um arquivo.
extends State

@export var flee_threshold: float = 0.3

func execute(_delta: float) -> void:
	# TODO: BLOCO C: se a vida <= `flee_threshold` do maximo, `go(&"flee")`.
	#       Escrito UMA vez aqui, vale para TODOS os estados.
	pass
