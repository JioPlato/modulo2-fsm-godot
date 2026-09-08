# Módulo II — Laboratório de Máquinas de Estados

Projeto **Godot 4.2+** do segundo encontro do Módulo II da disciplina
*Inteligência Computacional Aplicada a Jogos Digitais I* (Sistemas e Mídias
Digitais, 7º semestre).

O laboratório constrói o mesmo guarda três vezes, em ordem crescente de
disciplina arquitetural, para que a diferença entre elas seja **sentida** e não
apenas descrita:

| Etapa | O que se constrói | Tag |
|---|---|---|
| A | FSM ingênua: `enum` + `match` num único arquivo | `etapa-a-fsm-ingenua` |
| B | FSM por objetos de estado — padrão *State* | `etapa-b-padrao-state` |
| C | HFSM: super-estado de combate com transição herdada | `etapa-c-hfsm` |

## Como começar

```bash
git clone <url-do-repositorio>
cd modulo2-fsm-godot
git switch starter        # esqueleto com TODOs — comece por aqui
```

Abra a pasta na Godot 4.2 ou superior (*Import* → selecione `project.godot`).

- **F5** roda a cena principal (`scenes/main.tscn`) — o guarda com padrão *State*.
- **F6** roda a cena aberta. Use em `scenes/lab_a_naive.tscn` para ver a versão ingênua.
- Setas do teclado movem o jogador.

O roteiro completo, passo a passo, está em [`docs/ROTEIRO.md`](docs/ROTEIRO.md).

## Branches

- **`starter`** — esqueleto comentado, com `TODO` nos pontos que você deve escrever.
  É o ponto de partida da aula.
- **`main`** — solução de referência, comentada. Consulte depois de tentar,
  ou quando estiver travado por mais de dez minutos.

## Estrutura

```
src/
  actors/        player.gd, guard.gd          — o CONTEXTO (só dados e serviços)
  perception/    vision_sensor.gd             — o estágio SENTIR, isolado
  fsm/           state.gd, state_machine.gd   — o motor, genérico e estável
  fsm/states/    um arquivo por estado         — o comportamento
  naive/         guard_naive.gd               — a versão da etapa A, para comparação
  debug/         state_label.gd               — depuração por Observer
  world/         walls.gd                     — cenário orientado a dados
tests/
  run_tests.gd   testes headless, sem plugin  — `godot --headless --script res://tests/run_tests.gd`
docs/
  ROTEIRO.md, ARQUITETURA.md, AVALIACAO.md
```

## Testes

Num clone novo, importe uma vez antes (a Godot precisa registrar as classes):

```bash
godot --headless --path . --import
godot --headless --path . --script res://tests/run_tests.gd
```

Sai com código 0 se todos os casos passarem. Rode antes de cada *commit*.

## Estado de verificação

Este projeto foi **executado** na Godot 4.3, e não apenas analisado. Em cada
branch e em cada *tag*:

| Ref | Importação | Comportamento observado |
|---|---|---|
| `etapa-a-fsm-ingenua` | sem erros | `PATRULHAR → PERSEGUIR → ATACAR → PROCURAR → PATRULHAR` |
| `etapa-b-padrao-state` | sem erros | `Patrol → Chase → Attack → Search → Patrol` |
| `etapa-c-hfsm` | sem erros | `Patrol → Combat/Chase → Combat/Attack → Search → Patrol` |
| `main` | sem erros | idem, com estado global e fuga |
| `starter` | sem erros | roda a cena do bloco A; o resto espera você |

O guarda percorre ~2200 px em 24 s, dobra os quatro cantos da rota e nunca
fica travado. A simulação que mede isso é `sim_scene.gd` (veja abaixo).

## Licença

MIT — veja [`LICENSE`](LICENSE). Material didático, livre para reúso com atribuição.
