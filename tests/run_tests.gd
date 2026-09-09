## Testes da rota e da implementação REAL do motor. Sem plugins.
## godot --headless --path . --script res://tests/run_tests.gd
## Na starter, as falhas do motor são esperadas até completar o bloco B.
extends SceneTree

var failures: int = 0
var total: int = 0

func _initialize() -> void:
	call_deferred("_run")

func check(title: String, condition: bool) -> void:
	total += 1
	if condition:
		print("[ok] ", title)
	else:
		failures += 1
		printerr("[FALHA] ", title)

func _run() -> void:
	_test_route()
	if FileAccess.file_exists("res://src/fsm/state_machine.gd"):
		var suite: RefCounted = load("res://tests/test_motor.gd").new()
		suite.run(self)
	else:
		print("[N/A] Etapa A: o motor State ainda não faz parte desta versão.")
	print("RESULTADO: %d/%d verificações passaram." % [total - failures, total])
	quit(0 if failures == 0 else 1)

func _test_route() -> void:
	var path: String = "res://scenes/main.tscn"
	if not FileAccess.file_exists(path):
		path = "res://scenes/lab_a_naive.tscn"
	var packed: PackedScene = load(path)
	if packed == null:
		check("a cena carrega", false)
		return
	var world: Node = packed.instantiate()
	var walls: Node = world.get_node("Walls")
	var route: Node = world.get_node("PatrolPoints")
	var points: PackedVector2Array = PackedVector2Array()
	for marker in route.get_children():
		if marker is Marker2D:
			points.append(marker.position)
	check("a rota possui quatro pontos", points.size() == 4)
	var clear: bool = points.size() == 4
	for i in points.size():
		var segment: Rect2 = Rect2(points[i], points[(i + 1) % points.size()] - points[i]).abs().grow(15.0)
		for wall in walls.rects:
			if segment.intersects(wall):
				clear = false
	check("a rota tem folga para o corpo do guarda", clear)
	world.free()
