## ETAPA A: enum + match, com patrulha, perseguição, ataque e procura.
## O ataque causa dano a cada 0,8 s somente com visão livre.
## A desistência após três segundos sem visão está duplicada em perseguir e atacar.
## As duas entradas por AVISTAMENTO, em patrulhar/procurar, repetem a mesma regra.
## Um som pode ser inserido em cada ramo de transição, mas não há gancho comum.
## Memória de comportamento: estado, última posição, índice, tempo de procura
## e recarga, além da memória de percepção mantida pelo sensor.
extends CharacterBody2D

enum Estado { PATRULHAR, PERSEGUIR, ATACAR, PROCURAR }

@export var speed: float = 115.0
@export var attack_radius: float = 56.0
@export var give_up_time: float = 3.0
@export var patrol_path: NodePath = ^"../PatrolPoints"
@export var radius: float = 15.0

var estado: Estado = Estado.PATRULHAR      # Estado discreto atual.
var ultima_posicao_vista: Vector2 = Vector2.ZERO
var sensor: VisionSensor = null

var _indice_patrulha: int = 0
var _tempo_procurando: float = 0.0
var _cooldown: float = 0.0
@export var damage: int = 8
@export var interval: float = 0.8
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
		Estado.ATACAR:    _atacar(delta)
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
	if global_position.distance_to(alvo) < 12.0:
		_indice_patrulha = (_indice_patrulha + 1) % _pontos.size()
		alvo = _pontos[_indice_patrulha]
	velocity = (alvo - global_position).normalized() * speed

func _perseguir() -> void:
	# Desistência comum ao combate: cópia 1.
	if sensor.time_since_seen() > give_up_time:
		ultima_posicao_vista = sensor.last_seen_position()
		_tempo_procurando = 0.0
		estado = Estado.PROCURAR
		return
	if sensor.distance() <= attack_radius:
		_cooldown = 0.0
		estado = Estado.ATACAR
		return
	velocity = (sensor.target_position() - global_position).normalized() * speed

func _atacar(delta: float) -> void:
	velocity = Vector2.ZERO
	# Desistência comum ao combate: cópia 2.
	if sensor.time_since_seen() > give_up_time:
		ultima_posicao_vista = sensor.last_seen_position()
		_tempo_procurando = 0.0
		estado = Estado.PROCURAR
		return
	if sensor.distance() > attack_radius:
		estado = Estado.PERSEGUIR
		return
	_cooldown -= delta
	if _cooldown <= 0.0:
		_cooldown = interval
		if sensor.can_see() and sensor.target.has_method(&"take_damage"):
			sensor.target.call(&"take_damage", damage)

func _procurar(delta: float) -> void:
	if sensor.can_see():
		estado = Estado.PERSEGUIR          # transição 5 — DUPLICADA (ver 1)
		return
	# A paciência não está aqui por elegância: sem ela, uma última posição
	# vista atrás de uma parede prende o guarda para sempre. Todo estado que
	# persegue um ponto do mundo precisa de uma condição de desistência que
	# não dependa de chegar lá.
	_tempo_procurando += delta
	if (global_position.distance_to(ultima_posicao_vista) < 14.0
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
