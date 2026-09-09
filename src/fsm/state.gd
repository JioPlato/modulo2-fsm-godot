## Interface do estado: enter prepara, execute atualiza, exit libera.
## O sinal anuncia uma transição sem depender da classe da máquina.
## Isso facilita testes isolados; referências injetadas também podem ser testadas.
## setup recebe o contexto e path informa o caminho ativo para depuração.
class_name State
extends Node

## Emitido quando o estado pede a troca. `to` é o nome do destino, minúsculo.
signal transition_requested(to: StringName)

## O contexto. Injetado por `setup()`, nunca buscado com `get_parent()`.
var agent: Guard = null

## Injeção de dependência. Super-estados sobrescrevem para propagar.
func setup(_context: Guard) -> void:
	# TODO: injecao de dependencia: guarde o contexto em `agent`.
	#       Super-estados sobrescrevem para repassar aos sub-estados.
	pass

func enter() -> void:
	# TODO: chamado UMA vez, ao entrar. Preparacao da entrada.
	pass

func execute(_delta: float) -> void:
	# TODO: chamado a cada quadro. Comportamento continuo ('a Moore').
	pass

func exit() -> void:
	# TODO: chamado UMA vez, ao sair. Limpeza simetrica ao enter().
	pass

## O caminho ativo a partir deste estado. Numa folha é o próprio nome; num
## super-estado, `Combat/Chase`. É a "configuração ativa" da aula teórica.
func path() -> String:
	return name

## Açúcar sintático para pedir uma transição.
func go(_to: StringName) -> void:
	# TODO: emita `transition_requested` com o destino.
	pass
