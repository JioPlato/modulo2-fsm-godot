## Dublês apenas de estados e contexto. As trocas usam StateMachine real.
extends RefCounted

class Context extends Guard:
	func _ready() -> void:
		pass # Este teste não precisa de rota nem cenário.

class Spy extends State:
	var events: Array[String] = []
	var destination: StringName = &""
	func enter() -> void:
		events.append("%s.enter" % name)
	func exit() -> void:
		events.append("%s.exit" % name)
	func execute(_delta: float) -> void:
		events.append("%s.execute" % name)
		if destination != &"":
			var to: StringName = destination
			destination = &""
			go(to)

func run(report: SceneTree) -> void:
	var context: Context = Context.new()
	var motor: StateMachine = StateMachine.new()
	var events: Array[String] = []
	var a: Spy = Spy.new()
	var b: Spy = Spy.new()
	var global: Spy = Spy.new()
	a.name = "A"
	b.name = "B"
	global.name = "Global"
	for state in [a, b, global]:
		state.events = events
		motor.add_child(state)
	motor.initial_state = &"a"
	motor.global_state = &"global"
	context.add_child(motor)
	report.root.add_child(context)
	motor.set_physics_process(false)
	report.check("o contexto chega a todos os estados", a.agent == context and b.agent == context and global.agent == context)
	report.check("o estado inicial entra uma vez", events.count("A.enter") == 1 and motor.current == a)
	var changes: Array[String] = []
	motor.state_changed.connect(func(from: StringName, to: StringName) -> void: changes.append("%s>%s" % [from, to]))
	events.clear()
	motor.change_to(&"B")
	report.check("exit precede enter no motor real", events == ["A.exit", "B.enter"])
	report.check("a troca atualiza previous e avisa observadores", motor.previous == a and changes == ["A>B"])
	events.clear()
	motor.change_to(&"b")
	report.check("trocar para si mesmo não reentra", events.is_empty())
	motor.change_to(&"inexistente")
	report.check("destino desconhecido preserva o corrente", motor.current == b and events.is_empty())
	b.go(&"a")
	report.check("o sinal de State.go troca o estado real", motor.current == a)
	events.clear()
	motor.push_state(&"b")
	report.check("push suspende sem chamar exit", motor.current == b and events == ["B.enter"])
	motor.pop_state()
	report.check("pop retoma sem chamar enter novamente", motor.current == a and events == ["B.enter", "B.exit"])
	events.clear()
	motor.pop_state()
	report.check("pop vazio preserva o estado", motor.current == a and events.is_empty())
	global.destination = &"b"
	motor._physics_process(1.0 / 60.0)
	report.check("global troca antes de executar o corrente", motor.current == b and events == ["Global.execute", "A.exit", "B.enter", "B.execute"])
	context.free()
