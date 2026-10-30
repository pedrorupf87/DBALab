# Cenário 08: Compressão de dados

## Contexto

O storage do servidor está chegando ao limite e a compra de discos novos vai demorar. Antes de pedir verba, avalie quanto a compressão nativa do SQL Server economiza e quanto ela custa em CPU.

## Tarefas (numa cópia do `BibliotecaLab`)

1. Estime a economia de `ROW` e `PAGE` para `operacao.Emprestimo`, `cadastro.Leitor` e `cadastro.Livro` com `sp_estimate_data_compression_savings`.
2. Aplique `PAGE` em `operacao.Emprestimo` e compare:
   - tamanho antes e depois;
   - log gerado pelo rebuild;
   - `STATISTICS IO` e `STATISTICS TIME` de uma consulta que agrega 2 milhões de linhas, antes e depois.
3. Abra com `DBCC PAGE` uma página comprimida e localize o *compression information* (CI record) e o dicionário.
4. Faça um backup full do banco antes e depois da compressão de dados, com e sem `COMPRESSION` no backup. Monte uma tabela com os quatro tamanhos.
5. Crie um índice columnstore nonclustered em `operacao.Emprestimo` (datas, unidade, valores) e compare o tamanho dele com o da tabela comprimida em `PAGE`.

## Entregáveis

- `Respostas/cenario-08.sql`.
- Um parecer curto: em quais tabelas do `BibliotecaLab` você aplicaria compressão, e qual tipo.

## Para pesquisar

- Por que a compressão `PAGE` costuma ser ruim para tabelas com muitas atualizações.
- Diferença entre compressão de dados (`ROW`/`PAGE`), compressão de backup e a função `COMPRESS()`.
