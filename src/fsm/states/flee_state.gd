## Fugir: afasta-se do jogador enquanto a vida estiver baixa.
##
## Nunca é pedido por outro estado: quem o dispara é o ESTADO GLOBAL, que
## roda a todo quadro em paralelo ao corrente. É assim que se escreve, num
## único lugar, uma regra válida em qualquer situação — em vez de repetir o
## mesmo teste em cada um dos estados, como a etapa A obrigava.
extends State

@export var recover_rate: float = 6.0

func enter() -> void:
	# TODO: cor: LabPalette.FUGIR.
	pass

func execute(_delta: float) -> void:
	# TODO: afaste-se do jogador, recupere vida e volte a patrulhar
	#       quando a vida passar de metade.
	pass
