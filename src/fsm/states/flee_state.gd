## Fugir: afasta-se do jogador enquanto a vida estiver baixa.
##
## Nunca é pedido por outro estado: quem o dispara é o ESTADO GLOBAL, que
## roda a todo quadro em paralelo ao corrente. É assim que se escreve, num
## único lugar, uma regra válida em qualquer situação — em vez de repetir o
## mesmo teste em cada um dos estados. Outra opção seria um teste global
## centralizado no despachante da versão A.
extends State

@export var recover_rate: float = 6.0
var _recovery: float = 0.0

func enter() -> void:
	_recovery = 0.0
	agent.set_body_color(LabPalette.FUGIR)

func execute(delta: float) -> void:
	var fuga := agent.global_position - agent.sensor.target_position()
	if fuga.length() < 1.0:
		fuga = Vector2.RIGHT
	agent.move_towards(agent.global_position + fuga.normalized() * 200.0)

	_recovery += recover_rate * delta
	var recovered: int = int(_recovery)
	_recovery -= recovered
	agent.health = mini(agent.max_health, agent.health + recovered)
	if agent.health >= agent.max_health / 2:
		go(&"patrol")
