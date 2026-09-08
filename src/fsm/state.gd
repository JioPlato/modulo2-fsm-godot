## Classe base de todo estado — a interface do padrão *State*.
##
##   enter()    uma única vez, ao ENTRAR   — preparação (efeito "à Mealy")
##   execute()  a cada quadro              — comportamento contínuo ("à Moore")
##   exit()     uma única vez, ao SAIR     — limpeza
##
## POR QUE UM SINAL, E NÃO UMA CHAMADA À MÁQUINA?
## Um estado que chamasse `machine.change_to(...)` precisaria de referência à
## máquina, que já referencia o estado: um ciclo. Ciclos entre `class_name`
## complicam a análise da Godot e, pior, impedem testar um estado isolado.
## Com o sinal, o estado apenas ANUNCIA; quem escuta decide.
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
