# Roteiro do laboratório — Módulo II, encontro 2

Duas horas. O roteiro é **auto-instrucional**: siga na sua máquina, no seu
ritmo. Cada bloco termina com uma verificação — se ela falhar, resolva antes
de seguir.

| Bloco | Tema | Tempo |
|---|---|---|
| A | Preparar o projeto e ler a FSM ingênua | 20 min |
| B | Refatorar para o padrão *State* | 50 min |
| C | Agrupar o combate sob um super-estado | 30 min |
| D | Testes, comparação e entrega | 20 min |

---

## Bloco A — preparar e ler (20 min)

1. `git clone <url>` e `git switch starter`.
2. Abra o projeto na Godot 4.2+ (*Import* → `project.godot`) e **deixe a
   importação terminar** antes de rodar. Num clone novo a Godot ainda não
   registrou as classes (`class_name`); rodar antes disso produz erros de
   análise que somem sozinhos depois. Pela linha de comando, o equivalente é
   `godot --headless --import`.
3. Abra `scenes/lab_a_naive.tscn` e rode com **F6**. Mova o jogador com as setas.
4. Leia `src/naive/guard_naive.gd` inteiro, sem editar.

**Verifique:** o guarda patrulha o retângulo, persegue quando você entra no
raio de visão e volta a patrulhar quando você se esconde atrás de uma parede.

**Responda no seu README** (uma frase cada):

- Onde está a memória deste agente? Quantas variáveis a compõem?
- Qual transição aparece escrita duas vezes?
- Onde você tocaria um som de alerta **uma única vez**, ao começar a perseguir?

---

## Bloco B — o padrão *State* (50 min)

O objetivo é substituir o `match` por uma máquina genérica com um arquivo por
estado.

1. Abra `src/fsm/state.gd`. Implemente os `TODO`: a interface é `enter`,
   `execute`, `exit`, mais o sinal `transition_requested`.
2. Abra `src/fsm/state_machine.gd`. Implemente `_register`, `change_to` e o
   `_physics_process`. Cuidado com a ordem: **`exit` do que sai antes do
   `enter` do que entra**.
3. Implemente os quatro estados em `src/fsm/states/`. Comece por `patrol`;
   rode; só então faça `chase`.
4. Não há nada para ligar no Inspector: a máquina acha os estados pelos nomes
   dos nós-filhos. Um nó chamado `Chase` é pedido como `&"chase"`.

**Verifique:** rode `scenes/main.tscn` com **F5**. O rótulo sobre a cabeça do
guarda deve mudar de `Patrol` para `Chase`, `Attack` e `Search`, e a cor do
corpo deve acompanhar.

**Se der errado:**

- *O guarda não se move.* `move_and_slide()` é chamado uma vez, na máquina,
  depois dos `execute()`. Confira se você não o chamou dentro de um estado —
  ou se esqueceu de chamá-lo.
- *O rótulo não muda.* O rótulo assina `state_changed`. Confira se a máquina
  emite o sinal em `change_to` e se `state_label.gd` encontrou a máquina.
- *A cor pisca.* Você chamou `set_body_color` no `execute` em vez do `enter`.
- *"Estado desconhecido".* Os nomes são comparados em minúsculas: um nó
  chamado `Chase` é pedido como `&"chase"`.

---

## Bloco C — o super-estado (30 min)

Requisito novo: *"depois de perder o jogador de vista por três segundos, o
guarda deve ir procurá-lo"* — e isso vale tanto perseguindo quanto atacando.

1. **Antes de programar**, abra `chase_state.gd` e `attack_state.gd`. A regra
   de desistência por tempo está escrita nos **dois**, palavra por palavra.
   Anote: dois arquivos. Agora responda — quantos seriam se o combate tivesse
   cinco sub-estados, como tem um inimigo de jogo comercial?
2. Crie `src/fsm/states/combat_state.gd`. `Combat` é um estado que contém uma
   sub-máquina: implemente `setup` (propagando o contexto aos filhos), `enter`,
   `execute` e `change_sub`.
3. Escreva a regra de desistência **uma única vez**, no `execute` de `Combat`,
   antes de delegar ao sub-estado — e **apague-a de `chase_state.gd` e de
   `attack_state.gd`**. Os dois devem ficar visivelmente mais curtos.
4. Reorganize a cena: `Chase` e `Attack` passam a ser filhos de `Combat`.
   `Patrol` e `Search` passam a pedir `&"combat"` no lugar de `&"chase"`.
5. Acrescente `Global` e `Flee` e ligue `global_state` na máquina.

**Verifique:** esconda-se atrás de uma parede durante o combate. Após três
segundos, o guarda deve ir até o último ponto onde o viu e depois retomar a
patrulha. O comportamento é o mesmo estando ele em `Chase` ou em `Attack`.

**Prova da tese:** acrescente agora um sub-estado `Recuar` dentro de `Combat`.
Quantos arquivos você teve de editar para que ele também desista depois de
três segundos? Compare com o número que você anotou no passo 1.

---

## Bloco D — verificar, comparar, entregar (20 min)

1. `godot --headless --script res://tests/run_tests.gd`. Todos devem passar.
2. Escreva **um** caso de teste novo (sugestão em `tests/README.md`).
3. Complete a seção de comparação do seu `README.md`.
4. Confira o histórico: um *commit* por etapa, `.godot/` fora do versionamento.

```bash
git add -A
git commit -m "feat(c): HFSM com super-estado de combate"
git log --oneline
```

**Entregue** a URL do repositório. O histórico conta a história da refatoração
— e é lido.
