## Simulação headless da cena principal.
##
##     godot --headless --path . --import
##     godot --headless --fixed-fps 60 --path . --script res://sim_scene.gd
##
## Roda o jogo de verdade — física, colisão e raycast de visão — e teleporta
## o jogador para forçar cada transição, conferindo o ciclo completo.
extends SceneTree

## Longe o bastante para estar fora do raio de visão de qualquer ponto da rota.
const LONGE := Vector2(3000, 3000)

var _frames := 0
var _guard: Node2D
var _player: Node2D
var _machine: Node

var _trilha: Array[String] = []
var _percorrido := 0.0
var _ultima_pos := Vector2.ZERO
var _parado := 0
var _max_parado := 0
var _cantos := 0
var _ultimo_indice := -1
var _falhas := 0
var _fase := "1. PATRULHA"

func _initialize() -> void:
	var cena: PackedScene = load("res://scenes/main.tscn")
	if cena == null:
		printerr("FALHA: nao consegui carregar main.tscn")
		quit(1)
		return
	var raiz: Node = cena.instantiate()
	root.add_child(raiz)

	_guard = raiz.get_node("Guard")
	_player = raiz.get_node("Player")
	_machine = _guard.get_node_or_null("StateMachine")
	_ultima_pos = _guard.global_position
	_player.global_position = LONGE

	print("\n=== SIMULACAO DA CENA PRINCIPAL ===")


func _physics_process(_delta: float) -> bool:
	_frames += 1
	if _frames == 2:
		print("pontos de patrulha: ", _guard.patrol_points.size(),
				" | guarda em ", _guard.global_position)

	# --- roteiro ---------------------------------------------------------
	if _frames == 60 * 8:
		_fase = "2. DETECCAO"
		_player.global_position = _guard.global_position + Vector2(70, 0)
	elif _frames == 60 * 13:
		_fase = "3. PERDA"
		_player.global_position = LONGE
	elif _frames == 60 * 24:
		_relatorio()
		quit(1 if _falhas > 0 else 0)
		return true

	# --- medicao ---------------------------------------------------------
	var pos: Vector2 = _guard.global_position
	var passo := pos.distance_to(_ultima_pos)
	_percorrido += passo
	_ultima_pos = pos

	var caminho := "?"
	if _machine != null:
		caminho = _machine.active_path()
	if _trilha.is_empty() or _trilha[-1] != caminho:
		_trilha.append(caminho)
		print("  t=%5.2fs  %-14s pos=%s  [%s]"
				% [_frames / 60.0, caminho, pos.round(), _fase])

	# o índice do ponto de patrulha avançou? (prova que a rota progride)
	var patrol := _machine.get_node_or_null("Patrol") if _machine else null
	if patrol != null and caminho == "Patrol":
		var idx: int = patrol.get("_index")
		if idx != _ultimo_indice:
			_ultimo_indice = idx
			_cantos += 1

	# travamento: parado enquanto deveria estar andando
	var parado_ok := caminho.contains("Attack") or caminho.contains("Flee")
	if passo < 0.2 and not parado_ok:
		_parado += 1
		_max_parado = maxi(_max_parado, _parado)
	else:
		_parado = 0

	return false


func _relatorio() -> void:
	var trilha := " -> ".join(_trilha)
	print("\n--- VERIFICACOES ---")
	_ok("o guarda percorreu mais de 600 px", _percorrido > 600.0,
			"percorreu %.0f px" % _percorrido)
	_ok("dobrou pelo menos 2 cantos da rota", _cantos >= 2,
			"avancou o indice %d vez(es)" % _cantos)
	_ok("nunca ficou travado mais de 1 s", _max_parado < 60,
			"ficou %.1f s parado" % (_max_parado / 60.0))
	_ok("entrou em Combat/Chase", trilha.contains("Combat/Chase"), "")
	_ok("entrou em Combat/Attack", trilha.contains("Combat/Attack"), "")
	_ok("passou por Search ao perder o alvo", trilha.contains("Search"), "")
	_ok("terminou de volta em Patrol", _trilha[-1] == "Patrol",
			"terminou em %s" % _trilha[-1])
	print("\n  trilha: ", trilha)
	print("  percorrido: %.0f px | cantos: %d" % [_percorrido, _cantos])
	if _falhas == 0:
		print("\nRESULTADO: CENA FUNCIONAL\n")
	else:
		printerr("\nRESULTADO: %d VERIFICACAO(OES) FALHARAM\n" % _falhas)


func _ok(titulo: String, cond: bool, detalhe: String) -> void:
	if cond:
		print("  [ok]    ", titulo)
	else:
		_falhas += 1
		printerr("  [FALHA] ", titulo, "  ", detalhe)
