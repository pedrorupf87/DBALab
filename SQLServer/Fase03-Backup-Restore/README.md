# Fase03: Backup e restore

A responsabilidade número um de um DBA: **conseguir devolver os dados**. Backup que nunca foi restaurado é só uma hipótese. Esta fase é quase toda feita de incidentes simulados.

## Pré-requisitos

- `INST02` instalada (Fase01, cenário 03) e SQL Server Agent em execução nas duas instâncias.
- Fase02 concluída, principalmente os cenários 04 a 07 (log, recovery models e filegroups).
- `BibliotecaLab` carregado. Para os cenários destrutivos, trabalhe em cópias (`BibliotecaLab_C02`, `BibliotecaLab_C03`...).
- Uma pasta de backup, por exemplo `C:\SQLBackup`. Em produção os backups nunca ficam no mesmo disco dos dados; aqui é só por limitação do laboratório.

## Cenários

| # | Cenário | Tipo |
|---|---|---|
| 01 | [Estratégia de backup e anatomia de um backup](Cenarios/cenario-01-estrategia-backup.md) | Rotina |
| 02 | [DELETE sem WHERE às 14:32](Cenarios/cenario-02-incidente-delete-sem-where.md) | Incidente |
| 03 | [O arquivo de dados sumiu](Cenarios/cenario-03-incidente-perda-arquivo-dados.md) | Incidente |
| 04 | [Cadeia de backup quebrada](Cenarios/cenario-04-incidente-cadeia-quebrada.md) | Incidente |
| 05 | [Corrupção de página](Cenarios/cenario-05-incidente-corrupcao.md) | Incidente |
| 06 | [Migrando um banco para outra instância](Cenarios/cenario-06-migracao-usuarios-orfaos.md) | Rotina |
| 07 | [Rotina de manutenção com Ola Hallengren](Cenarios/cenario-07-ola-hallengren.md) | Rotina |
| 08 | [Teste de restore automatizado](Cenarios/cenario-08-teste-restore-automatizado.md) | Rotina |
| 09 | [Restore por partes (piecemeal)](Cenarios/cenario-09-piecemeal-restore.md) | Incidente |
| 10 | [Perdemos o master](Cenarios/cenario-10-bancos-de-sistema.md) | Incidente |

## Como registrar as respostas

- `Respostas/cenario-NN.sql` ou `.ps1`.
- `Runbooks/`: todo incidente termina com um runbook. Ao fim da fase, você terá um **manual de recuperação** completo, o tipo de material que se mostra numa entrevista.

> Em todo incidente, cronometre do "chamado aberto" até "dados devolvidos" e registre o tempo no runbook. Esse é o seu **RTO real**, que você vai comparar com o RTO prometido no cenário 01.
