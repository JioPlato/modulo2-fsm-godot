## ETAPA A — a FSM ingênua: um `enum` e um `match`.
##
## Esta versão FUNCIONA. Ela é curta, direta e qualquer programador a lê de
## imediato. É por isso que ela é escrita assim em milhares de jogos.
##
## Leia-a com atenção e depois procure, você mesmo, os três defeitos que a
## aula teórica anunciou:
##
##   1. A transição para PERSEGUIR aparece em DOIS lugares (PATRULHAR e
##      PROCURAR). A mesma regra, escrita duas vezes.
##   2. O comportamento (o que fazer) está entrelaçado com a topologia
##      (para onde ir em seguida), no mesmo bloco.
##   3. Não há gancho de entrada nem de saída. Onde você tocaria o som de
##      alerta UMA única vez, ao passar a perseguir?
##
## Guarde a resposta: a etapa B existe para resolver exatamente isso.
extends CharacterBody2D

enum Estado { PATRULHAR, PERSEGUIR, ATACAR, PROCURAR }

@export var speed: float = 115.0
@export var attack_radius: float = 56.0
@export var give_up_time: float = 3.0
@export var patrol_path: NodePath = ^"../PatrolPoints"
@export var radius: float = 15.0

var estado: Estado = Estado.PATRULHAR      # <<< A MEMÓRIA. É só isto.
var ultima_posicao_vista: Vector2 = Vector2.ZERO
var sensor: VisionSensor = null

var _indice_patrulha: int = 0
var _tempo_procurando: float = 0.0
var _pontos: PackedVector2Array = PackedVector2Array()
var _rotulo: Label = null

func _enter_tree() -> void:
	sensor = get_node_or_null("VisionSensor") as VisionSensor
	_rotulo = get_node_or_null("StateLabel") as Label

func _ready() -> void:
	var rota := get_node_or_null(patrol_path)
	if rota == null:
		push_warning("GuardNaive: nao encontrei a rota em '%s'." % patrol_path)
		return
	for child in rota.get_children():
		if child is Marker2D:
			_pontos.append((child as Marker2D).global_position)

func _physics_process(delta: float) -> void:
	match estado:
		Estado.PATRULHAR: _patrulhar()
		Estado.PERSEGUIR: _perseguir()
		Estado.ATACAR:    _atacar()
		Estado.PROCURAR:  _procurar(delta)

	move_and_slide()
	_rotulo.text = Estado.keys()[estado]
	queue_redraw()

func _patrulhar() -> void:
	if sensor.can_see():
		estado = Estado.PERSEGUIR          # transição 1
		return
	if _pontos.is_empty():
		velocity = Vector2.ZERO
		return
	var alvo := _pontos[_indice_patrulha]
	if global_position.distance_to(alvo) < 10.0:
		_indice_patrulha = (_indice_patrulha + 1) % _pontos.size()
		alvo = _pontos[_indice_patrulha]
	velocity = (alvo - global_position).normalized() * speed

func _perseguir() -> void:
	if sensor.distance() <= attack_radius:
		estado = Estado.ATACAR             # transição 2
		return
	if sensor.time_since_seen() > give_up_time:
		ultima_posicao_vista = sensor.last_seen_position()
		_tempo_procurando = 0.0
		estado = Estado.PROCURAR           # transição 3
		return
	velocity = (sensor.target_position() - global_position).normalized() * speed

func _atacar() -> void:
	velocity = Vector2.ZERO
	if sensor.distance() > attack_radius:
		estado = Estado.PERSEGUIR          # transição 4
		return

func _procurar(delta: float) -> void:
	if sensor.can_see():
		estado = Estado.PERSEGUIR          # transição 5 — DUPLICADA (ver 1)
		return
	# A paciência não está aqui por elegância: sem ela, uma última posição
	# vista atrás de uma parede prende o guarda para sempre. Todo estado que
	# persegue um ponto do mundo precisa de uma condição de desistência que
	# não dependa de chegar lá.
	_tempo_procurando += delta
	if (global_position.distance_to(ultima_posicao_vista) < 12.0
			or _tempo_procurando > 4.0):
		estado = Estado.PATRULHAR          # transição 6
		return
	velocity = (ultima_posicao_vista - global_position).normalized() * speed

func _draw() -> void:
	var cor := LabPalette.PATRULHAR
	match estado:
		Estado.PERSEGUIR: cor = LabPalette.PERSEGUIR
		Estado.ATACAR:    cor = LabPalette.ATACAR
		Estado.PROCURAR:  cor = LabPalette.PROCURAR
	draw_circle(Vector2.ZERO, radius, cor)
	draw_arc(Vector2.ZERO, attack_radius, 0.0, TAU, 32, LabPalette.ATACAR, 1.0)
