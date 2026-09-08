# Testes

```bash
godot --headless --script res://tests/run_tests.gd
echo $?     # 0 = todos passaram
```

Os testes não dependem de plugin algum e não abrem janela. Rode-os antes de
cada *commit*; o histórico do repositório deve conter apenas revisões verdes.

## O que é coberto

| Caso | Por que importa |
|---|---|
| Ordem `exit` → `enter` na troca | É a garantia de simetria do padrão *State*. Invertida, um recurso adquirido no `enter` é liberado pelo `exit` do estado errado. |
| Transição para o próprio estado corrente é ignorada | Sem isso, um estado que se pede a si mesmo reexecuta `enter` a cada quadro — e o som de alerta toca 60 vezes por segundo. |
| Estado desconhecido não quebra a máquina | O nome do estado é um dado (uma `StringName`); um erro de digitação não pode derrubar o jogo. |
| Pilha retoma o estado interrompido | É o comportamento definidor do autômato com pilha. |
| Estado global consegue forçar a troca | É o mecanismo que substitui as *n* transições duplicadas da FSM plana. |

## O simulador de cena

Testes de unidade não pegam "o guarda não anda". Para isso há um segundo
verificador, que roda o jogo de verdade — física, colisão e raycast de visão —,
teleporta o jogador para forçar cada transição e confere o ciclo completo:

```bash
godot --headless --fixed-fps 60 --path . --script res://sim_scene.gd
```

Ele reprova se o guarda percorrer pouco, ficar travado mais de um segundo,
deixar de dobrar os cantos da rota ou não completar
`Patrol → Combat/Chase → Combat/Attack → Search → Patrol`.

Foi ele que revelou o defeito que nenhum teste de unidade pegaria: uma
propriedade `@export var patrol_root: Node2D` preenchida à mão no `.tscn`
**nunca é resolvida** — fica nula, sem erro e sem aviso, e o guarda fica
parado. Daí o projeto usar `NodePath` + `get_node_or_null()`.

## Exercícios

1. Acrescente um caso que verifique que `exit()` **não** é chamado quando
   `push_state()` empilha — a interrupção não é uma saída definitiva.
2. Acrescente ao `sim_scene.gd` uma verificação de que o guarda entra em
   `Flee` quando a vida cai abaixo de 30%.
