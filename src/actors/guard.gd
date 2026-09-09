## O guarda — o CONTEXTO do padrão State.
##
## Repare no que este arquivo NÃO faz: ele não decide nada. Não há um único
## `if` sobre o que o guarda deveria estar fazendo. Ele guarda dados, oferece
## serviços (mover, parar, sofrer dano) e delega a decisão à máquina.
##
## Acrescentar um comportamento é acrescentar um arquivo — não editar este.
class_name Guard
extends CharacterBody2D

@export var speed: float = 115.0
@export var attack_radius: float = 56.0
@export var give_up_time: float = 3.0
@export var max_health: int = 100
@export var radius: float = 15.0

## Caminho da rota, resolvido explicitamente ao iniciar.
## Godot também suporta @export de Node. Aqui usamos NodePath para deixar
## o vínculo legível no arquivo de cena e a resolução explícita no script.
@export var patrol_path: NodePath = ^"../PatrolPoints"


var health: int = 100
var patrol_points: PackedVector2Array = PackedVector2Array()
var body_color: Color = LabPalette.PATRULHAR

## Resolvido em `_enter_tree`, e não com `@onready`: o `_ready` dos filhos
## roda antes do pai, e a StateMachine é filha do guarda.
var sensor: VisionSensor = null

var state_machine: StateMachineG = null

func _enter_tree() -> void:
	sensor = get_node_or_null("VisionSensor") as VisionSensor
	state_machine = get_node_or_null("StateMachineGuard") as StateMachineG

func _ready() -> void:
	health = max_health
	_load_patrol_points()

func _load_patrol_points() -> void:
	patrol_points.clear()
	var rota := get_node_or_null(patrol_path)
	if rota == null:
		push_warning("Guard: nao encontrei a rota em '%s'." % patrol_path)
		return
	for child in rota.get_children():
		if child is Marker2D:
			patrol_points.append((child as Marker2D).global_position)
	if patrol_points.is_empty():
		push_warning("Guard: '%s' nao tem nenhum Marker2D filho." % patrol_path)
		return
	# Cenário e rota são projetados juntos: avisa se alguma parede a cruza.
	var paredes := get_tree().get_first_node_in_group(&"walls") as Walls
	if paredes != null:
		paredes.verificar_rota(patrol_points)

# --- serviços oferecidos aos estados ------------------------------------

func move_towards(destination: Vector2) -> void:
	var to_target := destination - global_position
	if to_target.length() < 2.0:
		velocity = Vector2.ZERO
		return
	velocity = to_target.normalized() * speed

func stop() -> void:
	velocity = Vector2.ZERO

func set_body_color(c: Color) -> void:
	if body_color == c:
		return
	body_color = c
	queue_redraw()   # só quando o CONTEÚDO muda, não a cada movimento

func take_damage(amount: int) -> void:
	health = maxi(0, health - amount)

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, body_color)
	draw_arc(Vector2.ZERO, attack_radius, 0.0, TAU, 32, LabPalette.ATACAR, 1.0)
