## Jogador controlado pelas setas do teclado.
##
## Sem dependência de textura: o corpo é desenhado em `_draw()`. Essa decisão
## vem do Módulo I e elimina a causa número um de "não aparece nada" — um
## Sprite2D sem Texture não desenha, e o aluno não tem como saber disso
## olhando o editor.
class_name Player
extends CharacterBody2D

@export var speed: float = 190.0
@export var radius: float = 12.0
@export var max_health: int = 100

var health: int = 100

func _ready() -> void:
	health = max_health

## Chamado pelo estado de ataque do guarda. O guarda nao conhece a classe
## Player: ele so verifica `has_method`. Acoplamento pelo COMPORTAMENTO,
## nao pelo tipo.
func take_damage(amount: int) -> void:
	health = maxi(0, health - amount)
	queue_redraw()

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(&"ui_left", &"ui_right", &"ui_up", &"ui_down")
	velocity = direction * speed
	move_and_slide()

func _draw() -> void:
	# O raio encolhe conforme a vida cai: retorno visual imediato do ataque.
	var vivo := float(health) / float(max_health)
	draw_circle(Vector2.ZERO, radius, LabPalette.JOGADOR)
	draw_arc(Vector2.ZERO, radius + 6.0, -PI / 2.0, -PI / 2.0 + TAU * vivo,
			24, LabPalette.JOGADOR, 2.0)
