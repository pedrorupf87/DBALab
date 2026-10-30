# Cenário 06: Recovery models na prática

## Contexto

O recovery model define quanto log é mantido e, portanto, até onde você consegue restaurar. Antes de desenhar a estratégia de backup da Fase03, você vai medir as diferenças entre os três modelos.

## Tarefas (no `InternalsLab`)

1. Crie três bancos idênticos: `RM_Simple`, `RM_Full` e `RM_BulkLogged`, com o recovery model correspondente e log com tamanho inicial de 2 GB (para o crescimento não interferir na medição).
2. **O modo pseudo-simple**
   - No `RM_Full`, **sem** fazer backup full, gere carga e observe o `log_reuse_wait_desc` e o uso do log após um `CHECKPOINT`.
   - Faça um backup full, repita a carga e compare. Explique o que mudou.
3. **Operações minimamente logadas**
   - Em cada banco (o `RM_Full` já com backup full), execute e meça o log gerado (`sys.dm_db_log_space_usage` antes e depois, ou `database_transaction_log_bytes_used` em `sys.dm_tran_database_transactions`) de:
     1. `SELECT ... INTO` de 1 milhão de linhas;
     2. `INSERT INTO ... WITH (TABLOCK)` num heap vazio;
     3. o mesmo `INSERT` sem `TABLOCK`;
     4. `CREATE INDEX` e `ALTER INDEX ... REBUILD` numa tabela de 1 milhão de linhas.
   - Monte uma tabela comparativa: operação × recovery model × MB de log.
4. **O preço do BULK_LOGGED**
   - No `RM_BulkLogged`, faça um backup full, uma operação minimamente logada, um `INSERT` comum e um backup de log.
   - Tente restaurar com `STOPAT` para um momento **no meio** desse backup de log. O que acontece, e por quê?
   - Compare o tamanho desse backup de log com o tamanho do log ativo.

## Entregáveis

- `Respostas/cenario-06.sql` com a tabela comparativa.
- Um resumo de quando usar cada modelo, que será a base da estratégia do cenário 01 da Fase03.

## Para pesquisar

- O que acontece com a cadeia de log ao alternar FULL → SIMPLE → FULL, e o que é preciso fazer em seguida.
- Por que o `BULK_LOGGED` é usado só temporariamente, em janelas de carga.
