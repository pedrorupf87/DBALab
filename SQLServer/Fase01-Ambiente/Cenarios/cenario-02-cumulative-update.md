# Cenário 02: Aplicando a Cumulative Update

## Contexto

O inventário do cenário 01 mostrou que a instância está na versão RTM, sem nenhuma Cumulative Update (CU). São muitos meses de correções de bugs e de segurança pendentes. A gerência autorizou a atualização, desde que haja plano de retorno.

## Tarefas

1. **Antes de atualizar**
   - Identifique a CU mais recente do SQL Server 2022 e leia as notas da versão. Há algum problema conhecido que afete o seu ambiente?
   - Faça backup de **todos** os bancos, incluindo `master`, `msdb` e `model`, e confirme que os arquivos existem.
   - Anote a versão atual exata (`SELECT @@VERSION`) para comparar depois.
2. **Atualização**
   - Aplique a CU. Na primeira vez use o assistente gráfico. Depois pesquise a sintaxe para aplicar pela linha de comando (`/quiet /IAcceptSQLServerLicenseTerms /Action=Patch /InstanceName=...`), que você usará na `INST02` no cenário 03.
   - Localize o log de instalação (`Setup Bootstrap\Log`) e leia o `Summary.txt`.
3. **Validação**
   - Confirme a nova versão.
   - Verifique se todos os bancos estão `ONLINE` e se o ERRORLOG tem algum erro após o restart.
   - Rode uma consulta simples no `Northwind` e no `AdventureWorks2022`.
4. **Plano de retorno**
   - Descreva como desinstalar a CU (Painel de Controle, *Exibir atualizações instaladas*) e em que situação você faria isso.

## Entregáveis

- `Runbooks/atualizacao-cu.md`: checklist de antes, durante e depois, reaproveitável para qualquer CU futura.
- Atualize a ficha `Runbooks/inventario-MSSQLSERVER.md` com a nova versão.

## Para pesquisar

- Diferença entre CU, GDR e Service Pack. Por que o SQL Server deixou de ter Service Packs a partir da versão 2017?
- *Modern Servicing Model* e o que é o "branch GDR" de uma instalação.
- Por que se recomenda aplicar a CU primeiro em homologação e esperar algumas semanas após o lançamento.
