## Regra global: fugir com vida positiva e igual ou inferior a 30%.
## Uma regra global repetida em n estados custa Theta(n) cópias.
## Aqui ela fica em um único lugar, antes da execução do estado corrente.
extends State

@export var flee_threshold: float = 0.3

func execute(_delta: float) -> void:
	var limiar := int(agent.max_health * flee_threshold)
	if agent.health <= limiar and agent.health > 0:
		go(&"flee")
