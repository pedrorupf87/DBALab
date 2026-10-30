# Cenário 07: Rotina de manutenção com Ola Hallengren

## Contexto

Os backups feitos à mão nos cenários anteriores precisam virar rotina. A solução gratuita de Ola Hallengren (*SQL Server Maintenance Solution*) é usada em grande parte das empresas que têm SQL Server, e é bem provável que você a encontre no seu primeiro emprego como DBA.

## Tarefas

1. **Instalação**
   - Crie um banco administrativo `DBAdmin` nas duas instâncias.
   - Baixe o `MaintenanceSolution.sql` do site oficial, leia o cabeçalho de parâmetros e instale no `DBAdmin` com criação dos jobs, apontando para `C:\SQLBackup`.
2. **Configuração conforme a estratégia**
   - Ajuste os jobs e agendas para implementar a estratégia do cenário 01 (full, diferencial e log para cada banco).
   - Use, pelo menos, os parâmetros `@CheckSum`, `@Compress`, `@Verify`, `@CleanupTime` e `@LogToTable`.
   - Configure `DatabaseIntegrityCheck` (CHECKDB) semanal e `IndexOptimize` semanal. Pesquise e decida os limites de fragmentação.
3. **Verificação**
   - Deixe rodando por algumas horas com carga simulada.
   - Analise `DBAdmin.dbo.CommandLog`: duração de cada backup, falhas, tamanhos.
   - Confira a estrutura de pastas que a solução cria e a limpeza de arquivos antigos.
4. **Falha proposital**
   - Faça um job falhar (por exemplo, retire a permissão da conta do Agent na pasta de backup) e descubra o erro pelo histórico do job e pelo `CommandLog`.
   - Como você ficaria sabendo disso às 3h da manhã? Isso será resolvido na Fase07 (alertas e Database Mail).

## Entregáveis

- `Respostas/cenario-07.sql` com as chamadas de cada job.
- Atualize `Runbooks/estrategia-backup.md` com a implementação.

## Para pesquisar

- Diferença entre `@CleanupTime` e uma rotina de limpeza separada, e por que a ordem "backup e depois limpeza" importa.
- `IndexOptimize` com `@UpdateStatistics = 'ALL'` e `@OnlyModifiedStatistics = 'Y'`.
