## Obstáculos do cenário, construídos a partir de dados.
##
## Os retângulos vivem em um `Array[Rect2]` exportado, não em nós criados à
## mão no editor. É o mesmo princípio da tabela de transição da aula teórica:
## a estrutura é um dado, e um único trecho de código genérico a interpreta.
class_name Walls
extends Node2D

## As paredes ficam TODAS no miolo do mapa. A rota de patrulha corre pelo
## perímetro — (160,140) → (980,140) → (980,520) → (160,520) — e precisa
## permanecer livre, com folga maior que o raio do guarda.
##
## Regra que vale para qualquer laboratório deste curso: cenário e rota são
## projetados JUNTOS. Uma parede sobre a rota não produz um erro nem um
## aviso — produz um agente parado, e o aluno passa meia hora procurando o
## defeito no código da decisão, que está correto.
##
## `verificar_rota()` abaixo confere isso em tempo de execução.
@export var rects: Array[Rect2] = [
	# bordas da arena — ninguém sai do mapa
	Rect2(0, 0, 1152, 20),
	Rect2(0, 628, 1152, 20),
	Rect2(0, 0, 20, 648),
	Rect2(1132, 0, 20, 648),
	# obstáculos internos
	Rect2(300, 200, 24, 180),
	Rect2(300, 200, 200, 24),
	Rect2(560, 260, 24, 200),
	Rect2(400, 420, 220, 24),
	Rect2(700, 220, 24, 220),
	Rect2(700, 220, 160, 24),
]

## Folga mínima entre a rota e qualquer parede (raio do corpo + margem).
@export var clearance: float = 22.0

func _ready() -> void:
	for r in rects:
		_build_body(r)

## Confere, na inicialização, que nenhuma parede cruza a rota de patrulha.
##
## É uma verificação barata que roda uma vez e evita a classe de defeito mais
## cara de diagnosticar num laboratório de IA: o comportamento está correto,
## mas o cenário não deixa o agente executá-lo.
func verificar_rota(pontos: PackedVector2Array) -> void:
	if pontos.size() < 2:
		return
	for i in pontos.size():
		var a := pontos[i]
		var b := pontos[(i + 1) % pontos.size()]
		for r in rects:
			var inflada := r.grow(clearance)
			if (inflada.has_point(a) or inflada.has_point(b)
					or inflada.intersects(Rect2(a, b - a).abs())):
				push_warning("Rota de patrulha bloqueada: o trecho %s -> %s cruza %s."
						% [a, b, r])

func _build_body(r: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = r.position + r.size * 0.5
	var shape := RectangleShape2D.new()
	shape.size = r.size
	var collider := CollisionShape2D.new()
	collider.shape = shape
	body.add_child(collider)
	add_child(body)

func _draw() -> void:
	for r in rects:
		draw_rect(r, LabPalette.PAREDE)
