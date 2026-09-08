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
	var limiar := int(agent.max_health * flee_threshold)
	if agent.health <= limiar and agent.health > 0:
		go(&"flee")
