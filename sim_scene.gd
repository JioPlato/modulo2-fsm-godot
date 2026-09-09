## Jogo real: física, colisão e raycast. Verifica A, B ou C conforme a cena.
## godot --headless --fixed-fps 60 --path . --script res://sim_scene.gd
## Para escolher: acrescente -- --scene=a ou -- --scene=main.
extends SceneTree

const FAR: Vector2 = Vector2(3000, 3000)
var world: Node
var guard: Node2D
var player: Node2D
var machine: Node
var scene_path: String
var failures: int = 0
var total: int = 0

func _initialize() -> void:
	scene_path = ProjectSettings.get_setting("application/run/main_scene")
	for arg in OS.get_cmdline_user_args():
		if arg == "--scene=a":
			scene_path = "res://scenes/lab_a_naive.tscn"
		elif arg == "--scene=main":
			scene_path = "res://scenes/main.tscn"
	call_deferred("_run")

func _run() -> void:
	print("CENA: ", scene_path)
	if not FileAccess.file_exists(scene_path) or load(scene_path) == null:
		printerr("Cena ausente nesta etapa: ", scene_path)
		quit(1)
		return
	await _cycle()
	await _occlusion(false)
	await _occlusion(true)
	await _open()
	if guard.get_node_or_null("StateMachine/Combat") != null:
		await _flee()
		await _inherited_transition()
	else:
		print("[N/A] Fuga e transição herdada pertencem ao bloco C.")
	await _close()
	print("RESULTADO: %d/%d verificações de cena passaram." % [total - failures, total])
	quit(0 if failures == 0 else 1)

func _check(title: String, condition: bool) -> void:
	total += 1
	if condition:
		print("[ok] ", title)
	else:
		failures += 1
		printerr("[FALHA] ", title)

func _step(frames: int) -> void:
	for i in frames:
		await physics_frame
		await process_frame

func _close() -> void:
	if is_instance_valid(world):
		world.queue_free()
		await process_frame
	world = null

func _open() -> void:
	await _close()
	world = load(scene_path).instantiate()
	root.add_child(world)
	guard = world.get_node("Guard")
	player = world.get_node("Player")
	machine = guard.get_node_or_null("StateMachine")
	player.global_position = FAR
	await _step(2)

func _path() -> String:
	if machine != null:
		return machine.active_path()
	return ["Patrol", "Chase", "Attack", "Search"][guard.get("estado")]

func _leaf() -> String:
	return _path().get_slice("/", _path().get_slice_count("/") - 1)

func _cycle() -> void:
	await _open()
	var trail: Array[String] = []
	var distance_total: float = 0.0
	var last_position: Vector2 = guard.global_position
	var last_index: int = -1
	var corners: int = 0
	var stopped: int = 0
	var max_stopped: int = 0
	for frame in 1440:
		if frame == 480:
			player.global_position = guard.global_position + Vector2(70, 0)
		elif frame == 780:
			player.global_position = FAR
		await _step(1)
		var active: String = _path()
		if trail.is_empty() or trail[-1] != active:
			trail.append(active)
		var step: float = guard.global_position.distance_to(last_position)
		distance_total += step
		last_position = guard.global_position
		if _leaf() == "Patrol":
			var index: int = guard.get("_indice_patrulha") if machine == null else machine.get_node("Patrol").get("_index")
			if index != last_index:
				if last_index >= 0:
					corners += 1
				last_index = index
		if step < 0.2 and _leaf() not in ["Attack", "Flee"]:
			stopped += 1
			max_stopped = maxi(max_stopped, stopped)
		else:
			stopped = 0
	var joined: String = " -> ".join(trail)
	print("TRILHA: ", joined)
	print("PERCURSO: %.0f px; cantos: %d; vida do jogador: %d" % [distance_total, corners, player.health])
	_check("percorreu mais de 600 px", distance_total > 600.0)
	_check("dobrou pelo menos dois cantos", corners >= 2)
	_check("não travou por um segundo durante o ciclo", max_stopped < 60)
	_check("entrou em perseguição e ataque", joined.contains("Chase") and joined.contains("Attack"))
	_check("investigou após perder o alvo", joined.contains("Search"))
	_check("terminou em patrulha", _leaf() == "Patrol")
	_check("o ataque causa dano com cadência", player.health > 0 and player.health < 100)

func _occlusion(from_attack: bool) -> void:
	await _open()
	guard.global_position = Vector2(545, 340)
	guard.speed = 0.0 # Isola a decisão; a parede e o sensor continuam reais.
	player.global_position = Vector2(520 if from_attack else 480, 340)
	await _step(60)
	var label: String = "Attack" if from_attack else "Chase"
	_check("preparação de oclusão em " + label, _leaf() == label)
	player.global_position = Vector2(596.1 if from_attack else 650, 340)
	await _step(2)
	var health_before: int = player.health
	await _step(118)
	_check(label + ": parede bloqueia a visão", not guard.sensor.can_see())
	_check(label + ": não causa dano através da parede", player.health == health_before)
	_check(label + ": mantém a tolerância de três segundos", _leaf() != "Search")
	await _step(68)
	_check(label + ": entra em Search após três segundos", _leaf() == "Search")

func _flee() -> void:
	await _open()
	var key: InputEventKey = InputEventKey.new()
	key.physical_keycode = KEY_F
	key.pressed = true
	world.get_node("LabControls")._unhandled_key_input(key)
	await _step(2)
	_check("F causa dano e o estado global inicia a fuga", guard.health == 20 and _leaf() == "Flee")
	await _step(360)
	_check("a recuperação conserva as frações entre quadros", guard.health >= 50)
	_check("a fuga termina ao recuperar metade da vida", _leaf() == "Patrol")

func _inherited_transition() -> void:
	await _close()
	world = load(scene_path).instantiate()
	guard = world.get_node("Guard")
	player = world.get_node("Player")
	machine = guard.get_node("StateMachine")
	var combat: Node = machine.get_node("Combat")
	var extra: Node = load("res://tests/recuar_probe.gd").new()
	extra.name = "Recuar"
	combat.add_child(extra)
	combat.initial_substate = &"recuar"
	root.add_child(world)
	guard.speed = 0.0
	player.global_position = guard.global_position + Vector2(70, 0)
	await _step(5)
	_check("o novo subestado é realmente ativado", _path() == "Combat/Recuar")
	player.global_position = FAR
	await _step(188)
	_check("Recuar herda a desistência sem duplicar a regra", _leaf() == "Search")
