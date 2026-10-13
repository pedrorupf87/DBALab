
USE NORTHWIND
GO

-----------------------------------
-- LISTA DE EXERCICIOS AVANCADOS --
-----------------------------------

------------------------------------------------------------------------------------------------------------------------------------------
-- 01
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_NEW_PRODUCTS
CREATE TABLE #TEMP_NEW_PRODUCTS
(
	ProductName NVARCHAR(40),
	SupplierId  INT,
	CategoryId  INT,
	UnitPrice   DECIMAL(10,2)
)

-- Carga da tabela base, conforme o enunciado
INSERT INTO #TEMP_NEW_PRODUCTS (ProductName, SupplierId, CategoryId, UnitPrice)
VALUES ('New Product A', 1, 1, 15.50),
       ('New Product B', 2, 2, 25.00)

-- Para não alterar a base, a inserção é feita em uma cópia temporária de Products.
-- O SELECT INTO leva junto a propriedade IDENTITY de ProductID, então os novos produtos recebem 78 e 79
DROP TABLE IF EXISTS #TEMP_PRODUCTS
SELECT ProductID,
       ProductName,
       SupplierID,
       CategoryID,
       UnitPrice
  INTO #TEMP_PRODUCTS
  FROM Products

INSERT INTO #TEMP_PRODUCTS (ProductName, SupplierID, CategoryID, UnitPrice)
SELECT np.ProductName, np.SupplierId, np.CategoryId, np.UnitPrice
  FROM #TEMP_NEW_PRODUCTS np
 WHERE NOT EXISTS ( SELECT 1
                      FROM #TEMP_PRODUCTS p
                     WHERE p.ProductName = np.ProductName )

SELECT ProductID, ProductName, SupplierID, CategoryID, UnitPrice
  FROM #TEMP_PRODUCTS
 WHERE ProductName IN ( SELECT ProductName FROM #TEMP_NEW_PRODUCTS )

DROP TABLE #TEMP_NEW_PRODUCTS
DROP TABLE #TEMP_PRODUCTS

------------------------------------------------------------------------------------------------------------------------------------------
-- 02
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_UPDATE_PRICE
CREATE TABLE #TEMP_UPDATE_PRICE
(
	ProductId   INT,
	ProductName VARCHAR(50),
	UnitPrice   DECIMAL(10,2)
)

INSERT INTO #TEMP_UPDATE_PRICE
SELECT ProductId,
	   ProductName,
	   UnitPrice
  FROM Products
 WHERE CategoryID   = 8
   AND Discontinued = 0

UPDATE t
   SET t.UnitPrice = 1.10 * UnitPrice
  FROM #TEMP_UPDATE_PRICE t

SELECT ProductId, ProductName, UnitPrice
  FROM Products
 WHERE CategoryID = 8 AND Discontinued = 0

SELECT * FROM #TEMP_UPDATE_PRICE
DROP TABLE #TEMP_UPDATE_PRICE

------------------------------------------------------------------------------------------------------------------------------------------
-- 03
------------------------------------------------------------------------------------------------------------------------------------------

-- Data de referência: último pedido da base (o Northwind termina em 1998)
DECLARE @RefDate03 DATETIME = ( SELECT MAX(OrderDate) FROM Orders )

DROP TABLE IF EXISTS #TEMP_DELETE_OD
CREATE TABLE #TEMP_DELETE_OD
(
	OrderId   INT,
	ProductId INT
)

-- Para não deletar os registros de 'Order Details', os itens que seriam excluídos vão para uma temporária.
-- São os itens de produtos SEM nenhuma venda nos últimos 2 anos (NOT EXISTS), e não os de produtos com alguma venda antiga
INSERT INTO #TEMP_DELETE_OD
SELECT od.OrderID,
       od.ProductID
  FROM [Order Details] od
 WHERE NOT EXISTS ( SELECT 1
                      FROM [Order Details] od2
                      JOIN Orders           o ON o.OrderID = od2.OrderID
                     WHERE od2.ProductID = od.ProductID
                       AND o.OrderDate  >= DATEADD(YEAR, -2, @RefDate03) )

-- No Northwind padrão o resultado é vazio: a base cobre menos de 2 anos, então todo produto vendido teve venda no período
SELECT * FROM #TEMP_DELETE_OD ORDER BY ProductId, OrderId
DROP TABLE #TEMP_DELETE_OD

------------------------------------------------------------------------------------------------------------------------------------------
-- 04
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_UPDATE_SHIPDATE
CREATE TABLE #TEMP_UPDATE_SHIPDATE
(
	OrderId      INT,
	CustomerId   CHAR(5),
	OrderDate    DATE,
	RequiredDate DATE,
	ShippedDate  DATE
)

INSERT INTO #TEMP_UPDATE_SHIPDATE
SELECT o.OrderID,
       o.CustomerID,
	   CAST(o.OrderDate AS DATE)    AS OrderDate,
	   CAST(o.RequiredDate AS DATE) AS RequiredDate,
	   CAST(o.ShippedDate AS DATE)  AS ShippedDate
  FROM Orders o
 WHERE ShippedDate IS NULL

UPDATE t
   SET t.ShippedDate = CAST(GETDATE() AS DATE)
  FROM #TEMP_UPDATE_SHIPDATE t

SELECT * FROM #TEMP_UPDATE_SHIPDATE
DROP TABLE #TEMP_UPDATE_SHIPDATE

------------------------------------------------------------------------------------------------------------------------------------------
-- 05
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_INSERT_OD
CREATE TABLE #TEMP_INSERT_OD
(
	OrderId   INT,
	ProductId INT,
	UnitPrice MONEY,
	Quantity  SMALLINT
)

-- Último pedido criado: maior OrderID existente
-- Produto mais vendido do último ano: maior soma de quantidade nos 12 meses anteriores ao último pedido da base
INSERT INTO #TEMP_INSERT_OD (OrderId, ProductId, UnitPrice, Quantity)
SELECT ( SELECT MAX(OrderID) FROM Orders ),
       p.ProductID,
       p.UnitPrice,
       10
  FROM Products p
 WHERE p.ProductID = (   SELECT TOP 1
                                od.ProductID
                           FROM [Order Details] od
                           JOIN Orders           o ON o.OrderID = od.OrderID
                          WHERE o.OrderDate >= DATEADD(YEAR, -1, ( SELECT MAX(OrderDate) FROM Orders ))
                       GROUP BY od.ProductID
                       ORDER BY SUM(od.Quantity) DESC )

SELECT * FROM #TEMP_INSERT_OD
DROP TABLE #TEMP_INSERT_OD

------------------------------------------------------------------------------------------------------------------------------------------
-- 06
------------------------------------------------------------------------------------------------------------------------------------------

-- Para não alterar a base, fornecedor e produto são inseridos em temporárias.
-- Nas tabelas reais, o SupplierID do novo fornecedor viria de SCOPE_IDENTITY()

DROP TABLE IF EXISTS #TEMP_INSERT_SUPPLIER
CREATE TABLE #TEMP_INSERT_SUPPLIER
(
	SupplierId  INT,
	CompanyName VARCHAR(40)
)

DROP TABLE IF EXISTS #TEMP_INSERT_PRODUCTS
CREATE TABLE #TEMP_INSERT_PRODUCTS
(
	ProductId   INT,
	ProductName VARCHAR(40),
	SupplierId  INT
)

DECLARE @SupplierId06 INT

BEGIN TRY
	BEGIN TRAN

	-- 1. Novo fornecedor
	SET @SupplierId06 = ( SELECT MAX(SupplierID) + 1 FROM Suppliers )

	INSERT INTO #TEMP_INSERT_SUPPLIER (SupplierId, CompanyName)
	VALUES ( @SupplierId06, 'Fornecedor Teste' )

	-- 2. Novo produto vinculado ao fornecedor inserido acima
	INSERT INTO #TEMP_INSERT_PRODUCTS (ProductId, ProductName, SupplierId)
	SELECT MAX(ProductID) + 1,
	       'Produto Teste',
	       @SupplierId06
	  FROM Products

	COMMIT TRAN
END TRY

BEGIN CATCH
	-- 3. Qualquer falha desfaz as duas inserções
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN

	PRINT 'ERRO: ' + ERROR_MESSAGE()
END CATCH

SELECT * FROM #TEMP_INSERT_SUPPLIER
SELECT * FROM #TEMP_INSERT_PRODUCTS

DROP TABLE #TEMP_INSERT_SUPPLIER
DROP TABLE #TEMP_INSERT_PRODUCTS

------------------------------------------------------------------------------------------------------------------------------------------
-- 07
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_UPDATE_DISCOUNT
CREATE TABLE #TEMP_UPDATE_DISCOUNT
(
	OrderID   INT,
	ProductId INT,
	UnitPrice MONEY,
	Quantity  SMALLINT,
	Discount  REAL
)

-- Produtos com preço acima do preço médio da SUA categoria (média calculada em Products)
INSERT INTO #TEMP_UPDATE_DISCOUNT
SELECT od.OrderID,
       od.ProductID,
       od.UnitPrice,
       od.Quantity,
       od.Discount
  FROM [Order Details] od
  JOIN Products         p ON p.ProductID = od.ProductID
 WHERE p.UnitPrice > ( SELECT AVG(p2.UnitPrice)
                         FROM Products p2
                        WHERE p2.CategoryID = p.CategoryID )

-- Desconto dobrado, limitado a 1: a tabela real tem CHECK de Discount entre 0 e 1
UPDATE t
   SET t.Discount = CASE WHEN t.Discount * 2.00 > 1 THEN 1 ELSE t.Discount * 2.00 END
  FROM #TEMP_UPDATE_DISCOUNT t

SELECT od.OrderID,
       od.ProductID,
       od.UnitPrice,
       od.Quantity,
       od.Discount
  FROM [Order Details] od
  JOIN Products         p ON p.ProductID = od.ProductID
 WHERE p.UnitPrice > ( SELECT AVG(p2.UnitPrice)
                         FROM Products p2
                        WHERE p2.CategoryID = p.CategoryID )

SELECT * FROM #TEMP_UPDATE_DISCOUNT

DROP TABLE #TEMP_UPDATE_DISCOUNT

------------------------------------------------------------------------------------------------------------------------------------------
-- 08
------------------------------------------------------------------------------------------------------------------------------------------

-- Para não deletar os registros da tabela 'Customers', irei armazenar em uma temporária

DROP TABLE IF EXISTS #TEMP_CUSTOMERS_ORDERS
CREATE TABLE #TEMP_CUSTOMERS_ORDERS
(
	CustomerId  CHAR(5),
	CompanyName VARCHAR(40),
	City        VARCHAR(15),
	Country     VARCHAR(15)
)

INSERT INTO #TEMP_CUSTOMERS_ORDERS
SELECT CustomerID,
       CompanyName,
	   City,
	   Country
  FROM Customers
 WHERE CustomerID NOT IN ( SELECT CustomerID 
                             FROM Orders )

SELECT * FROM #TEMP_CUSTOMERS_ORDERS
DROP TABLE #TEMP_CUSTOMERS_ORDERS

------------------------------------------------------------------------------------------------------------------------------------------
-- 09
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_UPDATE_COMPANY_NAME
CREATE TABLE #TEMP_UPDATE_COMPANY_NAME
(
	SupplierId   INT,
	CompanyName  VARCHAR(70),
	City         VARCHAR(30),
	Country      VARCHAR(50)
)

-- Fornecedores SEM nenhum produto ativo (NOT EXISTS), e não os que têm algum produto descontinuado
INSERT INTO #TEMP_UPDATE_COMPANY_NAME
SELECT s.SupplierID,
       s.CompanyName,
	   s.City,
	   s.Country
  FROM Suppliers s
 WHERE NOT EXISTS ( SELECT 1
                      FROM Products p
                     WHERE p.SupplierID   = s.SupplierID
                       AND p.Discontinued = 0 )

UPDATE t
   SET t.CompanyName = '[Inactive] ' + t.CompanyName
  FROM #TEMP_UPDATE_COMPANY_NAME t

SELECT s.SupplierID,
       s.CompanyName,
	   s.City,
	   s.Country
  FROM Suppliers s
 WHERE NOT EXISTS ( SELECT 1
                      FROM Products p
                     WHERE p.SupplierID   = s.SupplierID
                       AND p.Discontinued = 0 )

SELECT * FROM #TEMP_UPDATE_COMPANY_NAME
DROP TABLE #TEMP_UPDATE_COMPANY_NAME;

------------------------------------------------------------------------------------------------------------------------------------------
-- 10
------------------------------------------------------------------------------------------------------------------------------------------

-- "Para cada novo pedido inserido" pede um trigger AFTER INSERT em Orders.
-- Para não alterar a base, o trigger é criado, testado e desfeito dentro de uma transação.
-- O CREATE TRIGGER vai em EXEC porque precisa ser o primeiro comando do seu próprio lote.

-- O ROLLBACK desfaz o pedido de teste, mas não devolve o valor de IDENTITY consumido.
-- Por isso o contador de Orders é guardado aqui e restaurado no final
DECLARE @IdentOrders10 INT = IDENT_CURRENT('Orders')

BEGIN TRY
	BEGIN TRAN

	EXEC ('
	CREATE TRIGGER trg_Orders_DefaultItem
	    ON Orders
	 AFTER INSERT
	AS
	BEGIN
		SET NOCOUNT ON

		INSERT INTO [Order Details] (OrderID, ProductID, UnitPrice, Quantity, Discount)
		SELECT i.OrderID,
		       p.ProductID,
		       p.UnitPrice,
		       5,
		       0
		  FROM inserted i
		  JOIN Products p ON p.ProductID = 1
	END')

	-- Teste: novo pedido e o item padrão gerado pelo trigger
	INSERT INTO Orders (CustomerID, EmployeeID, OrderDate)
	VALUES ('ALFKI', 1, GETDATE())

	SELECT od.OrderID,
	       od.ProductID,
	       od.UnitPrice,
	       od.Quantity,
	       od.Discount
	  FROM [Order Details] od
	 WHERE od.OrderID = SCOPE_IDENTITY()

	ROLLBACK TRAN
END TRY

BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN

	PRINT 'ERRO: ' + ERROR_MESSAGE()
END CATCH

DBCC CHECKIDENT ('Orders', RESEED, @IdentOrders10) WITH NO_INFOMSGS

-----------------------------------------------------------------------------
-- PARA OS EXERCICIOS A SEGUIR, NAO IREI UTILIZAR O CONCEITO DE PROCEDURES --
-----------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------------------------
-- 11
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @CategoryId11 INT, 
        @Percentage11 FLOAT

SET @CategoryId11 = 1 
SET @Percentage11 = 40

DROP TABLE IF EXISTS #TEMP_UPDATE_PRODUCTS
CREATE TABLE #TEMP_UPDATE_PRODUCTS
(
	ProductId  INT,
	CategoryId INT,
	UnitPrice  MONEY
)

DECLARE CategoryCursor CURSOR FOR
SELECT CategoryID 
  FROM Categories

OPEN CategoryCursor
FETCH NEXT FROM CategoryCursor INTO @CategoryId11

WHILE @@FETCH_STATUS = 0
BEGIN
	DECLARE @CategoryIdCheck INT 
	    SET @CategoryIdCheck = ( SELECT CategoryID FROM Categories WHERE CategoryID = @CategoryId11 )
	
	IF ( @CategoryIdCheck = @CategoryId11 )
	BEGIN
		INSERT INTO #TEMP_UPDATE_PRODUCTS
		SELECT ProductID,
		       CategoryID,
		       UnitPrice
		  FROM Products
		 WHERE CategoryID = @CategoryId11
		
		UPDATE t
		   SET t.UnitPrice  = t.UnitPrice * ( 1 + @Percentage11 / 100 )
		  FROM #TEMP_UPDATE_PRODUCTS t
		 WHERE t.CategoryId = @CategoryId11
	END	
	
	FETCH NEXT FROM CategoryCursor INTO @CategoryId11
END

CLOSE CategoryCursor
DEALLOCATE CategoryCursor

SELECT ProductID,
       CategoryID,
	   UnitPrice
  FROM Products
ORDER BY ProductID

SELECT * FROM #TEMP_UPDATE_PRODUCTS
DROP TABLE #TEMP_UPDATE_PRODUCTS

------------------------------------------------------------------------------------------------------------------------------------------
-- 12
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @ProductId12   INT,
        @ProductName12 VARCHAR(40),
		@SupplierId12  INT,
		@CategoryId12  INT,
		@UnitPrice12   MONEY

DROP TABLE IF EXISTS #TEMP_PROD12
CREATE TABLE #TEMP_PROD12
(
	ProductId12   INT,
	ProductName12 VARCHAR(40),
	SupplierId12  INT,
	CategoryId12  INT,
	UnitPrice12   MONEY
)

DROP TABLE IF EXISTS #TEMP_INSERT_PROD12
CREATE TABLE #TEMP_INSERT_PROD12
(
	ProductId12   INT,
	ProductName12 VARCHAR(40),
	SupplierId12  INT,
	CategoryId12  INT,
	UnitPrice12   MONEY
)

INSERT INTO #TEMP_PROD12
VALUES ( 78, 'Picanha Maturada', 4, 6, 250 ),
       ( 79, 'Queijo Coalho',    5, 4,  35 )

DECLARE InsertProductsCursor CURSOR FOR
SELECT ProductId12,
       ProductName12,
	   SupplierId12,
	   CategoryId12,
	   UnitPrice12
  FROM #TEMP_PROD12

OPEN InsertProductsCursor
FETCH NEXT FROM InsertProductsCursor INTO @ProductId12, @ProductName12, @SupplierId12, @CategoryId12, @UnitPrice12

WHILE @@FETCH_STATUS = 0
BEGIN
	-- Insere apenas a linha lida pelo FETCH (as variáveis), uma por volta do loop
	INSERT INTO #TEMP_INSERT_PROD12
	VALUES ( @ProductId12, @ProductName12, @SupplierId12, @CategoryId12, @UnitPrice12 )

	FETCH NEXT FROM InsertProductsCursor INTO @ProductId12, @ProductName12, @SupplierId12, @CategoryId12, @UnitPrice12
END

CLOSE InsertProductsCursor
DEALLOCATE InsertProductsCursor

SELECT * FROM #TEMP_INSERT_PROD12
DROP TABLE #TEMP_PROD12
DROP TABLE #TEMP_INSERT_PROD12

------------------------------------------------------------------------------------------------------------------------------------------
-- 13
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @Country13 VARCHAR(50),
        @OrderId13 INT,
        @Freight13 MONEY

SET @Country13 = 'Brazil'

DROP TABLE IF EXISTS #TEMP_UPDATE_FREIGHT_13
CREATE TABLE #TEMP_UPDATE_FREIGHT_13
(
	OrderId    INT,
	CustomerId CHAR(5),
	Country    VARCHAR(15),
	OldFreight MONEY,
	NewFreight MONEY
)

-- O filtro é pelo país do CLIENTE (Customers.Country), como pede o enunciado, e não pelo país de entrega
DECLARE FreightCountryCursor CURSOR FOR
SELECT o.OrderID,
       o.Freight
  FROM Orders    o
  JOIN Customers c ON c.CustomerID = o.CustomerID
 WHERE c.Country = @Country13

OPEN FreightCountryCursor
FETCH NEXT FROM FreightCountryCursor INTO @OrderId13, @Freight13

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #TEMP_UPDATE_FREIGHT_13
	SELECT o.OrderID,
	       o.CustomerID,
	       @Country13,
	       @Freight13,
	       @Freight13 * 2.0
	  FROM Orders o
	 WHERE o.OrderID = @OrderId13

	FETCH NEXT FROM FreightCountryCursor INTO @OrderId13, @Freight13
END

CLOSE FreightCountryCursor
DEALLOCATE FreightCountryCursor

SELECT * FROM #TEMP_UPDATE_FREIGHT_13
DROP TABLE #TEMP_UPDATE_FREIGHT_13

------------------------------------------------------------------------------------------------------------------------------------------
-- 14
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @ProductID14 INT

DROP TABLE IF EXISTS #TEMP_DELETE_PROD_14
CREATE TABLE #TEMP_DELETE_PROD_14
(
	ProductId INT
)

INSERT INTO #TEMP_DELETE_PROD_14
SELECT ProductID 
  FROM Products
 WHERE Discontinued = 1 
   AND ProductID NOT IN ( SELECT DISTINCT ProductID 
                                     FROM [Order Details]
                                    WHERE OrderID IN ( SELECT OrderID 
									                     FROM Orders 
														WHERE OrderDate >= DATEADD( YEAR, -5, GETDATE() )
													 ) 
                        )

-- SELECT * FROM #TEMP_DELETE_PROD_14

DECLARE ProductDeleteCursor CURSOR FOR
SELECT ProductID
  FROM Products
 WHERE Discontinued = 1 
   AND ProductID NOT IN ( SELECT DISTINCT ProductID 
                                     FROM [Order Details]
                                    WHERE OrderID IN ( SELECT OrderID 
									                     FROM Orders 
														WHERE OrderDate >= DATEADD( YEAR, -5, GETDATE() )
													 ) 
                        )

OPEN ProductDeleteCursor
FETCH NEXT FROM ProductDeleteCursor INTO @ProductID14

WHILE @@FETCH_STATUS = 0
BEGIN
    DELETE FROM #TEMP_DELETE_PROD_14 
	      WHERE ProductID = @ProductID14

    FETCH NEXT FROM ProductDeleteCursor INTO @ProductID14
END

CLOSE ProductDeleteCursor
DEALLOCATE ProductDeleteCursor

DROP TABLE #TEMP_DELETE_PROD_14

------------------------------------------------------------------------------------------------------------------------------------------
-- 15
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @OrderId15  INT,
        @QtyItens15 INT,
        @Extra15    REAL

DROP TABLE IF EXISTS #TEMP_UPDATE_DISCOUNT_15
CREATE TABLE #TEMP_UPDATE_DISCOUNT_15
(
	OrderId     INT,
	ProductId   INT,
	UnitPrice   MONEY,
	Quantity    INT,
	QtyItens    INT,
	OldDiscount REAL,
	NewDiscount REAL
)

-- "Pedidos com mais de 5 itens" = pedidos com mais de 5 linhas em Order Details
DECLARE ProgressiveDiscountCursor CURSOR FOR
  SELECT OrderID,
         COUNT(*) AS QtyItens
    FROM [Order Details]
GROUP BY OrderID
  HAVING COUNT(*) > 5

OPEN ProgressiveDiscountCursor
FETCH NEXT FROM ProgressiveDiscountCursor INTO @OrderId15, @QtyItens15

WHILE @@FETCH_STATUS = 0
BEGIN
	-- Desconto progressivo: cresce com a quantidade de itens do pedido
	SET @Extra15 = CASE WHEN @QtyItens15 <= 7  THEN 0.05
	                    WHEN @QtyItens15 <= 10 THEN 0.10
	                    ELSE 0.15
	                END

	INSERT INTO #TEMP_UPDATE_DISCOUNT_15
	SELECT OrderID,
	       ProductID,
	       UnitPrice,
	       Quantity,
	       @QtyItens15,
	       Discount,
	       CASE WHEN Discount + @Extra15 > 1 THEN 1 ELSE Discount + @Extra15 END
	  FROM [Order Details]
	 WHERE OrderID = @OrderId15

	FETCH NEXT FROM ProgressiveDiscountCursor INTO @OrderId15, @QtyItens15
END

CLOSE ProgressiveDiscountCursor
DEALLOCATE ProgressiveDiscountCursor

SELECT * FROM #TEMP_UPDATE_DISCOUNT_15 ORDER BY OrderId, ProductId
DROP TABLE #TEMP_UPDATE_DISCOUNT_15

------------------------------------------------------------------------------------------------------------------------------------------
-- 16
------------------------------------------------------------------------------------------------------------------------------------------

-- PENDENTE: exercícios 16 a 30 ainda não resolvidos

