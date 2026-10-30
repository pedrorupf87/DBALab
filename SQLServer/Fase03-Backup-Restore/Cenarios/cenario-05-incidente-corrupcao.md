# Cenário 05 (incidente): Corrupção de página

> **Somente em uma cópia descartável (`BibliotecaLab_C05`).** Este cenário danifica dados de propósito.

## Contexto

> **Alerta automático (03:10):** *Msg 824, Level 24: SQL Server detected a logical consistency-based I/O error: incorrect checksum...*
> Alguns relatórios de empréstimos começaram a falhar; o resto do sistema funciona.

## Preparação

1. Confirme que o banco usa `PAGE_VERIFY CHECKSUM` e faça backup full e de log.
2. Gere um pouco de carga e faça outro backup de log.
3. Escolha uma página de dados de `operacao.Emprestimo` (como no cenário 01 da Fase02) e corrompa-a. Duas opções:
   - `DBCC WRITEPAGE` (não documentado; exige o banco em `SINGLE_USER`);
   - colocar o banco `OFFLINE` e alterar alguns bytes do `.mdf` com um editor hexadecimal, no offset `página × 8192`.
4. Volte o banco para o ar e rode um `SELECT` que leia essa página.

## Tarefas

1. **Diagnóstico**
   - Rode `DBCC CHECKDB (BibliotecaLab_C05) WITH NO_INFOMSGS, ALL_ERRORMSGS`. Leia a saída inteira: qual objeto, qual índice, qual página e qual é o *repair level* mínimo sugerido?
   - Consulte `msdb.dbo.suspect_pages`.
   - A página é do índice clustered (dados) ou de um nonclustered? Isso muda tudo: veja a Parte B.
2. **Parte A: página de dados → page restore**
   - Restaure **apenas a página** danificada: `RESTORE DATABASE ... PAGE = '1:xxxx'` a partir do full, aplique os logs, faça um backup de log novo e restaure-o com `RECOVERY`.
   - Rode o `CHECKDB` de novo e confirme zero erros. Quanto tempo levou, comparado a um restore completo?
3. **Parte B: página de índice nonclustered**
   - Corrompa uma página de um índice **nonclustered** e corrija sem restore algum. Como? Por que isso é seguro?
4. **O que não fazer**
   - Numa outra cópia, rode `DBCC CHECKDB ... REPAIR_ALLOW_DATA_LOSS` e compare as linhas da tabela antes e depois. O que se perdeu, e por que essa opção é o último recurso?

## Entregáveis

- `Runbooks/incidente-corrupcao.md`: fluxo de decisão (nonclustered → rebuild; dados → page restore; muitas páginas → restore completo; sem backup → repair) e como avisar a infraestrutura sobre o storage.
- `Respostas/cenario-05.sql`.

## Para pesquisar

- Diferença entre os erros 823, 824 e 825, e por que o 825 é um aviso que não pode ser ignorado.
- Com que frequência rodar `CHECKDB` e como reduzir o custo em bancos grandes (`PHYSICAL_ONLY`, rodar numa cópia restaurada).
