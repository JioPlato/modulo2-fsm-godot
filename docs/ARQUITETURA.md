# Decisões de arquitetura

## Estados, contexto e percepção

StateMachine controla registro, transição e pilha. Guard oferece dados e serviços.
Cada State recebe o Guard por `setup(context)`. VisionSensor cuida do alcance,
raycast, última posição e tempo desde o último avistamento.

As referências de Node exportadas são suportadas pela Godot. Este projeto escolhe
nomes `StringName` para indexar estados e um `NodePath` explícito para a rota.
Essa escolha facilita a leitura do arquivo de cena; não implica que exportar Node
seja inválido. Renomear um estado exige atualizar os destinos que o referenciam.
Referência: [GDScript exports](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html#nodes).

Os sinais evitam que State dependa da classe da máquina que resolve seus pedidos.
Isso facilita testes; referências a interfaces ou dublês injetados também podem
ser testadas isoladamente. O contexto continua sendo uma dependência explícita.
O prefixo `_` comunica uso interno; não impede acesso por outro script.

## Execução e ciclo de vida

O motor avalia Global, depois o estado corrente e chama `move_and_slide()` uma vez.
Uma troca síncrona executa `exit` do estado anterior, atualiza o corrente e executa
`enter`. O código que pediu uma transição deve retornar quando o restante do método
não se aplica mais. `push_state` suspende sem chamar exit; `pop_state` retoma sem enter.

Enter/exit são ações de ciclo de vida. Execute representa a atualização do estado.
Não são, por si sós, definições formais das máquinas de Mealy e Moore.

Guard resolve o sensor em `_enter_tree`, antes do `_ready` dos filhos.
Os estados obtêm o contexto sem depender de cadeias de `get_parent()`.
O rótulo consulta `active_path()` por quadro porque `state_changed` informa trocas
de topo, mas não todas as trocas entre subestados.

## Memória e hierarquia

Na versão ingênua, estado, última posição, índice da rota, tempo de procura e
recarga do ataque persistem entre quadros. O sensor guarda memória adicional.
Na versão por objetos, esses dados ficam próximos do comportamento responsável.
Patrol já preserva `_index` ao sair e reentrar. Combat, por padrão, recomeça em Chase.

Em B, a condição de desistência aparece em Chase e Attack. Em C, Combat a avalia
antes de delegar. Um pedido desconhecido da submáquina sobe para StateMachine.
Uma regra comum copiada para n estados custa Theta(n) locais de manutenção.
O limite de n(n−1) arestas de uma FSM plana descreve outra contagem, quadrática.
Não são o mesmo argumento.

Ao criar Recuar, acrescentam-se script, nó e forma de ativação. A economia está em
não editar ou copiar novamente a regra comum de desistência. O simulador instancia
e ativa Recuar para provar esse comportamento, em vez de apenas contar arquivos.

## Ataque, fuga e cenário

As três versões compartilham o ciclo básico e o ataque de 8 pontos a cada 0,8 s.
O golpe exige visão livre. A tolerância de três segundos serve para abandonar o
combate; não autoriza ferir um alvo oculto pela parede. C acrescenta fuga global.
A recuperação conserva frações entre quadros, evitando perder `6 * delta` ao
converter cedo demais para inteiro. F é um gatilho didático de dano na cena C.

Há obstáculos internos e paredes de borda. A rota contorna o cenário e os testes
verificam a folga para o raio do corpo. Isso não implementa navegação geral: o guarda
usa movimento direto, e Search tem limite de espera para destinos inacessíveis.

A paleta vive em LabPalette. `set_body_color` só redesenha quando a cor muda.
Repetir a mesma cor não causa oscilação. O modo Floating é adequado ao jogo de topo.

## Verificação

Os testes instanciam **StateMachine real**. Apenas estados e contexto são dublês.
O simulador executa física e raycast e verifica ciclo, dano, oclusão, fuga e Recuar.
`--fixed-fps 60` fixa a duração dos quadros e acelera esta reprodução; não é garantia
geral de determinismo entre jogos ou plataformas.
