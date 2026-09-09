## Estado adicional usado pelo simulador para verificar a transição herdada.
## Não contém regra de desistência. A regra pertence a Combat.
extends State

func execute(_delta: float) -> void:
	var direction: Vector2 = agent.global_position - agent.sensor.target_position()
	if direction.is_zero_approx():
		direction = Vector2.RIGHT
	agent.move_towards(agent.global_position + direction.normalized() * 100.0)
