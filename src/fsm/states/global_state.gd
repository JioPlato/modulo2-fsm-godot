## Regra global: fugir com vida positiva e igual ou inferior a 30%.
## Uma regra global repetida em n estados custa Theta(n) cópias.
## Aqui ela fica em um único lugar, antes da execução do estado corrente.
extends State

@export var flee_threshold: float = 0.3

func execute(_delta: float) -> void:
	# TODO: BLOCO C: se a vida <= `flee_threshold` do maximo, `go(&"flee")`.
	#       Escrito UMA vez aqui, vale para TODOS os estados.
	pass
