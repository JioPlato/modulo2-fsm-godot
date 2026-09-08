## ETAPA C — o SUPER-ESTADO.
##
## `Combat` é, ao mesmo tempo, um estado da máquina de cima e uma máquina
## para os seus próprios filhos. É a definição de statechart de Harel (1987)
## traduzida para a árvore de nós da Godot.
##
## A HERANÇA DE TRANSIÇÕES está numa única linha, marcada abaixo. A regra
## "perdi o jogador há tempo demais, vou procurar" vale para Chase E Attack —
## e valerá para qualquer sub-estado que você acrescente depois. Na etapa B
## essa mesma regra estava escrita DUAS vezes, uma em cada sub-estado.
class_name CombatState
extends State

## Nome do sub-estado inicial. Um nome, não uma referência a nó — mesma
## razão da StateMachine.
@export var initial_substate: StringName = &"chase"

var current_sub: State = null

var _subs: Dictionary = {}

func setup(context: Guard) -> void:
	super.setup(context)
	for child in get_children():
		if child is State:
			var st := child as State
			st.setup(context)
			st.transition_requested.connect(_on_sub_transition)
			_subs[StringName(st.name.to_lower())] = st

func enter() -> void:
	current_sub = _sub(initial_substate)
	if current_sub == null and not _subs.is_empty():
		current_sub = _subs.values()[0]
	if current_sub != null:
		current_sub.enter()

func execute(delta: float) -> void:
	# ---- TRANSIÇÃO HERDADA: uma linha, válida para TODOS os sub-estados ----
	if agent.sensor.time_since_seen() > agent.give_up_time:
		go(&"search")
		return
	# -----------------------------------------------------------------------
	if current_sub != null:
		current_sub.execute(delta)

func exit() -> void:
	if current_sub != null:
		current_sub.exit()
	current_sub = null

## O caminho ativo inclui o sub-estado: `Combat/Attack`.
func path() -> String:
	return name if current_sub == null else "%s/%s" % [name, current_sub.name]

func change_sub(to: StringName) -> void:
	var next := _sub(to)
	if next == null or next == current_sub:
		return
	if current_sub != null:
		current_sub.exit()
	current_sub = next
	current_sub.enter()

func _sub(to: StringName) -> State:
	return _subs.get(StringName(String(to).to_lower())) as State

## Um pedido que os sub-estados conhecem resolve-se aqui dentro; um que eles
## não conhecem SOBE para a máquina de cima.
func _on_sub_transition(to: StringName) -> void:
	if _subs.has(StringName(String(to).to_lower())):
		change_sub(to)
	else:
		go(to)
