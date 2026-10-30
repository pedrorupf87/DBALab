# Fase02: Internals e armazenamento

Entender como o SQL Server guarda os dados no disco: páginas, extents, heaps, índices, arquivo de log e VLFs. Sem isso, backup, tuning e troubleshooting viram receita de bolo.

## Pré-requisitos

- Fase01 concluída (baseline aplicada, CU instalada).
- `BibliotecaLab` criado e carregado ([lista de fechamento da Fase00](../Fase00-TSQL/Exercicios/Enunciados/bibliotecalab-fechamento.md)).
- Um banco descartável `InternalsLab` para os testes destrutivos. Crie e apague quantas vezes precisar.

## Cenários

| # | Cenário | Tipo |
|---|---|---|
| 01 | [Anatomia de uma página](Cenarios/cenario-01-anatomia-pagina.md) | Estudo |
| 02 | [Heaps e forwarded records](Cenarios/cenario-02-heap-forwarded-records.md) | Estudo |
| 03 | [A escolha da chave clustered](Cenarios/cenario-03-chave-clustered.md) | Estudo |
| 04 | [Log de transações e VLFs](Cenarios/cenario-04-log-vlfs.md) | Estudo |
| 05 | [O log encheu](Cenarios/cenario-05-incidente-log-cheio.md) | Incidente |
| 06 | [Recovery models na prática](Cenarios/cenario-06-recovery-models.md) | Estudo |
| 07 | [Filegroups e dados históricos](Cenarios/cenario-07-filegroups.md) | Rotina |
| 08 | [Compressão de dados](Cenarios/cenario-08-compressao.md) | Rotina |

Os cenários 04 a 06 são a base da Fase03; não pule.

## Como registrar as respostas

- `Respostas/cenario-NN.sql`: scripts e resultados relevantes, colados como comentário quando ajudarem a comparar.
- `Runbooks/`: para os incidentes.

> Comandos não documentados (`DBCC PAGE`, `DBCC IND`, `fn_dblog`) são ótimos para estudo, mas **não são suportados** pela Microsoft. Use-os somente no laboratório.
