
USE Northwind
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

INSERT INTO #TEMP_NEW_PRODUCTS (ProductName, SupplierId, CategoryId, UnitPrice)
VALUES ('New Product A', 1, 1, 15.50),
       ('New Product B', 2, 2, 25.00)

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
SELECT p.ProductID,
	   p.ProductName,
	   p.UnitPrice
  FROM Products   p
  JOIN Categories c ON c.CategoryID = p.CategoryID
 WHERE c.CategoryName = 'Seafood'
   AND p.Discontinued = 0

UPDATE t
   SET t.UnitPrice = 1.10 * UnitPrice
  FROM #TEMP_UPDATE_PRICE t

SELECT p.ProductID, p.ProductName, p.UnitPrice
  FROM Products   p
  JOIN Categories c ON c.CategoryID = p.CategoryID
 WHERE c.CategoryName = 'Seafood' 
   AND p.Discontinued = 0

SELECT * FROM #TEMP_UPDATE_PRICE
DROP TABLE #TEMP_UPDATE_PRICE

------------------------------------------------------------------------------------------------------------------------------------------
-- 03
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @RefDate03 DATETIME = ( SELECT MAX(OrderDate) FROM Orders )

DROP TABLE IF EXISTS #TEMP_DELETE_OD
CREATE TABLE #TEMP_DELETE_OD
(
	OrderId   INT,
	ProductId INT
)

INSERT INTO #TEMP_DELETE_OD
SELECT od.OrderID,
       od.ProductID
  FROM [Order Details] od
 WHERE NOT EXISTS ( SELECT 1
                      FROM [Order Details] od2
                      JOIN Orders          o   ON o.OrderID = od2.OrderID
                     WHERE od2.ProductID = od.ProductID
                       AND o.OrderDate >= DATEADD(YEAR, -2, @RefDate03) )

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
SELECT DISTINCT
       o.OrderID,
       o.CustomerID,
	   CAST(o.OrderDate AS DATE)    AS OrderDate,
	   CAST(o.RequiredDate AS DATE) AS RequiredDate,
	   CAST(o.ShippedDate AS DATE)  AS ShippedDate
  FROM Orders           o
  JOIN [Order Details] od ON od.OrderID = o.OrderID
 WHERE o.ShippedDate IS NULL

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

UPDATE t
   SET t.Discount = CASE WHEN t.Discount * 2.00 > 1 THEN 1 
                         ELSE t.Discount * 2.00 
						  END
  FROM #TEMP_UPDATE_DISCOUNT t

SELECT od.OrderID,
       od.ProductID,
       od.UnitPrice,
       od.Quantity,
       od.Discount
  FROM [Order Details] od
  JOIN Products        p  ON p.ProductID = od.ProductID
 WHERE p.UnitPrice > ( SELECT AVG(p2.UnitPrice)
                         FROM Products p2
                        WHERE p2.CategoryID = p.CategoryID )

SELECT * FROM #TEMP_UPDATE_DISCOUNT

DROP TABLE #TEMP_UPDATE_DISCOUNT

------------------------------------------------------------------------------------------------------------------------------------------
-- 08
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_CUSTOMERS_ORDERS
CREATE TABLE #TEMP_CUSTOMERS_ORDERS
(
	CustomerId  CHAR(5),
	CompanyName VARCHAR(40),
	City        VARCHAR(15),
	Country     VARCHAR(15)
)

   INSERT INTO #TEMP_CUSTOMERS_ORDERS
   SELECT c.CustomerID,
          c.CompanyName,
	      c.City,
	      c.Country
     FROM Customers c
LEFT JOIN Orders    o ON o.CustomerID = c.CustomerID
    WHERE o.OrderID IS NULL

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

DECLARE @ProductId     INT,
        @UnitsInStock  INT,
        @QtyNecessaria INT

DROP TABLE IF EXISTS #TEMP_REABASTECIMENTO_16
CREATE TABLE #TEMP_REABASTECIMENTO_16
(
    ProductId           INT,
    QtyNecessaria       INT,
    DataReabastecimento DATETIME
)

DECLARE LowStockCursor CURSOR FOR
 SELECT ProductID,
        UnitsInStock
   FROM Products
  WHERE UnitsInStock < 10

OPEN LowStockCursor
FETCH NEXT FROM LowStockCursor INTO @ProductId, @UnitsInStock

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Quantidade necessária para levar o estoque até 20 unidades
    SET @QtyNecessaria = 20 - @UnitsInStock

    INSERT INTO #TEMP_REABASTECIMENTO_16(ProductId, QtyNecessaria, DataReabastecimento)
    VALUES (@ProductId, @QtyNecessaria, GETDATE())

    FETCH NEXT FROM LowStockCursor INTO @ProductId, @UnitsInStock
END

CLOSE LowStockCursor
DEALLOCATE LowStockCursor

SELECT *
  FROM #TEMP_REABASTECIMENTO_16
 ORDER BY ProductId

DROP TABLE #TEMP_REABASTECIMENTO_16

------------------------------------------------------------------------------------------------------------------------------------------
-- 17
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @RefDate17     DATETIME = (SELECT MAX(OrderDate) FROM Orders),
        @CustomerId17  CHAR(5),
        @CompanyName17 VARCHAR(40)

DROP TABLE IF EXISTS #TEMP_NOTIFICACAO_17
CREATE TABLE #TEMP_NOTIFICACAO_17
(
	CustomerId  CHAR(5),
	CompanyName VARCHAR(40),
	Mensagem    VARCHAR(200),
	DataEnvio   DATETIME
)

DECLARE NotifyCursor CURSOR FOR
 SELECT c.CustomerID,
        c.CompanyName
   FROM Customers c
  WHERE NOT EXISTS (SELECT 1
                      FROM Orders o
                     WHERE o.CustomerID = c.CustomerID
                       AND o.OrderDate >= DATEADD(YEAR, -2, @RefDate17))

OPEN NotifyCursor
FETCH NEXT FROM NotifyCursor INTO @CustomerId17, @CompanyName17

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #TEMP_NOTIFICACAO_17 (CustomerId, CompanyName, Mensagem, DataEnvio)
	VALUES ( @CustomerId17, @CompanyName17, 'Cliente sem pedidos nos ultimos 2 anos.', GETDATE() )

	FETCH NEXT FROM NotifyCursor INTO @CustomerId17, @CompanyName17
END

CLOSE NotifyCursor
DEALLOCATE NotifyCursor

SELECT * FROM #TEMP_NOTIFICACAO_17 ORDER BY CustomerId
DROP TABLE #TEMP_NOTIFICACAO_17

------------------------------------------------------------------------------------------------------------------------------------------
-- 18
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @ProductId18 INT,
        @Receita18   MONEY

DROP TABLE IF EXISTS #TEMP_RECEITA_PRODUTO_18
CREATE TABLE #TEMP_RECEITA_PRODUTO_18
(
	ProductId   INT,
	ProductName VARCHAR(40),
	Receita     MONEY
)

DECLARE RevenueProductCursor CURSOR FOR
 SELECT ProductID
   FROM Products

OPEN RevenueProductCursor
FETCH NEXT FROM RevenueProductCursor INTO @ProductId18

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @Receita18 = ISNULL(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 0)
	  FROM [Order Details] od
	 WHERE od.ProductID = @ProductId18

	INSERT INTO #TEMP_RECEITA_PRODUTO_18 (ProductId, ProductName, Receita)
	SELECT ProductID,
	       ProductName,
	       @Receita18
	  FROM Products
	 WHERE ProductID = @ProductId18

	FETCH NEXT FROM RevenueProductCursor INTO @ProductId18
END

CLOSE RevenueProductCursor
DEALLOCATE RevenueProductCursor

SELECT * FROM #TEMP_RECEITA_PRODUTO_18 ORDER BY Receita DESC, ProductId
DROP TABLE #TEMP_RECEITA_PRODUTO_18

------------------------------------------------------------------------------------------------------------------------------------------
-- 19
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @SupplierId19 INT

DROP TABLE IF EXISTS #TEMP_SUPPLIERS_19
CREATE TABLE #TEMP_SUPPLIERS_19
(
	SupplierId INT
)

INSERT INTO #TEMP_SUPPLIERS_19 (SupplierId)
VALUES (1), (2), (3)

DROP TABLE IF EXISTS #TEMP_BACKUP_PRODUTOS_19
CREATE TABLE #TEMP_BACKUP_PRODUTOS_19
(
	ProductId    INT,
	ProductName  VARCHAR(40),
	SupplierId   INT,
	CategoryId   INT,
	UnitPrice    MONEY,
	UnitsInStock SMALLINT
)

DECLARE SupplierBackupCursor CURSOR FOR
 SELECT SupplierId
   FROM #TEMP_SUPPLIERS_19

OPEN SupplierBackupCursor
FETCH NEXT FROM SupplierBackupCursor INTO @SupplierId19

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #TEMP_BACKUP_PRODUTOS_19
	SELECT ProductID,
	       ProductName,
	       SupplierID,
	       CategoryID,
	       UnitPrice,
	       UnitsInStock
	  FROM Products
	 WHERE SupplierID = @SupplierId19

	FETCH NEXT FROM SupplierBackupCursor INTO @SupplierId19
END

CLOSE SupplierBackupCursor
DEALLOCATE SupplierBackupCursor

SELECT * FROM #TEMP_BACKUP_PRODUTOS_19 ORDER BY SupplierId, ProductId
DROP TABLE #TEMP_SUPPLIERS_19
DROP TABLE #TEMP_BACKUP_PRODUTOS_19

------------------------------------------------------------------------------------------------------------------------------------------
-- 20
------------------------------------------------------------------------------------------------------------------------------------------

-- No banco Northwind classico nao tem peso em Products
-- Entao vou assumir que: peso unitario simulado sera (ProductID % 10) + 1, e frete novo = peso total * 0.50

DECLARE @OrderId20    INT,
        @OldFreight20 MONEY,
        @PesoTotal20  DECIMAL(10,2),
        @NewFreight20 MONEY

DROP TABLE IF EXISTS #TEMP_UPDATE_FREIGHT_PESO_20
CREATE TABLE #TEMP_UPDATE_FREIGHT_PESO_20
(
	OrderId    INT,
	PesoTotal  DECIMAL(10,2),
	OldFreight MONEY,
	NewFreight MONEY
)

DECLARE FreightWeightCursor CURSOR FOR
 SELECT OrderID,
        Freight
   FROM Orders

OPEN FreightWeightCursor
FETCH NEXT FROM FreightWeightCursor INTO @OrderId20, @OldFreight20

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @PesoTotal20 = ISNULL(SUM(od.Quantity * ((p.ProductID % 10) + 1)), 0)
	  FROM [Order Details] od
	  JOIN Products        p  ON p.ProductID = od.ProductID
	 WHERE od.OrderID = @OrderId20

	SET @NewFreight20 = CAST(@PesoTotal20 * 0.50 AS MONEY)

	INSERT INTO #TEMP_UPDATE_FREIGHT_PESO_20 (OrderId, PesoTotal, OldFreight, NewFreight)
	VALUES (@OrderId20, @PesoTotal20, @OldFreight20, @NewFreight20)

	FETCH NEXT FROM FreightWeightCursor INTO @OrderId20, @OldFreight20
END

CLOSE FreightWeightCursor
DEALLOCATE FreightWeightCursor

SELECT * FROM #TEMP_UPDATE_FREIGHT_PESO_20 ORDER BY OrderId
DROP TABLE #TEMP_UPDATE_FREIGHT_PESO_20

------------------------------------------------------------------------------------------------------------------------------------------
-- 21
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @ProductId21 INT

DROP TABLE IF EXISTS #TEMP_DISCONTINUED_21
CREATE TABLE #TEMP_DISCONTINUED_21
(
	ProductId    INT,
	ProductName  VARCHAR(40),
	Discontinued BIT,
	DataRegistro DATETIME
)

DECLARE DiscCursor CURSOR FOR
 SELECT ProductID
   FROM Products
  WHERE Discontinued = 1

-- OPEN antes do TRY e CLOSE/DEALLOCATE depois do CATCH: o cursor e liberado mesmo se der erro
OPEN DiscCursor

BEGIN TRY
	BEGIN TRAN

	FETCH NEXT FROM DiscCursor INTO @ProductId21

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #TEMP_DISCONTINUED_21 (ProductId, ProductName, Discontinued, DataRegistro)
		SELECT ProductID,
		       ProductName,
		       Discontinued,
		       GETDATE()
		  FROM Products
		 WHERE ProductID = @ProductId21

		FETCH NEXT FROM DiscCursor INTO @ProductId21
	END

	COMMIT TRAN
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN

	PRINT 'ERRO: ' + ERROR_MESSAGE()
END CATCH

CLOSE DiscCursor
DEALLOCATE DiscCursor

SELECT * FROM #TEMP_DISCONTINUED_21 ORDER BY ProductId
DROP TABLE #TEMP_DISCONTINUED_21

------------------------------------------------------------------------------------------------------------------------------------------
-- 22
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @CategoryId22 INT

DROP TABLE IF EXISTS #TEMP_PRICE_22
CREATE TABLE #TEMP_PRICE_22
(
	ProductId  INT,
	CategoryId INT,
	OldPrice   MONEY,
	NewPrice   MONEY
)

BEGIN TRAN

DECLARE CatPriceCursor CURSOR FOR
  SELECT CategoryID
    FROM Categories
ORDER BY CategoryID

OPEN CatPriceCursor
FETCH NEXT FROM CatPriceCursor INTO @CategoryId22

WHILE @@FETCH_STATUS = 0
BEGIN
	BEGIN TRY
		SAVE TRAN SaveCat22

		INSERT INTO #TEMP_PRICE_22 (ProductId, CategoryId, OldPrice, NewPrice)
		SELECT ProductID,
		       CategoryID,
		       UnitPrice,
		       UnitPrice * 1.05
		  FROM Products
		 WHERE CategoryID = @CategoryId22

		-- O cenario @CategoryId22 = 8 eh so pra simular um erro. Fica DEPOIS do INSERT:
		-- assim os produtos da categoria 8 ja foram gravados e o ROLLBACK ao savepoint precisa desfaze-los
		IF @CategoryId22 = 8
			RAISERROR('Falha simulada na categoria 8', 16, 1)
	END TRY
	BEGIN CATCH
		IF XACT_STATE() = 1
			ROLLBACK TRAN SaveCat22

		PRINT 'Categoria ' + CAST(@CategoryId22 AS VARCHAR(10)) + ' revertida: ' + ERROR_MESSAGE()
	END CATCH

	FETCH NEXT FROM CatPriceCursor INTO @CategoryId22
END

CLOSE CatPriceCursor
DEALLOCATE CatPriceCursor

COMMIT TRAN

SELECT * FROM #TEMP_PRICE_22 ORDER BY CategoryId, ProductId
DROP TABLE #TEMP_PRICE_22

------------------------------------------------------------------------------------------------------------------------------------------
-- 23
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @Anos23    INT = 5,
        @RefDate23 DATETIME = (SELECT MAX(OrderDate) FROM Orders),
        @OrderId23 INT

DROP TABLE IF EXISTS #TEMP_ORDERS_23
CREATE TABLE #TEMP_ORDERS_23
(
	OrderId   INT,
	OrderDate DATETIME
)

DROP TABLE IF EXISTS #TEMP_OD_23
CREATE TABLE #TEMP_OD_23
(
	OrderId   INT,
	ProductId INT
)

DROP TABLE IF EXISTS #TEMP_EXCLUIDOS_23
CREATE TABLE #TEMP_EXCLUIDOS_23
(
	OrderId   INT,
	ProductId INT,
	Etapa     VARCHAR(20)
)

INSERT INTO #TEMP_ORDERS_23 (OrderId, OrderDate)
SELECT OrderID,
       OrderDate
  FROM Orders
 WHERE OrderDate < DATEADD(YEAR, -@Anos23, @RefDate23)

INSERT INTO #TEMP_OD_23 (OrderId, ProductId)
SELECT od.OrderID,
       od.ProductID
  FROM [Order Details] od
  JOIN #TEMP_ORDERS_23 o  ON o.OrderId = od.OrderID

DECLARE DeleteOrderCursor CURSOR FOR
  SELECT OrderId
    FROM #TEMP_ORDERS_23
ORDER BY OrderId

-- OPEN antes do TRY e CLOSE/DEALLOCATE depois do CATCH: o cursor e liberado mesmo se der erro
OPEN DeleteOrderCursor

BEGIN TRY
	BEGIN TRAN

	FETCH NEXT FROM DeleteOrderCursor INTO @OrderId23

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #TEMP_EXCLUIDOS_23 (OrderId, ProductId, Etapa)
		SELECT OrderId,
		       ProductId,
		       'Order Details'
		  FROM #TEMP_OD_23
		 WHERE OrderId = @OrderId23

		DELETE FROM #TEMP_OD_23
		 WHERE OrderId = @OrderId23

		INSERT INTO #TEMP_EXCLUIDOS_23 (OrderId, ProductId, Etapa)
		VALUES (@OrderId23, NULL, 'Orders')

		DELETE FROM #TEMP_ORDERS_23
		 WHERE OrderId = @OrderId23

		FETCH NEXT FROM DeleteOrderCursor INTO @OrderId23
	END

	COMMIT TRAN
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN

	PRINT 'ERRO: ' + ERROR_MESSAGE()
END CATCH

CLOSE DeleteOrderCursor
DEALLOCATE DeleteOrderCursor

SELECT * FROM #TEMP_EXCLUIDOS_23 ORDER BY OrderId, Etapa, ProductId
SELECT * FROM #TEMP_OD_23
SELECT * FROM #TEMP_ORDERS_23

DROP TABLE #TEMP_EXCLUIDOS_23
DROP TABLE #TEMP_OD_23
DROP TABLE #TEMP_ORDERS_23

------------------------------------------------------------------------------------------------------------------------------------------
-- 24
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @RefDate24    DATETIME = (SELECT MAX(OrderDate) FROM Orders),
        @CustomerId24 CHAR(5)

DROP TABLE IF EXISTS #TEMP_ARCHIVED_CUSTOMERS_24
CREATE TABLE #TEMP_ARCHIVED_CUSTOMERS_24
(
	CustomerId  CHAR(5),
	CompanyName VARCHAR(40),
	Country     VARCHAR(15),
	DataArquivo DATETIME
)

DECLARE ArchiveCustomerCursor CURSOR FOR
 SELECT c.CustomerID
   FROM Customers c
  WHERE NOT EXISTS (SELECT 1
                      FROM Orders o
                     WHERE o.CustomerID = c.CustomerID
                       AND o.OrderDate >= DATEADD(YEAR, -3, @RefDate24))

-- OPEN antes do TRY e CLOSE/DEALLOCATE depois do CATCH: o cursor e liberado mesmo se der erro
OPEN ArchiveCustomerCursor

BEGIN TRY
	BEGIN TRAN

	FETCH NEXT FROM ArchiveCustomerCursor INTO @CustomerId24

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #TEMP_ARCHIVED_CUSTOMERS_24 (CustomerId, CompanyName, Country, DataArquivo)
		SELECT CustomerID,
		       CompanyName,
		       Country,
		       GETDATE()
		  FROM Customers
		 WHERE CustomerID = @CustomerId24

		FETCH NEXT FROM ArchiveCustomerCursor INTO @CustomerId24
	END

	COMMIT TRAN
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN

	PRINT 'ERRO: ' + ERROR_MESSAGE()
END CATCH

CLOSE ArchiveCustomerCursor
DEALLOCATE ArchiveCustomerCursor

SELECT * FROM #TEMP_ARCHIVED_CUSTOMERS_24 ORDER BY CustomerId
DROP TABLE #TEMP_ARCHIVED_CUSTOMERS_24

------------------------------------------------------------------------------------------------------------------------------------------
-- 25
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @ProductId25 INT

DROP TABLE IF EXISTS #TEMP_STOCK_25
CREATE TABLE #TEMP_STOCK_25
(
	ProductId    INT,
	UnitsInStock SMALLINT
)

DROP TABLE IF EXISTS #TEMP_RESTOCK_LOG_25
CREATE TABLE #TEMP_RESTOCK_LOG_25
(
	ProductId           INT,
	QtyAnterior         SMALLINT,
	QtyNova             SMALLINT,
	DataReabastecimento DATETIME
)

INSERT INTO #TEMP_STOCK_25 (ProductId, UnitsInStock)
SELECT ProductID,
       UnitsInStock
  FROM Products
 WHERE UnitsInStock < 10

DECLARE RestockCursor CURSOR FOR
 SELECT ProductId
   FROM #TEMP_STOCK_25

-- OPEN antes do TRY e CLOSE/DEALLOCATE depois do CATCH: o cursor e liberado mesmo se der erro
OPEN RestockCursor

BEGIN TRY
	BEGIN TRAN

	FETCH NEXT FROM RestockCursor INTO @ProductId25

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #TEMP_RESTOCK_LOG_25 (ProductId, QtyAnterior, QtyNova, DataReabastecimento)
		SELECT ProductId,
		       UnitsInStock,
		       20,
		       GETDATE()
		  FROM #TEMP_STOCK_25
		 WHERE ProductId = @ProductId25

		UPDATE #TEMP_STOCK_25
		   SET UnitsInStock = 20
		 WHERE ProductId = @ProductId25

		FETCH NEXT FROM RestockCursor INTO @ProductId25
	END

	COMMIT TRAN
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN

	PRINT 'ERRO: ' + ERROR_MESSAGE()
END CATCH

CLOSE RestockCursor
DEALLOCATE RestockCursor

SELECT * FROM #TEMP_RESTOCK_LOG_25 ORDER BY ProductId
SELECT * FROM #TEMP_STOCK_25 ORDER BY ProductId

DROP TABLE #TEMP_RESTOCK_LOG_25
DROP TABLE #TEMP_STOCK_25

------------------------------------------------------------------------------------------------------------------------------------------
-- 26
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @Region26  VARCHAR(15),
        @OrderId26 INT,
        @Freight26 MONEY

DROP TABLE IF EXISTS #TEMP_FREIGHT_REGIAO_26
CREATE TABLE #TEMP_FREIGHT_REGIAO_26
(
	OrderId    INT,
	ShipRegion VARCHAR(15),
	OldFreight MONEY,
	NewFreight MONEY
)

BEGIN TRAN

DECLARE RegionCursor CURSOR FOR
 SELECT DISTINCT 
        ISNULL(ShipRegion, '(sem regiao)')
   FROM Orders
  ORDER BY 1

OPEN RegionCursor
FETCH NEXT FROM RegionCursor INTO @Region26

WHILE @@FETCH_STATUS = 0
BEGIN
	BEGIN TRY
		SAVE TRAN SaveRegion26

		DECLARE OrderRegionCursor CURSOR FOR
		 SELECT OrderID,
		        Freight
		   FROM Orders
		  WHERE ISNULL(ShipRegion, '(sem regiao)') = @Region26

		OPEN OrderRegionCursor
		FETCH NEXT FROM OrderRegionCursor INTO @OrderId26, @Freight26

		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO #TEMP_FREIGHT_REGIAO_26 (OrderId, ShipRegion, OldFreight, NewFreight)
			VALUES (@OrderId26, @Region26, @Freight26,
			        CASE WHEN @Region26 = '(sem regiao)' THEN @Freight26 * 1.05
			             ELSE @Freight26 * 1.15
			              END)

			FETCH NEXT FROM OrderRegionCursor INTO @OrderId26, @Freight26
		END

		-- Erro simulado na regiao SP: so aquele grupo e revertido. Fica DEPOIS dos INSERTs e com o cursor interno
		-- ainda aberto, para testar o ROLLBACK ao savepoint e a liberacao do cursor no CATCH
		IF @Region26 = 'SP'
			RAISERROR('Falha simulada na regiao SP', 16, 1)

		CLOSE OrderRegionCursor
		DEALLOCATE OrderRegionCursor
	END TRY
	BEGIN CATCH
		IF XACT_STATE() = 1
			ROLLBACK TRAN SaveRegion26

		-- Se o erro aconteceu com o cursor interno aberto, ele precisa ser liberado aqui;
		-- senao o DECLARE da proxima regiao falha com "Ja existe um cursor com o nome 'OrderRegionCursor'"
		IF CURSOR_STATUS('global', 'OrderRegionCursor') >= -1
			DEALLOCATE OrderRegionCursor

		PRINT 'Regiao ' + @Region26 + ' revertida: ' + ERROR_MESSAGE()
	END CATCH

	FETCH NEXT FROM RegionCursor INTO @Region26
END

CLOSE RegionCursor
DEALLOCATE RegionCursor

COMMIT TRAN

SELECT * FROM #TEMP_FREIGHT_REGIAO_26 ORDER BY ShipRegion, OrderId
DROP TABLE #TEMP_FREIGHT_REGIAO_26

------------------------------------------------------------------------------------------------------------------------------------------
-- 27
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @RefDate27   DATETIME = (SELECT MAX(OrderDate) FROM Orders),
        @ProductId27 INT

DROP TABLE IF EXISTS #TEMP_REATIVAR_27
CREATE TABLE #TEMP_REATIVAR_27
(
	ProductId       INT,
	ProductName     VARCHAR(40),
	OldDiscontinued BIT,
	NewDiscontinued BIT
)

DECLARE ReactivateCursor CURSOR FOR
 SELECT p.ProductID
   FROM Products p
  WHERE p.Discontinued = 1
    AND EXISTS (SELECT 1
                  FROM [Order Details] od
                  JOIN Orders          o  ON o.OrderID = od.OrderID
                 WHERE od.ProductID = p.ProductID
                   AND o.OrderDate >= DATEADD(YEAR, -2, @RefDate27))

-- OPEN antes do TRY e CLOSE/DEALLOCATE depois do CATCH: o cursor e liberado mesmo se der erro
OPEN ReactivateCursor

BEGIN TRY
	BEGIN TRAN

	FETCH NEXT FROM ReactivateCursor INTO @ProductId27

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #TEMP_REATIVAR_27 (ProductId, ProductName, OldDiscontinued, NewDiscontinued)
		SELECT ProductID,
		       ProductName,
		       Discontinued,
		       0
		  FROM Products
		 WHERE ProductID = @ProductId27

		FETCH NEXT FROM ReactivateCursor INTO @ProductId27
	END

	COMMIT TRAN
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN

	PRINT 'ERRO: ' + ERROR_MESSAGE()
END CATCH

CLOSE ReactivateCursor
DEALLOCATE ReactivateCursor

SELECT * FROM #TEMP_REATIVAR_27 ORDER BY ProductId
DROP TABLE #TEMP_REATIVAR_27

------------------------------------------------------------------------------------------------------------------------------------------
-- 28
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @OrderId28   INT = ( SELECT MIN(OrderID) FROM Orders ),
        @ProductId28 INT,
        @Quantity28  SMALLINT,
        @Stock28     SMALLINT

DROP TABLE IF EXISTS #TEMP_STOCK_28
CREATE TABLE #TEMP_STOCK_28
(
	ProductId    INT,
	UnitsInStock SMALLINT
)

DROP TABLE IF EXISTS #TEMP_STOCK_ADJ_28
CREATE TABLE #TEMP_STOCK_ADJ_28
(
	OrderId    INT,
	ProductId  INT,
	Quantity   SMALLINT,
	StockAntes SMALLINT,
	StockDepois SMALLINT
)

INSERT INTO #TEMP_STOCK_28 (ProductId, UnitsInStock)
SELECT DISTINCT
       p.ProductID,
       p.UnitsInStock
  FROM Products        p
  JOIN [Order Details] od ON od.ProductID = p.ProductID
 WHERE od.OrderID = @OrderId28

DECLARE StockOrderCursor CURSOR FOR
 SELECT ProductID,
        Quantity
   FROM [Order Details]
  WHERE OrderID = @OrderId28

-- OPEN antes do TRY e CLOSE/DEALLOCATE depois do CATCH: o cursor e liberado mesmo se der erro
OPEN StockOrderCursor

BEGIN TRY
	BEGIN TRAN

	FETCH NEXT FROM StockOrderCursor INTO @ProductId28, @Quantity28

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @Stock28 = UnitsInStock
		  FROM #TEMP_STOCK_28
		 WHERE ProductId = @ProductId28

		-- Estoque negativo gera erro e desfaz o pedido inteiro
		IF @Stock28 < @Quantity28
			RAISERROR('Estoque insuficiente para o produto %d', 16, 1, @ProductId28)

		INSERT INTO #TEMP_STOCK_ADJ_28 (OrderId, ProductId, Quantity, StockAntes, StockDepois)
		VALUES (@OrderId28, @ProductId28, @Quantity28, @Stock28, @Stock28 - @Quantity28)

		UPDATE #TEMP_STOCK_28
		   SET UnitsInStock = UnitsInStock - @Quantity28
		 WHERE ProductId = @ProductId28

		FETCH NEXT FROM StockOrderCursor INTO @ProductId28, @Quantity28
	END

	COMMIT TRAN
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN

	PRINT 'ERRO: ' + ERROR_MESSAGE()
END CATCH

CLOSE StockOrderCursor
DEALLOCATE StockOrderCursor

SELECT @OrderId28 AS OrderId
SELECT * FROM #TEMP_STOCK_ADJ_28 ORDER BY ProductId
SELECT * FROM #TEMP_STOCK_28 ORDER BY ProductId

DROP TABLE #TEMP_STOCK_ADJ_28
DROP TABLE #TEMP_STOCK_28

------------------------------------------------------------------------------------------------------------------------------------------
-- 29
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @CategoryId29 INT,
        @Receita29    MONEY

DROP TABLE IF EXISTS #TEMP_CATEGORY_REVENUE_29
CREATE TABLE #TEMP_CATEGORY_REVENUE_29
(
	CategoryId   INT,
	CategoryName VARCHAR(15),
	Receita      MONEY
)

BEGIN TRAN

DECLARE CategoryRevenueCursor CURSOR FOR
  SELECT CategoryID
    FROM Categories
ORDER BY CategoryID

OPEN CategoryRevenueCursor
FETCH NEXT FROM CategoryRevenueCursor INTO @CategoryId29

WHILE @@FETCH_STATUS = 0
BEGIN
	BEGIN TRY
		SAVE TRAN SaveRev29

		SELECT @Receita29 = ISNULL(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 0)
		  FROM [Order Details] od
		  JOIN Products        p  ON p.ProductID = od.ProductID
		 WHERE p.CategoryID = @CategoryId29

		INSERT INTO #TEMP_CATEGORY_REVENUE_29 (CategoryId, CategoryName, Receita)
		SELECT CategoryID,
		       CategoryName,
		       @Receita29
		  FROM Categories
		 WHERE CategoryID = @CategoryId29

		-- Cada categoria e confirmada no proprio savepoint. Falha simulada propositalmente na categoria 8,
		-- DEPOIS do INSERT: a receita da categoria 8 ja foi gravada e o ROLLBACK ao savepoint precisa desfaze-la
		IF @CategoryId29 = 8
			RAISERROR('Falha simulada na categoria 8', 16, 1)
	END TRY
	BEGIN CATCH
		IF XACT_STATE() = 1
			ROLLBACK TRAN SaveRev29

		PRINT 'Categoria ' + CAST(@CategoryId29 AS VARCHAR(10)) + ' revertida: ' + ERROR_MESSAGE()
	END CATCH

	FETCH NEXT FROM CategoryRevenueCursor INTO @CategoryId29
END

CLOSE CategoryRevenueCursor
DEALLOCATE CategoryRevenueCursor

COMMIT TRAN

SELECT * FROM #TEMP_CATEGORY_REVENUE_29 ORDER BY CategoryId
DROP TABLE #TEMP_CATEGORY_REVENUE_29

------------------------------------------------------------------------------------------------------------------------------------------
-- 30
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @Anos30    INT = 10,
        @RefDate30 DATETIME = (SELECT MAX(OrderDate) FROM Orders),
        @OrderId30 INT

DROP TABLE IF EXISTS #TEMP_ORDERS_30
CREATE TABLE #TEMP_ORDERS_30
(
	OrderId    INT,
	CustomerId CHAR(5),
	OrderDate  DATETIME
)

DROP TABLE IF EXISTS #TEMP_OD_30
CREATE TABLE #TEMP_OD_30
(
	OrderId   INT,
	ProductId INT,
	UnitPrice MONEY,
	Quantity  SMALLINT,
	Discount  REAL
)

DROP TABLE IF EXISTS #TEMP_ARCHIVED_ORDERS_30
CREATE TABLE #TEMP_ARCHIVED_ORDERS_30
(
	OrderId    INT,
	CustomerId CHAR(5),
	OrderDate  DATETIME
)

DROP TABLE IF EXISTS #TEMP_ARCHIVED_OD_30
CREATE TABLE #TEMP_ARCHIVED_OD_30
(
	OrderId   INT,
	ProductId INT,
	UnitPrice MONEY,
	Quantity  SMALLINT,
	Discount  REAL
)

INSERT INTO #TEMP_ORDERS_30 (OrderId, CustomerId, OrderDate)
SELECT OrderID,
       CustomerID,
       OrderDate
  FROM Orders
 WHERE OrderDate < DATEADD(YEAR, -@Anos30, @RefDate30)

INSERT INTO #TEMP_OD_30 (OrderId, ProductId, UnitPrice, Quantity, Discount)
SELECT od.OrderID,
       od.ProductID,
       od.UnitPrice,
       od.Quantity,
       od.Discount
  FROM [Order Details] od
  JOIN #TEMP_ORDERS_30 o ON o.OrderId = od.OrderID

DECLARE ArchiveOrderCursor CURSOR LOCAL FAST_FORWARD FOR
  SELECT OrderId
    FROM #TEMP_ORDERS_30
ORDER BY OrderId

-- OPEN antes do TRY e CLOSE/DEALLOCATE depois do CATCH: o cursor e liberado mesmo se der erro
OPEN ArchiveOrderCursor

BEGIN TRY
	BEGIN TRAN

	FETCH NEXT FROM ArchiveOrderCursor INTO @OrderId30

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #TEMP_ARCHIVED_OD_30 (OrderId, ProductId, UnitPrice, Quantity, Discount)
		SELECT OrderId,
		       ProductId,
		       UnitPrice,
		       Quantity,
		       Discount
		  FROM #TEMP_OD_30
		 WHERE OrderId = @OrderId30

		DELETE FROM #TEMP_OD_30
		 WHERE OrderId = @OrderId30

		INSERT INTO #TEMP_ARCHIVED_ORDERS_30 (OrderId, CustomerId, OrderDate)
		SELECT OrderId,
		       CustomerId,
		       OrderDate
		  FROM #TEMP_ORDERS_30
		 WHERE OrderId = @OrderId30

		DELETE FROM #TEMP_ORDERS_30
		 WHERE OrderId = @OrderId30

		FETCH NEXT FROM ArchiveOrderCursor INTO @OrderId30
	END

	COMMIT TRAN
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN

	PRINT 'ERRO: ' + ERROR_MESSAGE()
END CATCH

CLOSE ArchiveOrderCursor
DEALLOCATE ArchiveOrderCursor

SELECT * FROM #TEMP_ARCHIVED_ORDERS_30 ORDER BY OrderId
SELECT * FROM #TEMP_ARCHIVED_OD_30 ORDER BY OrderId, ProductId
SELECT * FROM #TEMP_ORDERS_30
SELECT * FROM #TEMP_OD_30

DROP TABLE #TEMP_ARCHIVED_OD_30
DROP TABLE #TEMP_ARCHIVED_ORDERS_30
DROP TABLE #TEMP_OD_30
DROP TABLE #TEMP_ORDERS_30