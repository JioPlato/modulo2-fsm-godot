# Consulta de soluções por etapa

Tente primeiro. Use estas listagens para conferir a implementação ou retomar após dez minutos sem avanço. As listagens são cópias dos arquivos das referências corrigidas. Substitua o conteúdo do arquivo indicado, preservando a indentação.

## Bloco B

### src/fsm/state.gd

```gdscript
## Interface do estado: enter prepara, execute atualiza, exit libera.
## O sinal anuncia uma transição sem depender da classe da máquina.
## Isso facilita testes isolados; referências injetadas também podem ser testadas.
## setup recebe o contexto e path informa o caminho ativo para depuração.
class_name State
extends Node

## Emitido quando o estado pede a troca. `to` é o nome do destino, minúsculo.
signal transition_requested(to: StringName)

## O contexto. Injetado por `setup()`, nunca buscado com `get_parent()`.
var agent: Guard = null

## Injeção de dependência. Super-estados sobrescrevem para propagar.
func setup(context: Guard) -> void:
	agent = context

func enter() -> void:
	pass

func execute(_delta: float) -> void:
	pass

func exit() -> void:
	pass

## O caminho ativo a partir deste estado. Numa folha é o próprio nome; num
## super-estado, `Combat/Chase`. É a "configuração ativa" da aula teórica.
func path() -> String:
	return name

## Açúcar sintático para pedir uma transição.
func go(to: StringName) -> void:
	transition_requested.emit(to)
```

### src/fsm/state_machine.gd

```gdscript
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

## Nome do estado inicial. A máquina indexa os filhos por nome em minúsculas.
## Referências exportadas de Node também são válidas na Godot; usar nomes
## aqui é uma escolha de configuração, não uma limitação do carregador.
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
```

### src/fsm/states/patrol_state.gd

```gdscript
## Patrulhar: percorre a rota de Marker2D, em ciclo.
##
## O índice do ponto corrente vive DENTRO do estado. Ele não polui o guarda,
## e é justamente esse encapsulamento que torna o estado uma unidade
## isolável — e, portanto, testável.
extends State

var _index: int = 0

func enter() -> void:
	agent.set_body_color(LabPalette.PATRULHAR)

func execute(_delta: float) -> void:
	if agent.sensor.can_see():
		go(&"chase")            # na etapa C este destino vira &"combat"
		return

	if agent.patrol_points.is_empty():
		agent.stop()
		return

	var destino := agent.patrol_points[_index]
	if agent.global_position.distance_to(destino) < 12.0:
		_index = (_index + 1) % agent.patrol_points.size()
		destino = agent.patrol_points[_index]
	agent.move_towards(destino)
```

### src/fsm/states/chase_state.gd

```gdscript
## Perseguir: vai em linha reta até a última posição conhecida do alvo.
##
## Em linha reta — e por isso ele trava em quinas. Isso não é um defeito do
## laboratório: é exatamente a lacuna que o Módulo III preenche, com
## *steering behaviours* e busca de caminho.
extends State

func enter() -> void:
	agent.set_body_color(LabPalette.PERSEGUIR)

func execute(_delta: float) -> void:
	# >>> DESISTÊNCIA POR TEMPO — cópia nº 1 <<<
	# A mesma regra está escrita, palavra por palavra, em attack_state.gd.
	# Guarde este incômodo: a etapa C existe para eliminá-lo.
	if agent.sensor.time_since_seen() > agent.give_up_time:
		go(&"search")
		return

	if agent.sensor.distance() <= agent.attack_radius:
		go(&"attack")
		return
	agent.move_towards(agent.sensor.target_position())
```

### src/fsm/states/attack_state.gd

```gdscript
## Ataque: para, respeita a cadência e só aplica dano com visão livre.
## enter prepara a recarga uma vez. A saída por tempo é duplicada no bloco B
## e passa a ser responsabilidade de Combat no bloco C.
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

	# >>> DESISTÊNCIA POR TEMPO — cópia nº 2 <<<
	# Idêntica à de chase_state.gd. Mude uma e esqueça a outra, e o guarda
	# passa a se comportar de forma diferente conforme o sub-estado em que
	# estava — o defeito mais difícil de reproduzir que existe.
	if agent.sensor.time_since_seen() > agent.give_up_time:
		go(&"search")
		return

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
	if not agent.sensor.can_see():
		return
	var alvo := agent.sensor.target
	if alvo != null and alvo.has_method(&"take_damage"):
		alvo.call(&"take_damage", damage)
```

### src/fsm/states/search_state.gd

```gdscript
## Procurar: investiga a última posição em que o jogador foi visto.
##
## Este estado só é possível porque o agente TEM MEMÓRIA. Um agente reativo
## não sabe onde o jogador estava — ele só sabe o que percebe agora, e agora
## não percebe nada. "Ir ao último lugar visto" é o exemplo mais econômico do
## que o estado interno compra em termos de comportamento crível.
extends State

@export var patience: float = 4.0

var _target: Vector2 = Vector2.ZERO
var _elapsed: float = 0.0

func enter() -> void:
	agent.set_body_color(LabPalette.PROCURAR)
	_target = agent.sensor.last_seen_position()
	_elapsed = 0.0

func execute(delta: float) -> void:
	if agent.sensor.can_see():
		go(&"chase")            # na etapa C este destino vira &"combat"
		return

	_elapsed += delta
	var chegou := agent.global_position.distance_to(_target) < 14.0
	if chegou or _elapsed > patience:
		go(&"patrol")
		return

	agent.move_towards(_target)
```

## Bloco C

### src/fsm/states/combat_state.gd

```gdscript
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
```

### src/fsm/states/patrol_state.gd

```gdscript
## Patrulhar: percorre a rota de Marker2D, em ciclo.
##
## O índice do ponto corrente vive DENTRO do estado. Ele não polui o guarda,
## e é justamente esse encapsulamento que torna o estado uma unidade
## isolável — e, portanto, testável.
extends State

var _index: int = 0

func enter() -> void:
	agent.set_body_color(LabPalette.PATRULHAR)

func execute(_delta: float) -> void:
	if agent.sensor.can_see():
		go(&"combat")        # etapa C: o destino agora é o SUPER-ESTADO
		return

	if agent.patrol_points.is_empty():
		agent.stop()
		return

	var destino := agent.patrol_points[_index]
	if agent.global_position.distance_to(destino) < 12.0:
		_index = (_index + 1) % agent.patrol_points.size()
		destino = agent.patrol_points[_index]
	agent.move_towards(destino)
```

### src/fsm/states/chase_state.gd

```gdscript
## Perseguir — agora um SUB-ESTADO de Combat.
##
## Compare com a versão da etapa B: o teste de desistência por tempo sumiu
## daqui. Ele subiu para `combat_state.gd`, escrito uma única vez, e vale
## para este estado e para Attack.
##
## O arquivo ficou com uma responsabilidade só: ir na direção do alvo e
## avisar quando estiver perto o bastante para golpear.
extends State

func enter() -> void:
	agent.set_body_color(LabPalette.PERSEGUIR)

func execute(_delta: float) -> void:
	if agent.sensor.distance() <= agent.attack_radius:
		go(&"attack")
		return
	agent.move_towards(agent.sensor.target_position())
```

### src/fsm/states/attack_state.gd

```gdscript
## Ataque: para, respeita a cadência e só aplica dano com visão livre.
## enter prepara a recarga uma vez. A saída por tempo é duplicada no bloco B
## e passa a ser responsabilidade de Combat no bloco C.
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
	if not agent.sensor.can_see():
		return
	var alvo := agent.sensor.target
	if alvo != null and alvo.has_method(&"take_damage"):
		alvo.call(&"take_damage", damage)
```

### src/fsm/states/search_state.gd

```gdscript
## Procurar: investiga a última posição em que o jogador foi visto.
##
## Este estado só é possível porque o agente TEM MEMÓRIA. Um agente reativo
## não sabe onde o jogador estava — ele só sabe o que percebe agora, e agora
## não percebe nada. "Ir ao último lugar visto" é o exemplo mais econômico do
## que o estado interno compra em termos de comportamento crível.
##
## A `patience` não é enfeite: sem ela, uma última posição vista atrás de uma
## parede prenderia o guarda para sempre. Todo estado que persegue um ponto
## do mundo precisa de uma saída que não dependa de chegar lá.
extends State

@export var patience: float = 4.0

var _target: Vector2 = Vector2.ZERO
var _elapsed: float = 0.0

func enter() -> void:
	agent.set_body_color(LabPalette.PROCURAR)
	_target = agent.sensor.last_seen_position()
	_elapsed = 0.0

func execute(delta: float) -> void:
	if agent.sensor.can_see():
		go(&"combat")        # etapa C: o destino agora é o SUPER-ESTADO
		return

	_elapsed += delta
	var chegou := agent.global_position.distance_to(_target) < 14.0
	if chegou or _elapsed > patience:
		go(&"patrol")
		return

	agent.move_towards(_target)
```

### src/fsm/states/global_state.gd

```gdscript
## Regra global: fugir com vida positiva e igual ou inferior a 30%.
## Uma regra global repetida em n estados custa Theta(n) cópias.
## Aqui ela fica em um único lugar, antes da execução do estado corrente.
extends State

@export var flee_threshold: float = 0.3

func execute(_delta: float) -> void:
	var limiar := int(agent.max_health * flee_threshold)
	if agent.health <= limiar and agent.health > 0:
		go(&"flee")
```

### src/fsm/states/flee_state.gd

```gdscript
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
```

## Recuar: experimento do slide 21

Crie um Node Recuar como filho de Combat e anexe o script abaixo. Mude Initial Substate de Combat para `recuar` no Inspector. Observe Combat/Recuar e depois Search ao perder a visão por três segundos. Restaure `chase` após o experimento.

```gdscript
## Estado adicional usado pelo simulador para verificar a transição herdada.
## Não contém regra de desistência. A regra pertence a Combat.
extends State

func execute(_delta: float) -> void:
	var direction: Vector2 = agent.global_position - agent.sensor.target_position()
	if direction.is_zero_approx():
		direction = Vector2.RIGHT
	agent.move_towards(agent.global_position + direction.normalized() * 100.0)
```
