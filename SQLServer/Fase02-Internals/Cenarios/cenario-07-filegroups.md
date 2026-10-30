# Cenário 07: Filegroups e dados históricos

## Contexto

Os empréstimos de 2020 a 2023 nunca mais são alterados, mas entram em todo backup full e em toda manutenção de índice. A proposta é separar o histórico num filegroup próprio, **somente leitura**. Isso também abre caminho para o restore por partes (*piecemeal*) da Fase03.

## Tarefas (numa cópia do `BibliotecaLab`)

1. **Estrutura**
   - Crie o filegroup `FG_Historico` com um arquivo próprio, numa pasta diferente da dos dados principais.
   - Crie `operacao.EmprestimoHistorico` com a mesma estrutura de `operacao.Emprestimo`, **no** `FG_Historico`.
2. **Movimentação**
   - Mova os empréstimos devolvidos até 31/12/2023 para a tabela histórica, em lotes de 50 mil linhas, cada lote numa transação, acompanhando o crescimento do log.
   - Crie uma view `operacao.vw_EmprestimoCompleto` que una as duas tabelas para os relatórios.
3. **Somente leitura**
   - Reconstrua os índices da tabela histórica e marque o filegroup como `READ_ONLY`.
   - Tente um `UPDATE` na tabela histórica e anote o erro.
4. **Mover uma tabela existente de filegroup**
   - Mova uma tabela inteira de `PRIMARY` para outro filegroup recriando o índice clustered com `DROP_EXISTING = ON ... ON [FG_Destino]`.
   - O que acontece com os índices nonclustered dela? E se a tabela fosse um heap?
5. **Inventário**
   - Escreva uma consulta que liste, para cada tabela e índice, o filegroup, o arquivo físico e o tamanho.

## Entregáveis

- `Respostas/cenario-07.sql`.

## Para pesquisar

- Particionamento de tabelas (*partition function* e *partition scheme*) como alternativa à tabela histórica separada. Quais as vantagens e o custo de complexidade?
- Por que se recomenda deixar o `PRIMARY` só com os objetos de sistema e mudar o filegroup padrão.
