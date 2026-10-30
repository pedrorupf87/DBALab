# Cenário 09 (incidente): Restore por partes (piecemeal)

## Contexto

> **Chamado #1260:** "O servidor precisa ser reconstruído e o `BibliotecaLab` restaurado do zero. A operação das bibliotecas precisa voltar **o quanto antes**; os relatórios históricos podem esperar até amanhã."

Este cenário usa a cópia com o filegroup `FG_Historico` somente leitura, criada no cenário 07 da Fase02.

## Preparação

1. No banco com `FG_Historico` em `READ_ONLY`, faça:
   - um backup **do filegroup somente leitura** (uma única vez, já que ele não muda mais);
   - backups **parciais** dos filegroups de leitura e escrita (`BACKUP DATABASE ... READ_WRITE_FILEGROUPS`);
   - backups de log.
2. Compare o tamanho e o tempo do backup parcial com os de um full do banco inteiro.

## Tarefas

1. **Fase 1: operação de volta**
   - Restaure na `INST02` **apenas** o `PRIMARY` e os filegroups de leitura e escrita (`WITH PARTIAL`), aplique os logs e coloque o banco online.
   - Mostre que `operacao.Emprestimo` funciona normalmente e que uma consulta na tabela histórica falha. Qual é o erro? Qual é o estado do arquivo em `sys.master_files`?
2. **Fase 2: histórico de volta**
   - Com o banco online e recebendo carga, restaure o `FG_Historico` a partir do backup do filegroup.
   - Ele precisa de backups de log? Por que sim ou por que não, sendo somente leitura?
3. **Medição**
   - Tempo até a operação voltar (fase 1) × tempo de um restore completo convencional.

## Entregáveis

- `Runbooks/restore-piecemeal.md`.
- `Respostas/cenario-09.sql`.

## Para pesquisar

- Restore piecemeal online é recurso da edição Enterprise (a Developer tem todos os recursos dela). O que muda na edição Standard?
- Como essa técnica se combina com particionamento em bancos de vários terabytes.
