# Verificadores do laboratório

```bash
godot --headless --path . --import
godot --headless --path . --script res://tests/run_tests.gd
godot --headless --fixed-fps 60 --path . --script res://sim_scene.gd
```

Na etapa A: 2 verificações de rota e 17 de cena. Na B: 13 e 17. Na C/main: 13 e 22.
Na starter, a rota/cena A funcionam; o conjunto do motor aprova 6/13 inicialmente.
Essas sete falhas devem desaparecer ao completar B. Não as marque como sucesso.

`run_tests.gd` carrega a cena para conferir a rota. Quando StateMachine existe,
`test_motor.gd` instancia a implementação real. Os dublês substituem apenas State
e Guard. Não copie o código do motor para dentro de um dublê.

O simulador normaliza os nomes portugueses da etapa A apenas no relatório.
O rótulo da cena A continua mostrando PATRULHAR/PERSEGUIR/ATACAR/PROCURAR.
Ele seleciona o percurso pela cena principal, ou aceita `-- --scene=a` e
`-- --scene=main` no fim do comando. Para o ciclo C, Initial Substate deve ser chase.

## Cobertura

- Registro, injeção, ordem exit/enter, emissão de sinal, destino desconhecido e pilha.
- Precedência de Global sobre o corrente no motor real.
- Rota, deslocamento, ausência de travamento no cenário controlado e ciclo completo.
- Ataque com dano e cadência; nenhuma perda de vida através da parede.
- Tolerância de três segundos e saída para Search a partir de Chase e Attack.
- Tecla F, entrada em Flee, recuperação acumulada e retorno à patrulha.
- Ativação de um subestado Recuar que herda a regra comum sem copiá-la.

## Seus dois casos novos

No motor, teste duas interrupções empilhadas e a ordem de retomada; ou verifique
que uma transição herdada executa exit no subestado antes de entrar em Search.
No simulador, teste vida exatamente no limiar de fuga; ou perda de visão seguida
de reavistamento antes dos três segundos. O caso deve falhar se a regra for quebrada.

Não basta acrescentar um print verde. Faça uma asserção sobre comportamento e
confira uma versão deliberadamente quebrada em cópia temporária, depois restaure.
Referências oficiais: [propriedades exportadas](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html#nodes) e [linha de comando](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html).

Não versione `.godot/`. `--check-only` precisa de `--script res://caminho.gd`.
