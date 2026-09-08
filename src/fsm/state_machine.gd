## O motor da máquina de estados.
##
## Compare com `Pensar_FSM_Objetos` / `Transitar` da aula teórica: é uma
## tradução linha a linha.
##
## Este arquivo é GENÉRICO e ESTÁVEL: não menciona "patrulhar" nem "atacar".
## Acrescentar um estado ao jogo não muda uma vírgula aqui — muda a árvore de
## nós da cena. É a separação entre MECANISMO (o motor) e ESTRUTURA (os nós).
class_name StateMachine
extends Node

## Emitido a cada troca de estado de TOPO. Quem quiser reagir assina.
signal state_changed(from: StringName, to: StringName)

## Nome do nó-filho em que a máquina começa.
##
## Um nome, e não uma referência a nó: `@export var x: State` só é preenchido
## pelo editor e fica nulo num `.tscn` escrito à mão. Um nome sempre funciona,
## e a máquina já indexa os estados por nome.
@export var initial_state: StringName = &"patrol"

## Nome do estado avaliado a TODO quadro, em paralelo ao corrente
## (Buckland, 2005). Vazio = sem estado global.
@export var global_state: StringName = &"global"

var current: State = null
var previous: State = null

var _agent: Guard = null
var _global: State = null
var _states: Dictionary = {}      # StringName -> State
var _stack: Array[State] = []

func _ready() -> void:
	_agent = get_parent() as Guard
	assert(_agent != null, "StateMachine precisa ser filha de um Guard.")

	for child in get_children():
		if child is State:
			_register(child as State)

	_global = _lookup(global_state)
	if _global != null:
		_global.enter()

	current = _lookup(initial_state)
	if current == null:
		current = _primeiro_estado()
	if current == null:
		push_warning("StateMachine: nenhum estado filho.")
		return
	current.enter()
	state_changed.emit(&"", StringName(current.name))

func _physics_process(delta: float) -> void:
	if current == null:
		return
	# 1. o estado global roda ANTES e pode vetar o corrente
	if _global != null:
		_global.execute(delta)
	# 2. o comportamento do estado corrente
	current.execute(delta)
	# 3. o agente aplica o movimento — uma única chamada, num único lugar
	_agent.move_and_slide()

# --- API ------------------------------------------------------------------

func change_to(to: StringName) -> void:
	var next := _lookup(to)
	if next == null:
		push_warning("StateMachine: estado desconhecido '%s'" % to)
		return
	if next == current:
		return
	var from := StringName(current.name)
	current.exit()                           # limpeza do que sai
	previous = current
	current = next
	current.enter()                          # preparação do que entra
	state_changed.emit(from, StringName(current.name))

## Empilha o corrente e entra num estado temporário. `pop_state()` retoma.
func push_state(to: StringName) -> void:
	var next := _lookup(to)
	if next == null or next == current:
		return
	_stack.push_back(current)
	var from := StringName(current.name)
	previous = current
	current = next
	current.enter()
	state_changed.emit(from, StringName(current.name))

func pop_state() -> void:
	if _stack.is_empty():
		return
	var from := StringName(current.name)
	current.exit()
	current = _stack.pop_back()
	state_changed.emit(from, StringName(current.name))

## O caminho ativo completo: `Patrol`, ou `Combat/Attack` numa hierarquia.
func active_path() -> String:
	return "—" if current == null else current.path()

# --- implementação --------------------------------------------------------

func _register(st: State) -> void:
	st.setup(_agent)
	st.transition_requested.connect(_on_transition_requested)
	_states[StringName(st.name.to_lower())] = st

func _lookup(to: StringName) -> State:
	if to == &"":
		return null
	return _states.get(StringName(String(to).to_lower())) as State

func _primeiro_estado() -> State:
	for child in get_children():
		if child is State and child != _global:
			return child as State
	return null

func _on_transition_requested(to: StringName) -> void:
	change_to(to)
