# Cenário 02: Heaps e forwarded records

## Contexto

> **Chamado #1103:** "A tabela de log de integração tem só 300 mil linhas, mas o `SELECT COUNT(*)` está lendo muito mais páginas do que deveria e fica cada vez mais lento."

A tabela é um **heap** (não tem índice clustered) e recebe `UPDATE`s que aumentam o tamanho das linhas.

## Preparação (no `InternalsLab`)

1. Crie `dbo.IntegracaoLog` como heap: `ID INT`, `DataEvento DATETIME2`, `Status VARCHAR(20)`, `Mensagem VARCHAR(2000)`.
2. Insira 300 mil linhas com `Mensagem` curta (cerca de 50 caracteres).
3. Rode `SET STATISTICS IO ON; SELECT COUNT(*) FROM dbo.IntegracaoLog;` e anote as leituras lógicas.

## Tarefas

1. Atualize 30% das linhas, aumentando `Mensagem` para cerca de 1.500 caracteres.
2. Rode o `COUNT(*)` de novo e compare as leituras.
3. Diagnostique com `sys.dm_db_index_physical_stats` (modo `DETAILED`): `forwarded_record_count`, `page_count`, `avg_page_space_used_in_percent`.
4. Abra com `DBCC PAGE` uma página que contém um *forwarding stub* e encontre para onde ele aponta.
5. Corrija de duas formas e compare:
   - `ALTER TABLE dbo.IntegracaoLog REBUILD`;
   - criação de um índice clustered em `ID`.
6. Apague metade das linhas com `DELETE` e verifique se as páginas vazias do heap foram liberadas. Repita com `DELETE ... WITH (TABLOCK)`.

## Entregáveis

- `Respostas/cenario-02.sql` com as leituras antes e depois de cada etapa.
- `Runbooks/heap-forwarded-records.md`: como identificar heaps problemáticos em um banco inteiro com uma única consulta.

## Para pesquisar

- Em quais situações um heap é uma boa escolha (cargas de staging, por exemplo).
- O que é o RID e por que índices nonclustered num heap apontam para ele em vez de uma chave.
