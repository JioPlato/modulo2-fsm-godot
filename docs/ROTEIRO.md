# Roteiro autoinstrucional — 120 minutos

Use os slides como percurso e este texto para conferir comandos. O código completo
dos arquivos que você deve preencher está em [SOLUCOES.md](SOLUCOES.md).
Consulte a solução após tentar ou após dez minutos sem conseguir avançar.

| Bloco | Slides | Tempo | Minutos desde o início |
|---|---|---:|---|
| A: abertura, execução e leitura | 1–8 | 20 min | 0–20 |
| B: padrão State | 9–16 | 50 min | 20–70 |
| C: hierarquia | 17–21 | 30 min | 70–100 |
| D: verificar e entregar | 22–29 | 20 min | 100–120 |

A abertura está dentro do bloco A. Esta grade não inclui intervalo.
Se houver pausa, redistribua o tempo ou reserve a comparação escrita para terminar em casa.

## A — executar e ler

1. Copie a pasta fornecida com seu `.git`. No terminal dessa pasta, execute
   `git switch -c meu-laboratorio starter`.
2. Importe `project.godot` na Godot 4.7.2 e espere a importação.
3. Abra `scenes/lab_a_naive.tscn` e use F6. Setas movem o jogador.
4. Observe patrulha, perseguição, ataque e procura. A vida do jogador cai em
   golpes de 8 a cada 0,8 s. Atrás de uma parede, o golpe não causa dano.
5. Leia `src/naive/guard_naive.gd` e responda no README:
   - Quais dados de comportamento persistem entre quadros? Separe-os da configuração.
   - Em quais funções a regra de avistamento leva a PERSEGUIR? Onde se repete a desistência?
   - Onde inserir um som uma vez por entrada em perseguição? Que duplicação isso exigiria?

**Verifique:** `godot --headless --fixed-fps 60 --path . --script res://sim_scene.gd -- --scene=a`
aprova 17 verificações. Os testes do motor na starter ainda falham, pois B não foi implementado.

## B — quatro estados por objetos

1. **Mude a cena principal:** em Project Settings, Application > Run > Main Scene,
   selecione `scenes/main.tscn`. Salve. F5 passa a executar essa cena.
2. Em `src/fsm/state.gd`, implemente `setup(context)` e `go(to)`. Mantenha os
   métodos-base `enter/execute/exit` vazios com `pass` e preserve `path()`.
3. Em `state_machine.gd`, complete `_register`, `change_to` e `_physics_process`.
   Registre por nome em minúsculas, injete o contexto e conecte o sinal.
   Na troca, execute `exit` antes de `enter`, atualize `previous` e emita `state_changed`.
   A máquina avalia global, corrente e aplica `move_and_slide()` uma vez.
4. Implemente `patrol_state.gd`, com índice persistente e destino `chase` ao ver o alvo.
   Para testar só a patrulha, mantenha o jogador fora do alcance do sensor.
5. Em `chase_state.gd` e `attack_state.gd`, escreva a mesma regra de desistência
   após três segundos. Essa cópia é deliberada para comparação no bloco C.
6. Complete `Attack.enter/execute/exit/_strike`. Preserve dano 8, intervalo 0,8 s,
   pare a velocidade e só aplique o golpe se `sensor.can_see()` for verdadeiro.
7. Em `search_state.gd`, salve a última posição vista e zere `_elapsed` no `enter`.
   Reavistar pede `chase`; chegar a menos de 14 px ou esperar mais de 4 s pede
   `patrol`; caso contrário, caminhe ao destino.
8. Rode F5 e os dois verificadores. A solução B aprova 13 testes de motor/rota
   e 17 de cena. Registre `git add -A` e `git commit -m "refactor(b): FSM por estados"`.

**Se der errado:** confira a cena configurada antes de procurar defeitos no motor.
O rótulo lê `active_path()` a cada quadro. Um rótulo parado pode indicar máquina
sem transições ou cena errada. Cores alternando sugerem trocas repetidas ou cores
conflitantes; repetir a mesma cor em `set_body_color` não gera oscilação.

## C — superestado e fuga global

1. Conte duas cópias da desistência em Chase/Attack. Uma regra repetida em n estados
   custa n cópias; o limite n(n−1) refere-se ao total de arestas de uma FSM plana.
2. Na cena `guard.tscn`, crie Combat sob StateMachine e anexe `combat_state.gd`.
   Mova Chase e Attack para dentro de Combat.
3. Implemente Combat conforme SOLUCOES: `setup`, `enter`, `execute`, `exit`, `path`,
   `change_sub`, `_sub` e `_on_sub_transition`. `initial_substate` é
   `StringName = &"chase"`, já declarado assim na starter corrigida.
4. No começo de `Combat.execute`, peça Search se o tempo sem visão excedeu 3 s.
   Só depois delegue ao subestado. Apague essa condição de Chase e Attack.
5. Em Patrol e Search, troque o destino `chase` por `combat`.
6. Crie Flee e Global, irmãos de Combat, e anexe os scripts correspondentes.
   Complete ambos pelos exemplos em SOLUCOES. Global pede Flee com vida positiva
   e até 30%. Flee acumula frações de recuperação e retorna a Patrol com 50%.
   Mantenha os nomes padrão `initial_state=patrol` e `global_state=global`.
7. Rode F5. Pressione F: a vida do guarda cai de 100 para 20. Confirme entrada em
   Flee e retorno depois de cerca de cinco segundos de recuperação.
8. Crie um Node Recuar dentro de Combat, com script que estende State e se afasta
   do alvo. Para ativá-lo no experimento, selecione Combat no Inspector e mude
   Initial Substate para `recuar`. Rode, aproxime o jogador e depois esconda-o.
   Confira `Combat/Recuar` seguido de `Search`. A regra comum recebe **zero edições
   adicionais**. Criar o script, o nó e configurar a ativação continuam sendo trabalho.
9. Depois da demonstração, restaure Initial Substate para `chase` e salve.
   A cena de referência e o simulador do ciclo pressupõem essa entrada padrão.
10. Os dois comandos abaixo devem aprovar 13 e 22 verificações. Registre o commit C.

## D — verificar, comparar e entregar

```bash
godot --headless --path . --import
godot --headless --path . --script res://tests/run_tests.gd
godot --headless --fixed-fps 60 --path . --script res://sim_scene.gd
```

1. Acrescente **um caso no verificador de motor/rota e um no simulador**.
   Sugestões e critérios estão em `tests/README.md`.
2. Compare o custo de modificar a regra comum: 2 locais em B, 1 em C; acrescentar
   Recuar exige 0 novas cópias da regra em C. Separe isso do custo total da nova função.
3. Explique também quando enum/match seria suficiente: poucos estados estáveis,
   como uma porta ou interruptor, podem justificar a implementação direta.
4. Verifique os commits por etapa e entregue o repositório local completo ou a URL
   definida pelo docente. Não há URL de hospedagem pré-configurada neste material.
