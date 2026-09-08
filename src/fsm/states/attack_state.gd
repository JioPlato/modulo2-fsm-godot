## Atacar — agora um SUB-ESTADO de Combat.
##
## Como em Chase, o teste de desistência por tempo saiu deste arquivo. O que
## sobrou é o comportamento próprio do estado, e nada mais.
##
## Observe o uso de `enter()`: o som e a mudança de cor acontecem UMA vez, no
## instante da troca. Se estivessem em `execute()`, tocariam sessenta vezes
## por segundo. É a diferença entre a saída "à Mealy" e a "à Moore".
extends State

@export var damage: int = 8
@export var interval: float = 0.8

var _cooldown: float = 0.0

func enter() -> void:
	agent.set_body_color(LabPalette.ATACAR)
	_cooldown = 0.0
	# Aqui entraria o som de investida e a animação de saque — uma única vez.

func execute(delta: float) -> void:
	agent.stop()

	if agent.sensor.distance() > agent.attack_radius:
		go(&"chase")
		return

	_cooldown -= delta
	if _cooldown <= 0.0:
		_cooldown = interval
		_strike()

func exit() -> void:
	_cooldown = 0.0            # limpeza simétrica ao enter()

func _strike() -> void:
	var alvo := agent.sensor.target
	if alvo != null and alvo.has_method(&"take_damage"):
		alvo.call(&"take_damage", damage)
