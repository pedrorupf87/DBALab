# Cenário 03: A escolha da chave clustered

## Contexto

O time de desenvolvimento quer usar `UNIQUEIDENTIFIER` gerado por `NEWID()` como PK clustered em todas as tabelas novas, porque "facilita a integração entre sistemas". Você precisa mostrar, com números, o impacto disso no armazenamento.

## Tarefas (no `InternalsLab`)

1. Crie três tabelas com a mesma estrutura (chave + `CHAR(300)` de payload), mudando só a chave clustered:
   - `INT IDENTITY`;
   - `UNIQUEIDENTIFIER DEFAULT NEWID()`;
   - `UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID()`.
2. Insira 1 milhão de linhas em cada uma, em lotes de 10 mil, simulando inserções de aplicação. Meça o tempo de cada carga.
3. Compare as três com `sys.dm_db_index_physical_stats`: `page_count`, `avg_fragmentation_in_percent` e `avg_page_space_used_in_percent`.
4. Meça os *page splits*:
   - pela contagem de `leaf_allocation_count` em `sys.dm_db_index_operational_stats`;
   - pelo log gerado em cada carga (`sys.dm_db_log_space_usage` antes e depois).
5. Na tabela com `NEWID()`, reconstrua o índice com `FILLFACTOR = 80`, insira mais 200 mil linhas e compare a fragmentação com um rebuild sem fill factor.
6. Crie um índice nonclustered numa coluna `INT` em cada tabela e compare o tamanho deles. Por que o índice da tabela com GUID é maior?

## Entregáveis

- `Respostas/cenario-03.sql`.
- Um parecer curto (no chat ou em `.md`) respondendo ao time de desenvolvimento: usar ou não GUID, e com quais condições.

## Para pesquisar

- As quatro qualidades de uma boa chave clustered: estreita, única, estática e crescente.
- Fragmentação lógica ainda importa em SSD? Pesquise os argumentos de quem defende reduzir o rebuild de índices e foque em densidade de página.
