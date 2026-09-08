## Procurar: investiga a última posição em que o jogador foi visto.
##
## Este estado só é possível porque o agente TEM MEMÓRIA. Um agente reativo
## não sabe onde o jogador estava — ele só sabe o que percebe agora, e agora
## não percebe nada. "Ir ao último lugar visto" é o exemplo mais econômico do
## que o estado interno compra em termos de comportamento crível.
extends State

@export var patience: float = 4.0

var _target: Vector2 = Vector2.ZERO
var _elapsed: float = 0.0

func enter() -> void:
	agent.set_body_color(LabPalette.PROCURAR)
	_target = agent.sensor.last_seen_position()
	_elapsed = 0.0

func execute(delta: float) -> void:
	if agent.sensor.can_see():
		go(&"chase")            # na etapa C este destino vira &"combat"
		return

	_elapsed += delta
	var chegou := agent.global_position.distance_to(_target) < 14.0
	if chegou or _elapsed > patience:
		go(&"patrol")
		return

	agent.move_towards(_target)
