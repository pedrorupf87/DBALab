# Cenário 05 (incidente): O log encheu

## Contexto

> **Chamado #1120 (urgente):** "O sistema de biblioteca parou às 3h. Toda gravação retorna *The transaction log for database 'BibliotecaLab' is full due to ...*. Leituras funcionam."

Existem várias causas diferentes para o mesmo erro (9002), e a correção certa depende da causa. "Mudar para SIMPLE e dar shrink" quebra a cadeia de backup e é a resposta errada na maioria dos casos.

## Preparação

Use uma **cópia** do `BibliotecaLab` (restaure como `BibliotecaLab_Log`) em recovery `FULL`, com backup full feito e o arquivo de log limitado a `MAXSIZE = 256 MB`.

## Parte A: falta de backup de log

1. Rode atualizações em massa em `operacao.Emprestimo` até o erro 9002 aparecer.
2. Diagnostique com `SELECT name, log_reuse_wait_desc FROM sys.databases` e `sys.dm_db_log_space_usage`.
3. Corrija com o procedimento correto: backup de log. Explique no runbook por que só isso já libera espaço **dentro** do arquivo.

## Parte B: transação esquecida aberta

1. Numa janela, abra uma transação, faça um `UPDATE` pequeno e **não** dê commit.
2. Em outra janela, gere carga até encher o log, fazendo backups de log no meio do caminho. O espaço não volta.
3. Diagnostique: `log_reuse_wait_desc`, `DBCC OPENTRAN`, `sys.dm_tran_database_transactions` e `sys.dm_exec_sessions`. Descubra quem é o dono da transação, desde quando ela está aberta e qual foi o último comando dela.
4. Decida e documente: matar a sessão ou procurar o responsável? Quais são as consequências do `KILL` (rollback)?

## Parte C: disco cheio

1. Sem `MAXSIZE`, mas com o log numa pasta de um pendrive ou num VHD pequeno (opcional), reproduza o caso em que o problema é o volume, não o banco.
2. Liste as alternativas: adicionar um segundo arquivo de log em outro volume, liberar espaço, aumentar o volume. Quando cada uma é aceitável?

## Entregáveis

- `Runbooks/incidente-log-cheio.md`: árvore de decisão a partir do `log_reuse_wait_desc` (`LOG_BACKUP`, `ACTIVE_TRANSACTION`, `REPLICATION`, `AVAILABILITY_REPLICA`, `ACTIVE_BACKUP_OR_RESTORE`...), com a ação correta para cada valor.
- `Respostas/cenario-05.sql`.

## Para pesquisar

- Por que dar shrink no log como rotina agendada é uma má prática.
- O que o `log_reuse_wait_desc` mostra quando a causa é replicação ou Always On (você verá isso na Fase08).
