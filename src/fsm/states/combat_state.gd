## BLOCO C — o SUPER-ESTADO. Escreva este arquivo do zero.
##
## `Combat` e, ao mesmo tempo, um estado da maquina de cima e uma maquina
## para os seus proprios filhos (`Chase` e `Attack`).
##
## O que ele precisa fazer:
##
##   setup(context)  repassar o contexto aos sub-estados, ligar o sinal
##                   `transition_requested` de cada um a `_on_sub_transition`
##                   e indexa-los em `_subs`.
##
##   enter()         entrar no `initial_substate`.
##
##   execute(delta)  >>> A TRANSICAO HERDADA VAI AQUI, ANTES de delegar. <<<
##                   Se `agent.sensor.time_since_seen() > agent.give_up_time`,
##                   peca `go(&"search")` e retorne. Escrita UMA vez, vale
##                   para Chase E Attack — e para qualquer sub-estado que
##                   voce acrescente depois.
##
##   exit()          sair do sub-estado corrente.
##
##   change_sub(to)  trocar entre sub-estados (exit do que sai, enter do que entra).
##
##   _on_sub_transition(to)
##                   se `to` for um sub-estado conhecido, resolva aqui dentro;
##                   se nao for, SUBA o pedido com `go(to)`.
##
## Antes de escrever, responda: na estrutura do bloco B, em quantos arquivos
## voce precisaria escrever a regra de desistencia? Anote o numero — ele entra
## na sua comparacao escrita.
class_name CombatState
extends State

@export var initial_substate: StringName = &"chase"

var current_sub: State = null

var _subs: Dictionary = {}
