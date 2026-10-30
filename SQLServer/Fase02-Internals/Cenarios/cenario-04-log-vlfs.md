# Cenário 04: Log de transações e VLFs

## Contexto

O arquivo de log é dividido internamente em *Virtual Log Files* (VLFs). Um log que cresceu em pedacinhos tem milhares deles, e isso deixa lentos o recovery na inicialização, os restores e a replicação.

## Tarefas (no `InternalsLab`)

1. **Criando o problema**
   - Crie o banco `VLFLab` com log de 1 MB e crescimento de 1 MB, recovery `FULL`, e faça um backup full (para sair do modo pseudo-simple; veja o cenário 06).
   - Gere carga até o log passar de 2 GB, sem fazer backup de log.
   - Conte os VLFs com `sys.dm_db_log_info`.
2. **Medindo o impacto**
   - Reinicie a instância (ou coloque o banco `OFFLINE` e depois `ONLINE`) e veja no ERRORLOG quanto tempo o banco levou na fase de recovery.
3. **Corrigindo**
   - Faça backup de log, reduza o arquivo com `DBCC SHRINKFILE` ao menor tamanho possível e faça-o crescer de novo **manualmente**, em blocos de 512 MB ou 1 GB, até o tamanho desejado.
   - Conte os VLFs de novo e repita o teste de recovery.
4. **Olhando dentro do log**
   - Num banco pequeno, rode um único `UPDATE` de uma linha dentro de uma transação e use `fn_dblog(NULL, NULL)` para ver os registros gerados (`LOP_BEGIN_XACT`, `LOP_MODIFY_ROW`, `LOP_COMMIT_XACT`).
   - Compare com um `UPDATE` de 1.000 linhas e com um `TRUNCATE TABLE`. O `TRUNCATE` é mesmo "não logado"?
5. **Auditoria geral**
   - Escreva uma consulta que liste, para todos os bancos da instância, o tamanho do log, o crescimento configurado e a quantidade de VLFs.

## Entregáveis

- `Respostas/cenario-04.sql`.
- Inclua a consulta de VLFs no script de inventário do cenário 01 da Fase01.

## Para pesquisar

- A fórmula de quantos VLFs são criados em cada crescimento, e o que mudou no SQL Server 2022.
- O que é o MinLSN e por que o log é circular.
- Por que o arquivo de log não se beneficia do Instant File Initialization (com uma exceção no SQL Server 2022).
