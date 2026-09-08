## Desenha a rota de patrulha.
##
## Sem isto, a rota existe apenas como quatro Marker2D invisíveis, e o aluno
## não tem como ver o que o guarda está seguindo. Dez linhas que transformam
## a cena em documentação de si mesma.
class_name PatrolRoute
extends Node2D

func _draw() -> void:
	var p := PackedVector2Array()
	for c in get_children():
		if c is Marker2D:
			p.append((c as Marker2D).position)
	if p.size() < 2:
		return
	for i in p.size():
		draw_line(p[i], p[(i + 1) % p.size()], LabPalette.ROTA, 2.0)
		draw_circle(p[i], 5.0, LabPalette.ROTA)
