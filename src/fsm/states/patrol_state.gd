## Patrulhar: percorre a rota de Marker2D, em ciclo.
##
## O índice do ponto corrente vive DENTRO do estado. Ele não polui o guarda,
## e é justamente esse encapsulamento que torna o estado uma unidade
## isolável — e, portanto, testável.
extends State

var _index: int = 0

func enter() -> void:
	agent.set_body_color(LabPalette.PATRULHAR)

func execute(_delta: float) -> void:
	if agent.sensor.can_see():
		go(&"combat")        # etapa C: o destino agora é o SUPER-ESTADO
		return

	if agent.patrol_points.is_empty():
		agent.stop()
		return

	var destino := agent.patrol_points[_index]
	if agent.global_position.distance_to(destino) < 12.0:
		_index = (_index + 1) % agent.patrol_points.size()
		destino = agent.patrol_points[_index]
	agent.move_towards(destino)
