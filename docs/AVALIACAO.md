# Avaliação do laboratório

O laboratório vale **30% da nota** do módulo. A entrega é o **repositório**,
não um arquivo solto: o histórico faz parte do que se avalia.

## Checklist de entrega

- [ ] Etapa A funcional: guarda com `enum` + `match` (`scenes/lab_a_naive.tscn`).
- [ ] Etapa B funcional: mesmo comportamento com o padrão *State*, quatro
      estados, `enter` / `execute` / `exit` efetivamente usados — em particular,
      um efeito que ocorra **uma única vez** no `enter`.
- [ ] Etapa C funcional: super-estado `Combat` com **uma** transição herdada, e
      estado global disparando a fuga.
- [ ] `tests/run_tests.gd` passa (`godot --headless --script res://tests/run_tests.gd`).
- [ ] `README.md` com instruções de execução e **uma seção de comparação**
      entre a etapa A e a etapa C: o que ficou mais fácil, o que ficou mais
      difícil, e a que custo.
- [ ] Histórico Git com um *commit* por etapa, mensagens descritivas, sem
      `.godot/` versionado.

## Rubrica

| Critério | Peso | O que se observa |
|---|---|---|
| **Funcionalidade** | 25% | As três versões rodam e produzem o ciclo patrulha → perseguição → ataque → procura → patrulha. |
| **Arquitetura** | 35% | O guarda é mesmo só contexto? Os estados são coesos e independentes? A transição herdada está escrita **uma vez**? Há acoplamento escondido (`get_parent()` em cadeia, constantes mágicas)? |
| **Verificação** | 15% | Os testes passam e cobrem algo além do trivial. Há pelo menos um caso escrito por você. |
| **Comparação crítica** | 15% | O README discute legibilidade e extensibilidade com critério, não com adjetivos. Uma boa resposta cita um caso concreto: "acrescentar X custou 1 arquivo aqui e 4 edições lá". |
| **Versionamento** | 10% | Commits por etapa, descritivos, sem artefatos de build. |

## O que distingue o trabalho excelente

Não é fazer funcionar — é **justificar**. O trabalho mediano entrega três
versões que rodam. O trabalho excelente entrega três versões que rodam e um
parágrafo que explica, com um exemplo medido, por que a terceira é mais
barata de manter que a primeira, **e** em que situação a primeira ainda seria
a escolha certa.

## Desafios opcionais

1. **Estado de recarga com pilha.** Use `push_state` / `pop_state` para
   interromper o combate, recarregar e retomar exatamente o sub-estado
   anterior. Compare com o que seria preciso fazer sem pilha.
2. **História (Harel).** Faça `Patrol` retomar o ponto de rota em que estava
   antes do combate, em vez de recomeçar do índice atual. Trata-se de um
   estado de história `H` implementado à mão.
3. **Regiões ortogonais.** Acrescente um segundo eixo independente — *alerta*
   (calmo / desconfiado / alarmado) — que evolua em paralelo ao eixo de
   locomoção, sem multiplicar estados.
4. **FSM dirigida por eventos.** Substitua a sondagem por quadro pelos sinais
   `target_spotted` / `target_lost` do sensor e meça a diferença com o
   *profiler* da Godot.
