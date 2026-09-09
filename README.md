# Módulo II — Laboratório de máquinas de estados

Encontro 2 de Inteligência Computacional Aplicada a Jogos Digitais I.
Versão executada nesta revisão: **Godot 4.7.2**, renderizador GL Compatibility.
O projeto usa recursos de Godot 4.x; versões anteriores não foram verificadas nesta revisão.

## Começar pela pasta recebida

Copie a pasta `modulo2-fsm-godot` fornecida pelo docente, incluindo a pasta oculta
`.git`. Este material funciona localmente e não depende de um endereço GitHub.
Abra o terminal dentro da pasta do projeto e crie sua branch de trabalho:

```bash
git switch -c meu-laboratorio starter
godot --headless --path . --import
```

Na Godot, use **Import** e selecione `project.godot`. Espere a importação terminar.
O comando `godot` precisa apontar para o executável instalado. No macOS desta revisão:
`/Applications/Godot.app/Contents/MacOS/Godot`. No Windows, use o caminho do executável
de console da sua instalação. Não cole um caminho que não existe na sua máquina.

**Bloco A:** abra `scenes/lab_a_naive.tscn` e pressione **F6**.
Na `starter`, F5 também abre essa cena.

**Início do bloco B:** abra `scenes/main.tscn` e defina-a como cena principal
em **Project > Project Settings > Application > Run > Main Scene**.
Salve a configuração. A partir daí, F5 executa o trabalho de B/C.
Para conferir sem alterar a configuração, rode `scenes/main.tscn` com F6.

**Controles:** setas movem o jogador. Na cena C, **F** causa 80 de dano ao guarda:
ele foge com 20 de vida, recupera 6 pontos/s e volta a patrulhar ao chegar a 50.
A tecla é um gatilho didático, não um sistema de combate do jogador.

## Branches e etapas

| Referência | Conteúdo | Verificador do motor/rota | Simulador da cena principal |
|---|---|---|---|
| `starter` | A pronta; TODOs de B/C | 6/13, falhas esperadas até implementar B | 17/17 na cena A |
| `etapa-a-fsm-ingenua` | enum + match completo | 2/2; motor State ainda ausente | 17/17 |
| `etapa-b-padrao-state` | FSM plana por objetos | 13/13 | 17/17 |
| `etapa-c-hfsm` | HFSM, estado global e fuga | 13/13 | 22/22 |
| `main` | Solução completa e documentação | 13/13 | 22/22 |

Os totais são os da distribuição, antes dos casos acrescentados pelo aluno.
O ciclo comum é patrulha, perseguição, ataque com cadência e procura, seguido
de retorno à patrulha. C acrescenta a fuga global como requisito próprio.

## Verificação

Todos os refs incluem os verificadores necessários para a sua etapa:

```bash
godot --headless --path . --import
godot --headless --path . --script res://tests/run_tests.gd
godot --headless --fixed-fps 60 --path . --script res://sim_scene.gd
```

O simulador usa a cena principal configurada. Para escolher explicitamente:

```bash
godot --headless --fixed-fps 60 --path . --script res://sim_scene.gd -- --scene=a
godot --headless --fixed-fps 60 --path . --script res://sim_scene.gd -- --scene=main
```

`--scene=main` só vale a partir de B e na `starter` depois de completar os TODOs.
Código de saída 0 significa aprovação, 1 significa falha. As falhas da `starter`
são exercícios pendentes; não são erros de sintaxe e não devem ser escondidas.
Completar somente `State.go()` não basta para aprovar o motor real.

## Quando precisar retomar uma etapa

Guarde seu trabalho antes de mudar de versão. Para retomar pela solução B:

```bash
git stash push -u -m "tentativa antes de retomar B"
git switch -c retomada-b etapa-b-padrao-state
```

Escolha outro nome se `retomada-b` já existir. A branch nova mantém seus próximos
commits associados a um nome. A tentativa anterior continua guardada no stash.
Pare a execução do jogo antes de trocar arquivos e espere a reimportação.

## Material de apoio

- [ROTEIRO.md](docs/ROTEIRO.md): passos e marcos de verificação.
- [SOLUCOES.md](docs/SOLUCOES.md): arquivos completos de B/C para consulta depois da tentativa.
- [ARQUITETURA.md](docs/ARQUITETURA.md): decisões e limites do desenho.
- [AVALIACAO.md](docs/AVALIACAO.md): entrega e pesos.
- [tests/README.md](tests/README.md): cobertura e novos casos.

Referências oficiais: [propriedades exportadas](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html#nodes) e [linha de comando](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html).

Não versione `.godot/`. Os arquivos `.gd.uid` gerados pela Godot 4.4+ devem
acompanhar os scripts no Git. Material educacional sob licença MIT, conforme LICENSE.
