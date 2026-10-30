# NorthwindLab: lista de fechamento da Fase00

Nas listas anteriores, as escritas foram feitas em tabelas temporárias e as procedures foram substituídas por scripts. Esta lista faz o caminho inverso: **objetos reais, escrevendo em tabelas reais**, num banco de laboratório que pode ser destruído e recriado à vontade.

Respostas em [northwindlab-fechamento.sql](../Respostas/northwindlab-fechamento.sql).

---

### **Preparação**

0. **Criar o banco de laboratório**
   - Faça um backup `COPY_ONLY` do `Northwind` e restaure-o como `NorthwindLab`, usando `WITH MOVE` para dar nomes próprios aos arquivos `.mdf` e `.ldf`.
   - Deixe o script de restore pronto para ser executado de novo: ele será a forma de "zerar" o laboratório sempre que um exercício estragar os dados.
   - Todos os exercícios abaixo rodam no `NorthwindLab`, nunca no `Northwind`.

---

### **Tratamento de erros: o padrão definitivo**

1. **Tabela de log permanente**
   - Crie o schema `dba` e a tabela `dba.ErrorLog` com: `ErrorLogID`, `ErrorDate`, `LoginName`, `HostName`, `DatabaseName`, `ErrorNumber`, `ErrorSeverity`, `ErrorState`, `ErrorProcedure`, `ErrorLine`, `ErrorMessage`.
   - Crie a procedure `dba.usp_LogError`, que lê as funções `ERROR_*()` e grava uma linha nessa tabela. Ela será chamada de dentro do `CATCH` das procedures seguintes.

2. **Template de procedure transacional**
   - Escreva um template de procedure que use `SET NOCOUNT ON`, `SET XACT_ABORT ON`, `BEGIN TRY`/`BEGIN TRAN`, `IF @@TRANCOUNT > 0 ROLLBACK` no `CATCH`, chamada a `dba.usp_LogError` e `THROW` no final.
   - Demonstre, com três testes, o que acontece em cada caso:
     1. Erro de divisão por zero **sem** `XACT_ABORT`: a transação continua aberta? Confira com `SELECT @@TRANCOUNT` depois.
     2. O mesmo erro **com** `XACT_ABORT ON`.
     3. Um `CATCH` sem o `THROW` final: o chamador fica sabendo que houve erro?

3. **Log que sobrevive ao rollback**
   - Mostre que linhas inseridas numa **variável de tabela** durante uma transação continuam lá depois do `ROLLBACK`, e que as de uma **tabela temporária** não.
   - Use isso para registrar quais linhas estavam sendo processadas no momento da falha.

---

### **Procedures**

4. **Reajuste de preço com histórico**
   - Crie `dbo.PriceHistory` (`ProductID`, `OldPrice`, `NewPrice`, `ChangedAt`, `ChangedBy`).
   - Crie `dbo.usp_Product_AdjustPriceByCategory @CategoryName, @Percent`. Ela deve ser *set-based* (sem cursor), validar se a categoria existe e se o percentual está entre -50 e 100, e gravar o antes e o depois usando a cláusula `OUTPUT ... INTO`.

5. **Criação de pedido com Table-Valued Parameter**
   - Crie o tipo `dbo.OrderItemType` (`ProductID`, `Quantity`).
   - Crie `dbo.usp_Order_Create @CustomerID, @EmployeeID, @Items dbo.OrderItemType READONLY, @OrderID INT OUTPUT`.
   - A procedure deve:
     - inserir em `Orders` e obter o novo ID com `SCOPE_IDENTITY()`;
     - inserir os itens em `[Order Details]` usando o preço atual do produto;
     - baixar `UnitsInStock`;
     - falhar com mensagem clara (`THROW 50010, ...`) se algum produto não tiver estoque suficiente ou estiver descontinuado, sem deixar nada pela metade.
   - Teste chamando a procedure com um pedido válido e com um pedido em que só o terceiro item não tem estoque.

6. **Arquivamento em lote**
   - Crie `dbo.ArchivedCustomers` com a mesma estrutura de `Customers` mais a coluna `ArchivedAt`.
   - Crie `dbo.usp_Customer_Archive @ReferenceDate`, que move para o arquivo os clientes sem pedidos desde a data de referência, usando `DELETE ... OUTPUT deleted.* INTO`.
   - A procedure retorna quantos clientes foram arquivados.

7. **Sincronização com MERGE**
   - Crie uma tabela de staging `dbo.SupplierStaging` com alguns fornecedores novos e alguns já existentes, mas com telefone diferente.
   - Crie `dbo.usp_Supplier_Sync`, que usa `MERGE` para inserir os novos e atualizar os existentes, registrando `$action` via `OUTPUT`.
   - Pesquise e explique no chat: por que se recomenda `WITH (HOLDLOCK)` no `MERGE` e quais problemas conhecidos levam muitos DBAs a preferir `UPDATE` + `INSERT` separados.

8. **Cursor vs. set-based, medido**
   - Refaça o exercício 13 da lista 01 (frete em dobro para clientes do Brasil) de três formas:
     1. cursor padrão;
     2. cursor `LOCAL FAST_FORWARD`;
     3. um único `UPDATE` com `JOIN`.
   - Rode cada versão com `SET STATISTICS IO, TIME ON` e com o plano de execução real ligado. Compare leituras lógicas, tempo e número de planos gerados.

---

### **Funções e views**

9. **Função escalar vs. função inline**
   - Crie `dbo.fn_OrderTotal(@OrderID)` (escalar) e `dbo.itvf_OrderTotal(@OrderID)` (inline table-valued), ambas retornando o total do pedido com desconto.
   - Use cada uma num `SELECT` sobre todos os pedidos (a inline via `CROSS APPLY`) e compare `STATISTICS IO` e plano.
   - Repita a versão escalar com o banco em `COMPATIBILITY_LEVEL = 140` e depois em `160`. O que muda? Pesquise *Scalar UDF Inlining*.

10. **View indexada**
    - Crie `dbo.vw_SalesByEmployeeMonth` (funcionário, ano, mês, quantidade de pedidos e total vendido).
    - Transforme-a numa view indexada: `WITH SCHEMABINDING`, `COUNT_BIG(*)` e índice clustered único.
    - Liste no chat cada restrição que você encontrou e qual erro ela gerou.

---

### **Trigger**

11. **Auditoria multi-linha**
    - Crie um trigger `AFTER UPDATE` em `Products` que grave em `dbo.PriceHistory` somente quando `UnitPrice` realmente mudar, usando `inserted` e `deleted` com `JOIN` (nada de variáveis escalares).
    - Teste com um `UPDATE` que altera 10 produtos de uma vez e confirme que surgiram 10 linhas de histórico.
    - Depois, rode a procedure do exercício 4 e explique por que agora aparecem linhas duplicadas, e como resolver.

---

### **Permissões (introdução à Fase04)**

12. **Ownership chaining**
    - Crie um usuário sem login: `CREATE USER AppUser WITHOUT LOGIN`.
    - Conceda a ele apenas `EXECUTE` em `dbo.usp_Order_Create`.
    - Com `EXECUTE AS USER = 'AppUser'`, mostre que ele consegue criar pedidos pela procedure, mas não consegue fazer `SELECT` direto em `Orders`.
    - Crie uma segunda procedure que faça o mesmo `SELECT` usando `sp_executesql`, conceda `EXECUTE` e mostre que ela **falha**. Explique por quê.

---

### **Concorrência (introdução à Fase06)**

13. **Observando um bloqueio**
    - Na janela 1: `BEGIN TRAN`, depois um `UPDATE` em `Products` do produto 1, **sem commit**.
    - Na janela 2: `SELECT * FROM Products`. A consulta fica parada.
    - Na janela 3: descubra quem está bloqueando quem com `sys.dm_exec_requests` (`blocking_session_id`, `wait_type`) e `sys.dm_tran_locks`.
    - Resolva de duas formas: com `COMMIT` na janela 1, e com `KILL` na sessão bloqueadora. Anote o que acontece com o `UPDATE` em cada caso.

14. **Provocando um deadlock e tratando com retry**
    - Em duas janelas, faça transações que atualizem `Products` e `Orders` em **ordem inversa**, provocando o erro 1205.
    - Encontre o grafo do deadlock na sessão de Extended Events `system_health`.
    - Crie uma procedure que execute essa operação com até 3 tentativas, repetindo apenas quando `ERROR_NUMBER() = 1205`.
    - Explique qual seria a correção definitiva, que não depende de retry.
