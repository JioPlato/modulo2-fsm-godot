# Avaliação do laboratório

O laboratório vale 30% da nota do módulo. A entrega inclui o repositório e seu histórico.

## Checklist

- [ ] A funciona com enum/match, dano em cadência e bloqueio de ataque por parede.
- [ ] B funciona com quatro objetos de estado e uso de enter/execute/exit.
- [ ] C inclui Combat, uma regra herdada, Global e Flee com recuperação e retorno.
- [ ] A demonstração ativa Recuar e confirma a saída herdada para Search.
- [ ] `tests/run_tests.gd` e `sim_scene.gd` terminam com código 0 na solução entregue.
- [ ] O aluno escreveu um caso novo em cada um dos dois verificadores.
- [ ] O README separa custo de mudar a regra comum do custo de acrescentar um comportamento.
- [ ] O README discute quando a versão ingênua seria uma escolha suficiente.
- [ ] Há commits por etapa. `.godot/` não está versionada; os `.gd.uid` acompanham os scripts.

## Rubrica

| Critério | Peso | Evidência |
|---|---:|---|
| Funcionalidade | 25% | Ciclo, ataque, oclusão e fuga conforme a etapa. |
| Arquitetura | 35% | Contexto injetado, percepção separada, ciclo de vida e regra herdada única. |
| Verificação | 15% | Motor real e simulador aprovados, com um novo caso significativo em cada. |
| Comparação crítica | 15% | Contagens com escopo definido e limites das opções arquiteturais. |
| Versionamento | 10% | Histórico por etapa e arquivos necessários à reprodução. |

Buscas por `machine.` ou raycasts ajudam a localizar acoplamento, mas não provam
sozinhas uma arquitetura correta. Leia o fluxo de dependências e execute os testes.

## Desafios opcionais

1. Recarga com pilha: interromper Combat e retomar o subestado anterior.
2. História: fazer Combat lembrar o último subestado após saída normal e reentrada.
   Patrol já preserva seu índice e, portanto, não é um desafio novo de história.
3. Regiões ortogonais: acrescentar um eixo de alerta independente da locomoção.
4. Eventos: usar target_spotted/target_lost e medir a diferença com cinquenta guardas.
