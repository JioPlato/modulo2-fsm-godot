# Decisões de arquitetura

Este documento registra **por que** o código está assim. Ele é parte do
material didático: num projeto real, é o que impede que a próxima pessoa
desfaça, por desconhecimento, uma decisão tomada com cuidado.

## 1. Os estados são nós-filhos, não um `enum`

**Padrão:** *State* (Gamma et al., 1994), na forma idiomática da Godot.

Cada estado é um `Node` com script próprio, filho de `StateMachine`. Isso traz
três consequências que valem a cerimônia:

- **Coesão.** Toda a lógica de patrulha vive em `patrol_state.gd`, inclusive o
  índice do ponto corrente. Nada disso vaza para o guarda.
- **Extensão sem edição.** Acrescentar um estado é acrescentar um arquivo e um
  nó. Nenhum arquivo existente muda — nem mesmo o motor.
- **Configuração por dados.** O estado inicial e o estado global são
  `@export`, definidos na cena. A mesma classe `StateMachine` serve a
  qualquer agente, variando apenas a árvore de nós. É o padrão *Type Object*.

## 2. Estados anunciam por sinal; não chamam a máquina

`State` emite `transition_requested(to)`. A máquina escuta.

A alternativa óbvia — o estado chamar `machine.change_to(...)` — exigiria que
o estado guardasse uma referência à máquina, que já guarda referência ao
estado. Esse ciclo tem dois custos concretos:

1. Ciclos entre `class_name` complicam a análise estática da Godot e produzem
   erros de análise difíceis de diagnosticar.
2. Um estado acoplado à máquina **não pode ser testado sozinho**. Com o sinal,
   `tests/run_tests.gd` exercita estados sem instanciar o jogo.

O acoplamento passa a ser de mão única: a máquina conhece os estados; os
estados não conhecem a máquina.

## 3. O contexto é injetado, nunca buscado

`State.setup(context)` recebe o `Guard`. Nenhum estado chama
`get_parent().get_parent()`.

Buscar o contexto subindo a árvore é a origem do defeito mais comum em
projetos Godot de estudante: mover um nó no editor quebra um arquivo que não
menciona esse nó. Injeção de dependência torna a dependência **explícita e
verificável** — e é o que permite passar um dublê nos testes.

## 4. `move_and_slide()` é chamado em um único lugar

Na `StateMachine._physics_process`, depois de todos os `execute()`.

Estados definem *intenção* (`agent.velocity`); a aplicação do movimento
acontece uma vez, no fim do quadro. Se cada estado chamasse `move_and_slide()`
por conta própria, um quadro em que dois estados rodassem — o global e o
corrente — moveria o agente duas vezes.

## 5. Percepção separada da decisão

`VisionSensor` é um nó independente. Nenhum estado sabe fazer um teste de
linha de visada; o sensor não sabe o que é perseguir.

Além da separação de responsabilidades, isso dá um lugar natural para a
**histerese**: o sensor mede `time_since_seen()`, e a condição de desistência
é "não vejo há N segundos", não "não vejo neste quadro". É o que elimina a
oscilação (*thrashing*) que o Módulo I diagnosticou.

## 6. O corpo é desenhado em `_draw()`

Sem `Sprite2D`, sem textura. Decisão herdada do Módulo I: um `Sprite2D` sem
`Texture` não desenha nada, e o aluno não tem como perceber isso olhando o
editor — no editor ele vê o contorno de seleção e conclui que está tudo certo.

Como bônus, o mesmo mecanismo desenha os gizmos de depuração: o raio de
percepção e o raio de ataque. **O gizmo de depuração é a arte do laboratório.**

`queue_redraw()` é chamado quando o **conteúdo** muda (a cor do estado), não
quando a posição muda — a posição o nó acompanha de graça.

## 7. O cenário e a rota são projetados juntos

As paredes de `walls.gd` ficam **todas no miolo do mapa**; a rota de patrulha
corre pelo perímetro, com folga de 60 px — quatro vezes o raio do corpo.

Isso não é estética. Numa versão anterior deste laboratório, três das quatro
pernas da rota passavam dentro de paredes e o waypoint superior direito estava
**dentro** de um obstáculo. O efeito: o guarda andava cerca de 140 px, encostava
na face vertical da parede e parava. Como a velocidade desejada era puramente
horizontal contra uma face vertical, `move_and_slide()` não tinha componente de
deslizamento — parada total.

O sintoma — "o guarda não patrulha" — aponta para a máquina de estados, que
estava correta. É a classe de defeito mais cara de diagnosticar num laboratório
de IA: **o comportamento está certo e o mundo não deixa executá-lo.**

Duas defesas foram acrescentadas, e ambas valem para qualquer cenário que você
projete:

- `Walls.verificar_rota()` roda uma vez na inicialização e emite
  `push_warning` se alguma parede cruzar a rota;
- há um caso em `tests/run_tests.gd` que verifica a mesma propriedade sem abrir
  o editor.

## 8. `sensor` é resolvido em `_enter_tree`, não com `@onready`

Ordem de inicialização da Godot: `_ready` é chamado nos **filhos antes do pai**.
A `StateMachine` é filha do guarda, de modo que o `_ready` dela — que chama o
`enter()` do estado inicial — roda **antes** do `_ready` do guarda.

Com `@onready var sensor`, o campo ainda seria `null` nesse instante. Hoje isso
não estoura apenas porque o estado inicial é `Patrol`, cujo `enter()` não
consulta a percepção. Basta um aluno definir `Search` como estado inicial para
o laboratório quebrar com um erro que não aponta para a causa.

`_enter_tree` roda de cima para baixo, e os filhos de uma cena instanciada já
existem quando a raiz entra na árvore. É a resolução mais cedo possível, e
elimina a categoria inteira de defeito.

## 9. `motion_mode = 1` (Floating) nos corpos

`CharacterBody2D` nasce em `MOTION_MODE_GROUNDED`, que pressupõe um jogo de
plataforma: `up_direction` aponta para cima, superfícies com normal próxima
dela viram "chão", e entram em cena o *snap* ao chão e o `floor_stop_on_slope`.

Num jogo de topo isso produz comportamento errático ao raspar paredes. `Floating`
trata todas as colisões como parede e desliza uniformemente — que é o que se
espera aqui.

## 10. A paleta vive em um só arquivo

`LabPalette` existe para que a cor de um estado não seja uma constante mágica
repetida em cinco arquivos. É o mesmo princípio da tabela de transição: o dado
num lugar, o código genérico noutro.
