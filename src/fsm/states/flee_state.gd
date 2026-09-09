## Bloco C: fuga com recuperação fracionária.
## Complete enter/execute conforme docs/SOLUCOES.md.
## Não converta recover_rate * delta para int antes de acumular as frações.
extends State

@export var recover_rate: float = 6.0

func enter() -> void:
	# TODO: cor: LabPalette.FUGIR.
	pass

func execute(_delta: float) -> void:
	# TODO: afaste-se do jogador, recupere vida e volte a patrulhar
	#       quando a vida passar de metade.
	pass
