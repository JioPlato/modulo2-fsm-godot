## Sensor de visão — o estágio SENTIR do ciclo sentir–pensar–agir.
##
## Está deliberadamente separado da decisão: nenhum estado sabe fazer um
## teste de linha de visada, e este nó não sabe o que é "perseguir". É a
## separação de responsabilidades cobrada na avaliação.
##
## O sensor também guarda desde quando o alvo deixou de ser visto. Essa
## memória curta é o que permite a HISTERESE discutida na teoria: entra-se em
## perseguição ao primeiro quadro em que se vê o jogador, mas só se desiste
## após `give_up_time` segundos contínuos sem vê-lo.
class_name VisionSensor
extends Node2D

signal target_spotted(where: Vector2)
signal target_lost(last_seen: Vector2)

@export var radius: float = 240.0
@export var target_group: StringName = &"player"
## Camadas consideradas obstáculo para a linha de visada.
@export_flags_2d_physics var obstacle_mask: int = 1

var target: Node2D = null

var _visible_now: bool = false
var _was_visible: bool = false
var _time_since_seen: float = INF
var _last_seen: Vector2 = Vector2.ZERO

func _ready() -> void:
	target = get_tree().get_first_node_in_group(target_group)
	if target == null:
		push_warning("VisionSensor: nenhum no no grupo '%s'." % target_group)
	# Enquanto nada foi visto, a "última posição vista" é a posição do próprio
	# sensor — e não a origem do mundo. Um leitor distraído que consulte esta
	# informação antes do primeiro avistamento recebe um ponto inofensivo,
	# em vez de mandar o agente para o canto superior esquerdo do mapa.
	_last_seen = global_position

func _physics_process(delta: float) -> void:
	_was_visible = _visible_now
	_visible_now = _compute_visibility()

	if _visible_now != _was_visible:
		queue_redraw()   # o gizmo muda de cor: o CONTEUDO mudou

	if _visible_now:
		_time_since_seen = 0.0
		_last_seen = target.global_position
		if not _was_visible:
			target_spotted.emit(_last_seen)
	else:
		_time_since_seen += delta
		if _was_visible:
			target_lost.emit(_last_seen)

# --- consultas usadas pelos estados -------------------------------------

func can_see() -> bool:
	return _visible_now

func distance() -> float:
	if target == null:
		return INF
	return global_position.distance_to(target.global_position)

func target_position() -> Vector2:
	if target == null:
		return global_position
	return target.global_position

func last_seen_position() -> Vector2:
	return _last_seen

func time_since_seen() -> float:
	return _time_since_seen

## Houve algum avistamento desde o início da partida?
##
## Distingue "perdi o alvo há muito tempo" de "nunca vi coisa alguma" — dois
## casos que `time_since_seen()` sozinho confunde, e que levam a agente
## nenhum comportamento errado apenas por sorte.
func ever_seen() -> bool:
	return not is_inf(_time_since_seen)

# --- implementação -------------------------------------------------------

func _compute_visibility() -> bool:
	if target == null:
		return false
	if global_position.distance_to(target.global_position) > radius:
		return false
	return _has_line_of_sight(target.global_position)

func _has_line_of_sight(to: Vector2) -> bool:
	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, to)
	query.collision_mask = obstacle_mask
	query.collide_with_areas = false
	var hit := space.intersect_ray(query)
	return hit.is_empty()

func _draw() -> void:
	# Gizmo de depuração: o alcance do sensor é a própria arte do laboratório.
	var cor := LabPalette.PERSEGUIR if _visible_now else LabPalette.ROTA
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, cor, 1.0)
