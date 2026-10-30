# Fase01: Ambiente e instalação

Conhecer, instalar, atualizar e configurar instâncias SQL Server como um DBA faria em produção: com inventário, script, padrão documentado e capacidade de recuperar uma instância que não sobe.

## Ponto de partida (levantado em 30/10/2026)

| Item | Situação |
|---|---|
| Instância | `MSSQLSERVER` (default), SQL Server 2022 Developer, **16.0.1000.6 RTM, sem CU** |
| SQL Server Agent | Instalado, parado, início manual |
| SQL Server Browser | Desabilitado |
| Bancos de usuário | `Northwind`, `AdventureWorks2022` |
| Máquina | 12 núcleos lógicos, **7,7 GB de RAM** |
| Ferramentas | `sqlcmd` instalado; dbatools, Docker e Hyper-V ausentes |

A RAM é o principal limite do laboratório: duas instâncias cabem, desde que cada uma tenha `max server memory` bem ajustado (cenário 04).

## Cenários

| # | Cenário | Tipo |
|---|---|---|
| 01 | [Inventário da instância](Cenarios/cenario-01-inventario.md) | Rotina |
| 02 | [Aplicando a Cumulative Update](Cenarios/cenario-02-cumulative-update.md) | Rotina |
| 03 | [Segunda instância por instalação desassistida](Cenarios/cenario-03-instancia-desassistida.md) | Rotina |
| 04 | [Baseline de configuração](Cenarios/cenario-04-baseline-configuracao.md) | Rotina |
| 05 | [Aplicação não conecta na instância nomeada](Cenarios/cenario-05-incidente-conectividade.md) | Incidente |
| 06 | [A instância não sobe](Cenarios/cenario-06-incidente-instancia-nao-sobe.md) | Incidente |
| 07 | [Automação com dbatools](Cenarios/cenario-07-dbatools.md) | Rotina |

Faça os cenários na ordem: o 05 e o 06 dependem da instância criada no 03.

## Como registrar as respostas

- `Respostas/cenario-NN.sql` ou `.ps1`: scripts executados.
- `Runbooks/`: procedimentos escritos para outra pessoa conseguir repetir sem você. Todo cenário de incidente termina com um runbook.

> **Regra do laboratório:** cenários que quebram coisas de propósito são executados **somente na instância `INST02`**, nunca na default.
