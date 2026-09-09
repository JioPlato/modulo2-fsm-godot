## Rótulo de depuração: mostra o caminho ativo sobre a cabeça do guarda.
##
## POR QUE LER A CADA QUADRO, E NÃO ASSINAR O SINAL?
## `state_changed` avisa das trocas de TOPO. Numa hierarquia, passar de
## `Combat/Chase` para `Combat/Attack` não é uma troca de topo — o rótulo
## ficaria desatualizado. Ler `active_path()` a cada quadro custa nada e
## mostra sempre a configuração inteira, que é o que se quer depurar.
##
## É também a demonstração do que a aula teórica afirma: numa máquina plana o
## estado ativo é um rótulo; numa hierárquica, é um caminho.
extends Label

var _machine: StateMachineG

func _ready() -> void:
	_machine = get_parent().get_node_or_null("StateMachineGuard") as StateMachineG

func _process(_delta: float) -> void:
	if _machine != null:
		text = _machine.active_path()
