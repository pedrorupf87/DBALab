# BibliotecaLab: modelagem e DDL (fechamento da Fase00)

Até aqui, todos os exercícios partiram de bancos prontos. Nesta lista você **projeta e constrói** um banco do zero: o `BibliotecaLab`, sistema de empréstimos de uma rede de bibliotecas.

Esse banco será **reaproveitado nas Fases 02 e 03** (internals, backup e restore), então capriche na carga de dados do exercício 11.

Respostas em [bibliotecalab-fechamento.sql](../Respostas/bibliotecalab-fechamento.sql). Para as respostas conceituais (exercício 1), use um `.md` com o mesmo nome.

---

### **Modelagem**

1. **Normalização a partir de uma planilha**
   - Hoje os empréstimos são controlados numa planilha com estas colunas:

     | Leitor | CPF | Telefones | Livro | ISBN | Autores | Editora | CidadeEditora | Unidade | DataEmprestimo | DataPrevista | DataDevolucao | Multa |
     |---|---|---|---|---|---|---|---|---|---|---|---|---|
     | Ana Souza | 12345678901 | 35 99999-0000, 35 3222-1111 | Dom Casmurro | 9788535910663 | Machado de Assis | Cia das Letras | São Paulo | Centro | 2026-03-01 | 2026-03-15 | 2026-03-20 | 7,50 |
     | Ana Souza | 12345678901 | 35 99999-0000, 35 3222-1111 | Sapiens | 9788525432186 | Yuval Harari | L&PM | Porto Alegre | Centro | 2026-03-01 | 2026-03-15 | NULL | NULL |
     | Bruno Lima | 98765432100 | 11 98888-7777 | Dom Casmurro | 9788535910663 | Machado de Assis | Cia das Letras | São Paulo | Bairro Alto | 2026-03-05 | 2026-03-19 | 2026-03-18 | 0,00 |

   - Considere que a biblioteca tem **vários exemplares** do mesmo livro, distribuídos entre as unidades.
   - Leve o modelo até a **3ª forma normal**. Para cada tabela, aponte qual anomalia (de inserção, atualização ou exclusão) ela elimina.
   - Entregue o modelo em texto ou em Mermaid (`erDiagram`) no `.md` de respostas.

---

### **Criação do banco**

2. **Banco com arquivos explícitos**
   - Crie o `BibliotecaLab` sem depender dos padrões do `model`:
     - arquivo de dados e de log em pastas definidas por você;
     - tamanho inicial de 512 MB para dados e 256 MB para log;
     - crescimento automático **em MB**, não em porcentagem;
     - recovery model `FULL`.
   - Explique no chat por que o crescimento em porcentagem é considerado má prática.

3. **Schemas e tipos de dados**
   - Organize as tabelas em schemas: `cadastro` (leitores, livros, autores, editoras, unidades, exemplares), `operacao` (empréstimos, reservas, multas) e `auditoria`.
   - Escolha e **justifique** o tipo de cada coluna. No mínimo, responda:
     - CPF: `CHAR(11)`, `VARCHAR(14)` ou `BIGINT`?
     - ISBN: `CHAR(13)` ou `BIGINT`?
     - Valores de multa: `DECIMAL(10,2)` ou `MONEY`?
     - Datas de empréstimo: `DATE`, `DATETIME` ou `DATETIME2(0)`?
     - Nomes: `VARCHAR` ou `NVARCHAR`? E com qual tamanho?
   - Estime o tamanho em bytes de uma linha de `operacao.Emprestimo` e quantas linhas cabem numa página de 8 KB. Você vai conferir essa conta na Fase02.

4. **Constraints com nomes**
   - Defina um padrão de nomenclatura (ex.: `PK_Tabela`, `FK_Filha_Pai`, `UQ_Tabela_Coluna`, `CK_Tabela_Regra`, `DF_Tabela_Coluna`) e aplique-o a **todas** as constraints. Nenhuma pode ficar com nome gerado pelo sistema.
   - Crie, no mínimo:
     - PKs (decida e justifique: chave substituta `IDENTITY` ou chave natural?);
     - `UNIQUE` em CPF e ISBN;
     - FKs com a ação de `ON DELETE` adequada a cada caso. Por exemplo: excluir uma editora deve ser proibido; excluir um leitor deve fazer o quê?;
     - `CHECK` para `DataDevolucao >= DataEmprestimo`, `Multa >= 0` e situação do exemplar dentro de uma lista de valores;
     - `DEFAULT` para a data do empréstimo.
   - Escreva um bloco de testes que **tente violar cada constraint** e mostre o erro gerado.

5. **IDENTITY vs. SEQUENCE**
   - Empréstimos e reservas devem compartilhar uma numeração única de protocolo. Implemente isso com uma `SEQUENCE`.
   - Mostre que tanto `IDENTITY` quanto `SEQUENCE` geram **lacunas** após um `ROLLBACK`.
   - Crie um trigger em `operacao.Emprestimo` que insira em `auditoria`, e mostre a diferença entre `SCOPE_IDENTITY()`, `@@IDENTITY` e `IDENT_CURRENT()` depois de um insert.

---

### **Evolução e manutenção do modelo**

6. **FKs sem índice**
   - Escreva uma consulta nas views de catálogo (`sys.foreign_keys`, `sys.foreign_key_columns`, `sys.index_columns`) que liste as colunas de FK que **não** são a primeira coluna de nenhum índice.
   - Crie os índices que faltarem.
   - Explique no chat por que isso importa para o `DELETE` na tabela pai.

7. **Tabela temporal**
   - Transforme `cadastro.Leitor` numa *system-versioned temporal table*.
   - Altere o endereço de um leitor três vezes e consulte com `FOR SYSTEM_TIME AS OF` e `FOR SYSTEM_TIME ALL`.

8. **Colunas calculadas**
   - Adicione em `operacao.Emprestimo` uma coluna calculada `DiasAtraso` (diferença entre devolução e data prevista) e tente torná-la `PERSISTED`.
   - Depois tente o mesmo usando `GETDATE()` para empréstimos ainda não devolvidos. Explique o erro e o conceito de **determinismo**.

9. **Alterações que custam caro** (só depois do exercício 11)
   - Com a tabela de empréstimos já carregada, meça o crescimento do log (`sys.dm_db_log_space_usage`) e o tempo de cada operação abaixo:
     1. `ADD` de uma coluna `NOT NULL` com `DEFAULT`;
     2. `ADD` de uma coluna que aceita `NULL`, sem default;
     3. `ALTER COLUMN` de `INT` para `BIGINT` na PK. Antes, remova as FKs que apontam para ela e a própria PK, e recrie tudo depois. Inclua essa recriação no tempo medido.
   - Quais foram instantâneas (*metadata-only*) e quais reescreveram a tabela inteira? Por que essa diferença importa numa janela de manutenção em produção?

10. **Dicionário de dados gerado pelo catálogo**
    - Documente tabelas e colunas com *extended properties* (`MS_Description`).
    - Escreva uma consulta em `sys.tables`, `sys.columns`, `sys.types` e `sys.extended_properties` que gere o dicionário de dados: schema, tabela, coluna, tipo, tamanho, nulidade, default e descrição.

---

### **Carga e entrega**

11. **Carga volumosa set-based**
    - Popule o banco sem cursores e sem `WHILE` linha a linha. Use `GENERATE_SERIES` (SQL Server 2022) ou uma tabela de números.
    - Volumes mínimos:
      - 5 unidades;
      - 50 mil leitores;
      - 20 mil livros;
      - 100 mil exemplares;
      - **2 milhões de empréstimos** distribuídos entre 2020 e 2026, com cerca de 10% atrasados e 3% ainda abertos.
    - Meça o tempo total e o tamanho final dos arquivos de dados e de log. Compare o log com o que você esperava.

12. **Script de deploy idempotente**
    - Junte toda a DDL (schemas, tabelas, constraints, índices, sequence, trigger) num único script que possa ser executado **várias vezes** sem erro e sem duplicar nada. Use `IF NOT EXISTS`, `CREATE OR ALTER` e `DROP ... IF EXISTS` onde fizer sentido.
    - Teste rodando o script duas vezes seguidas num banco vazio e depois num banco já criado.
