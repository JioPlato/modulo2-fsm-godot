## Testes do motor de estados, executáveis SEM abrir o editor:
##
##     godot --headless --script res://tests/run_tests.gd
##
## Por que isto cabe num laboratório de IA para jogos? Porque comportamento
## é a parte mais difícil de depurar de um jogo: ele só se manifesta em
## situação, depois de minutos de jogo, e raramente se reproduz. Um estado
## isolável é uma unidade testável — exercita-se com percepções sintéticas e
## verifica-se a transição devolvida, à margem do jogo completo.
##
## Aliado ao passo fixo de física do Módulo I, isso transforma a depuração de
## comportamento numa verificação sistemática.
extends SceneTree

var _falhas: int = 0
var _total: int = 0

func _initialize() -> void:
	print("\n=== Testes do motor de estados ===\n")

	_testar_ordem_enter_exit()
	_testar_transicao_desconhecida_nao_quebra()
	_testar_pilha_retoma_estado_anterior()
	_testar_estado_global_tem_precedencia()
	_testar_rota_de_patrulha_nao_cruza_parede()

	print("\n%d de %d casos passaram." % [_total - _falhas, _total])
	if _falhas > 0:
		printerr("%d FALHA(S)." % _falhas)
	quit(1 if _falhas > 0 else 0)

# --- casos ----------------------------------------------------------------

func _testar_ordem_enter_exit() -> void:
	var registro: Array[String] = []
	var maquina := _montar(registro, ["a", "b"])

	_verificar("enter do estado inicial roda uma vez",
		registro, ["a.enter"])

	maquina.change_to(&"b")
	_verificar("na troca: exit do que sai ANTES do enter do que entra",
		registro, ["a.enter", "a.exit", "b.enter"])

	maquina.change_to(&"b")
	_verificar("transitar para o estado corrente nao faz nada",
		registro, ["a.enter", "a.exit", "b.enter"])

	maquina.free()

func _testar_transicao_desconhecida_nao_quebra() -> void:
	var registro: Array[String] = []
	var maquina := _montar(registro, ["a", "b"])
	maquina.change_to(&"inexistente")
	_verificar("estado desconhecido e ignorado, sem trocar o corrente",
		registro, ["a.enter"])
	maquina.free()

func _testar_pilha_retoma_estado_anterior() -> void:
	var registro: Array[String] = []
	var maquina := _montar(registro, ["a", "b"])
	maquina.push_state(&"b")
	maquina.pop_state()
	_afirmar("pop retoma o estado empilhado",
		maquina.current != null and maquina.current.name == "a")
	maquina.free()

func _testar_estado_global_tem_precedencia() -> void:
	var registro: Array[String] = []
	var maquina := _montar(registro, ["a", "b"])
	# O estado global pede 'b' logo no primeiro quadro.
	var global := _EstadoEspiao.new()
	global.name = "Global"
	global.registro = registro
	global.pedir = &"b"
	maquina.add_child(global)
	global.setup(null)
	global.transition_requested.connect(maquina.change_to)
	maquina.global_state = global

	maquina._physics_process_seguro(0.016)
	_afirmar("estado global consegue forcar a troca",
		maquina.current != null and maquina.current.name == "b")
	maquina.free()

## Regressão: o cenário e a rota são projetados juntos.
##
## Este caso existe por causa de um defeito real: numa versão anterior deste
## laboratório, três das quatro pernas da rota passavam dentro de paredes. O
## código da decisão estava correto — o guarda simplesmente encostava numa
## parede e parava, e o defeito parecia ser da máquina de estados.
##
## Nenhum teste de FSM pegaria isso. Este pega.
func _testar_rota_de_patrulha_nao_cruza_parede() -> void:
	var cena := load("res://scenes/main.tscn") as PackedScene
	if cena == null:
		_afirmar("main.tscn carrega", false)
		return

	var raiz := cena.instantiate()
	var paredes := raiz.get_node_or_null("Walls") as Walls
	var rota := raiz.get_node_or_null("PatrolPoints")
	if paredes == null or rota == null:
		_afirmar("main.tscn tem Walls e PatrolPoints", false)
		raiz.free()
		return

	var pontos := PackedVector2Array()
	for m in rota.get_children():
		if m is Marker2D:
			pontos.append((m as Marker2D).position)

	var raio := 15.0
	var livre := true
	for i in pontos.size():
		var a := pontos[i]
		var b := pontos[(i + 1) % pontos.size()]
		var trecho := Rect2(a, b - a).abs().grow(raio)
		for r in paredes.rects:
			if trecho.intersects(r):
				livre = false
				printerr("          trecho %s -> %s cruza %s" % [a, b, r])

	_afirmar("a rota de patrulha nao cruza nenhuma parede", livre)
	raiz.free()

# --- infraestrutura mínima -----------------------------------------------

func _montar(registro: Array[String], nomes: Array) -> _MaquinaDeTeste:
	var maquina := _MaquinaDeTeste.new()
	for n in nomes:
		var st := _EstadoEspiao.new()
		st.name = String(n)
		st.registro = registro
		maquina.add_child(st)
	maquina.iniciar()
	return maquina

func _verificar(titulo: String, obtido: Array[String], esperado: Array) -> void:
	_afirmar(titulo, str(obtido) == str(esperado),
		"esperado %s, obtido %s" % [str(esperado), str(obtido)])

func _afirmar(titulo: String, condicao: bool, detalhe: String = "") -> void:
	_total += 1
	if condicao:
		print("  [ok]    ", titulo)
	else:
		_falhas += 1
		printerr("  [FALHA] ", titulo, "  ", detalhe)

# --- dublês ---------------------------------------------------------------

class _EstadoEspiao extends State:
	var registro: Array[String] = []
	var pedir: StringName = &""

	func setup(context: Guard) -> void:
		agent = context

	func enter() -> void:
		registro.append("%s.enter" % name)

	func exit() -> void:
		registro.append("%s.exit" % name)

	func execute(_delta: float) -> void:
		if pedir != &"":
			var p := pedir
			pedir = &""
			go(p)


## Máquina de teste: mesma lógica de troca do motor real, sem depender de
## um Guard nem da árvore de cena. Se o motor real mudar, este dublê mostra
## a diferença — é o custo (baixo) de poder testar sem abrir o editor.
class _MaquinaDeTeste extends Node:
	var current: State = null
	var global_state: State = null
	var _states: Dictionary = {}
	var _stack: Array[State] = []

	func iniciar() -> void:
		for child in get_children():
			if child is State:
				var st := child as State
				st.transition_requested.connect(change_to)
				_states[StringName(st.name.to_lower())] = st
				if current == null:
					current = st
		if current != null:
			current.enter()

	func change_to(to: StringName) -> void:
		var next := _states.get(StringName(String(to).to_lower())) as State
		if next == null or next == current:
			return
		if current != null:
			current.exit()
		current = next
		current.enter()

	func push_state(to: StringName) -> void:
		var next := _states.get(StringName(String(to).to_lower())) as State
		if next == null or next == current:
			return
		_stack.push_back(current)
		current = next
		current.enter()

	func pop_state() -> void:
		if _stack.is_empty():
			return
		if current != null:
			current.exit()
		current = _stack.pop_back()

	func _physics_process_seguro(delta: float) -> void:
		if global_state != null:
			global_state.execute(delta)
		if current != null:
			current.execute(delta)
