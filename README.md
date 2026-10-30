# DBALab
Laboratório de estudos para migração de carreira para DBA
Atualmente, estou iniciando em SQL Server, contemplando os tópicos de Administração, Tuning, Backup e Replicação.

## Roteiro

| Fase | Tema | Status |
|---|---|---|
| [Fase00](SQLServer/Fase00-TSQL/) | T-SQL | Listas concluídas; fechamento a fazer |
| [Fase01](SQLServer/Fase01-Ambiente/) | Ambiente e instalação | Cenários prontos |
| [Fase02](SQLServer/Fase02-Internals/) | Internals e armazenamento | Cenários prontos |
| [Fase03](SQLServer/Fase03-Backup-Restore/) | Backup e restore | Cenários prontos |
| [Fase04](SQLServer/Fase04-Seguranca/) | Segurança | Não iniciada |
| [Fase05](SQLServer/Fase05-Tuning/) | Performance e tuning | Não iniciada |
| [Fase06](SQLServer/Fase06-Concorrencia/) | Concorrência | Não iniciada |
| [Fase07](SQLServer/Fase07-Automacao/) | Automação e monitoramento | Não iniciada |
| [Fase08](SQLServer/Fase08-HA-Replicacao/) | Alta disponibilidade e replicação | Não iniciada |
| [Fase09](SQLServer/Fase09-Nuvem/) | Nuvem (Azure SQL) | Não iniciada |

## Formato

A Fase00 é composta de listas de exercícios. A partir da Fase01, o laboratório é organizado em **cenários**: situações de rotina e incidentes simulados, como um chamado chegaria a um DBA. Cada fase tem:

- `Cenarios/`: os enunciados;
- `Respostas/`: os scripts executados (`.sql` e `.ps1`);
- `Runbooks/`: os procedimentos escritos para que outra pessoa consiga repeti-los.

## Ambiente

- SQL Server 2022 Developer Edition: instância default (`MSSQLSERVER`) e, a partir da Fase01, a instância nomeada `INST02`, usada nos testes destrutivos e como destino de restores.
- Bancos: `Northwind`, `AdventureWorks2022`, `NorthwindLab` e `BibliotecaLab`, os dois últimos criados na Fase00.
