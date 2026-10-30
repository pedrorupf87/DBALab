# Cenário 01: Anatomia de uma página

## Contexto

No exercício 3 da lista de fechamento do `BibliotecaLab`, você estimou o tamanho de uma linha de `operacao.Emprestimo` e quantas linhas cabem numa página. Agora vai conferir no disco.

## Tarefas

1. **Arquivos e espaço**
   - Liste os arquivos do `BibliotecaLab` com `sys.database_files`: tamanho, espaço usado (`FILEPROPERTY(name, 'SpaceUsed')`), crescimento e `max_size`.
   - Quantas páginas e extents a tabela `operacao.Emprestimo` ocupa? Use `sys.dm_db_partition_stats` e `sys.allocation_units`.
2. **Conferindo a estimativa**
   - Calcule o número médio de linhas por página (`row_count / in_row_data_page_count`) e compare com a sua estimativa. Se errou, descubra onde: overhead de linha, null bitmap, offset array, colunas de tamanho variável.
   - Consulte `avg_record_size_in_bytes` em `sys.dm_db_index_physical_stats` com o modo `DETAILED`.
3. **Abrindo uma página**
   - Encontre a página onde está o empréstimo de `EmprestimoID = 1` usando `sys.fn_PhysLocFormatter(%%physloc%%)`.
   - Ative `DBCC TRACEON(3604)` e abra a página com `DBCC PAGE (BibliotecaLab, 1, <página>, 3)`. Identifique o cabeçalho (`m_type`, `m_prevPage`, `m_nextPage`, `m_slotCnt`, `m_freeCnt`) e os valores das colunas da linha.
   - Repita com `sys.dm_db_page_info` (SQL Server 2019+), que é a alternativa documentada para o cabeçalho.
4. **Páginas especiais**
   - Abra as páginas 0, 1, 2 e 3 do arquivo de dados. O que é cada uma (file header, PFS, GAM, SGAM)?
5. **CHAR vs. VARCHAR**
   - No `InternalsLab`, crie duas tabelas idênticas, uma com `CHAR(200)` e outra com `VARCHAR(200)`. Insira 100 mil linhas com textos de 20 caracteres e compare páginas e tamanho.

## Entregáveis

- `Respostas/cenario-01.sql`.
- No chat ou num `.md`: um desenho (pode ser ASCII) de uma página de 8 KB com cabeçalho, linhas e offset array.

## Para pesquisar

- Extents uniformes vs. mistos. O que mudou a partir do SQL Server 2016 (`MIXED_PAGE_ALLOCATION`)?
- O que são as páginas IAM e como elas ligam uma tabela aos seus extents.
