# Cenário 02 (incidente): DELETE sem WHERE às 14:32

## Contexto

> **Chamado #1201:** "Um analista rodou um `DELETE` em `operacao.Emprestimo` achando que estava em homologação. Foi por volta das 14:32. O sistema continuou recebendo empréstimos novos depois disso, e **eles não podem ser perdidos**."

A restrição é o que torna o cenário realista: restaurar o banco inteiro para 14:31 apagaria tudo o que aconteceu depois. É preciso recuperar **só as linhas apagadas**.

## Preparação (em `BibliotecaLab_C02`)

1. Faça um backup full e inicie uma carga contínua de novos empréstimos (um `WHILE` com `WAITFOR DELAY '00:00:01'` numa janela separada).
2. Faça backups de log a cada 2 minutos (à mão ou com um job do Agent).
3. Anote a hora exata e rode, numa terceira janela:
   ```sql
   DELETE FROM operacao.Emprestimo WHERE DataEmprestimo < '2024-01-01';
   ```
   É um "quase sem WHERE": apaga anos de histórico.
4. Deixe a carga contínua rodando mais 5 minutos, faça mais um backup de log e só então pare a carga.

## Tarefas

1. **Descobrir o momento exato**
   - Você só tem a informação "por volta das 14:32". Encontre o horário preciso do `DELETE` lendo o log de transações com `fn_dump_dblog` sobre o arquivo de backup de log. Procure a transação `LOP_BEGIN_XACT` com nome `DELETE` e o `Begin Time`.
2. **Restaurar ao lado**
   - Restaure o banco como `BibliotecaLab_C02_Recuperado` com `STOPAT` um instante antes do `DELETE`, usando `WITH MOVE`. Use a procedure de script de restore do cenário 01.
3. **Devolver só o que foi perdido**
   - Insira de volta no banco original apenas as linhas que existem na cópia e não existem mais no original. Cuidado com `IDENTITY_INSERT`, triggers e FKs.
   - Confirme que os empréstimos inseridos **depois** das 14:32 continuam lá.
4. **Alternativa com marca**
   - Repita o incidente, mas desta vez o "deploy" perigoso roda dentro de `BEGIN TRAN DeployV2 WITH MARK 'deploy v2'`. Restaure usando `STOPBEFOREMARK`.

## Entregáveis

- `Runbooks/incidente-dados-apagados.md`: passo a passo, tempo total gasto e o que teria reduzido esse tempo.
- `Respostas/cenario-02.sql`.

## Para pesquisar

- Por que o restore é feito ao lado, e não por cima do banco de produção.
- Database snapshots (`CREATE DATABASE ... AS SNAPSHOT OF`) como proteção antes de um deploy arriscado. Quais são as limitações?
