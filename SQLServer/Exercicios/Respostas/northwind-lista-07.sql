
USE NORTHWIND
GO

------------------------------------------------------------------------------------------------------------------------------------------
-- 01
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @OrderId01 INT,
        @Freight01 MONEY

DROP TABLE IF EXISTS #TEMP_01
CREATE TABLE #TEMP_01
(
	OrderId    INT,
	OldFreight MONEY,
	NewFreight MONEY,
	[Date]     DATETIME
)

-- O filtro é pelo valor total do PEDIDO (itens de Order Details) acima de 500, e não pelo valor do frete
DECLARE UpdateFreightCursor CURSOR FOR
  SELECT o.OrderID,
         o.Freight
    FROM Orders          o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY o.OrderID, o.Freight
  HAVING SUM(od.UnitPrice * od.Quantity) > 500

OPEN UpdateFreightCursor
FETCH NEXT FROM UpdateFreightCursor INTO @OrderId01, @Freight01

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #TEMP_01 (OrderId, OldFreight, NewFreight, [Date])
	VALUES (@OrderId01, @Freight01, @Freight01 * 1.10, GETDATE())

	FETCH NEXT FROM UpdateFreightCursor INTO @OrderId01, @Freight01
END

CLOSE UpdateFreightCursor
DEALLOCATE UpdateFreightCursor

SELECT * FROM #TEMP_01
DROP TABLE #TEMP_01

------------------------------------------------------------------------------------------------------------------------------------------
-- 02
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @CustomerId02 VARCHAR(5),
        @Quantity02   INT,
		@TotalSpent02 FLOAT

DROP TABLE IF EXISTS #TEMP_02
CREATE TABLE #TEMP_02
(
	CustomerID VARCHAR(5),
	Quantity   INT,
	TotalSpent VARCHAR(20)
)

-- COUNT(DISTINCT): depois do JOIN com Order Details há uma linha por item, não por pedido
DECLARE CustomerCursor CURSOR FOR
  SELECT o.CustomerID,
         COUNT(DISTINCT o.OrderID),
		 SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))
    FROM Orders o
    JOIN [Order Details] od ON o.OrderID = od.OrderID
   WHERE YEAR(o.OrderDate) = 1998
GROUP BY o.CustomerID
  HAVING COUNT(DISTINCT o.OrderID) > 5

OPEN CustomerCursor
FETCH NEXT FROM CustomerCursor INTO @CustomerId02, @Quantity02, @TotalSpent02

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #TEMP_02
	VALUES (@CustomerId02, @Quantity02, FORMAT(@TotalSpent02, 'N2'))

	FETCH NEXT FROM CustomerCursor INTO @CustomerId02, @Quantity02, @TotalSpent02
END

CLOSE CustomerCursor
DEALLOCATE CustomerCursor

SELECT * FROM #TEMP_02
DROP TABLE #TEMP_02

------------------------------------------------------------------------------------------------------------------------------------------
-- 03
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @ProductName03   VARCHAR(100),
        @OriginalValue03 FLOAT,
		@ReducedValue03  FLOAT

DROP TABLE IF EXISTS #TEMP_03
CREATE TABLE #TEMP_03
(
	ProductName   VARCHAR(100),
	OriginalValue FLOAT,
	ReducedValue  FLOAT
)

DECLARE UpdatePriceCursor CURSOR FOR
SELECT ProductName,
       UnitPrice                        AS OriginalValue,
       ROUND(UnitPrice * (1 - 0.05), 2) AS ReducedValue
  FROM Products
 WHERE UnitsInStock > 100

OPEN UpdatePriceCursor
FETCH NEXT FROM UpdatePriceCursor INTO @ProductName03, @OriginalValue03, @ReducedValue03

WHILE @@FETCH_STATUS = 0
BEGIN
	BEGIN TRY
		IF @ReducedValue03 < 0
			THROW 50001, 'Valor não pode ser negativo!', 1

		INSERT INTO #TEMP_03
		VALUES (@ProductName03, @OriginalValue03, @ReducedValue03)
	END TRY
	BEGIN CATCH
		PRINT 'Erro ao atualizar o produto ' + @ProductName03 + ': ' + ERROR_MESSAGE()
	END CATCH

	-- O FETCH fica fora do TRY: se ficasse dentro, um erro pularia a leitura da próxima linha e o loop não terminaria
	FETCH NEXT FROM UpdatePriceCursor INTO @ProductName03, @OriginalValue03, @ReducedValue03
END

CLOSE UpdatePriceCursor
DEALLOCATE UpdatePriceCursor

SELECT * FROM #TEMP_03
DROP TABLE #TEMP_03

------------------------------------------------------------------------------------------------------------------------------------------
-- 04
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @OrderId04    INT,
        @TotalItens04 INT

DROP TABLE IF EXISTS #TEMP_04
CREATE TABLE #TEMP_04
(
	OrderId    INT,
    TotalItens INT
)

DECLARE TotalItensCursor CURSOR FOR
  SELECT OrderID,
         SUM(Quantity) AS TotalItens
    FROM [Order Details]
GROUP BY OrderID

OPEN TotalItensCursor
FETCH NEXT FROM TotalItensCursor INTO @OrderId04, @TotalItens04

WHILE @@FETCH_STATUS = 0
BEGIN
	BEGIN TRY
		IF (@TotalItens04 < 0 OR @TotalItens04 IS NULL)
			THROW 50001, 'O valor total não pode ser menor que zero, ou nulo!', 1

		INSERT INTO #TEMP_04
		VALUES (@OrderId04, @TotalItens04)
	END TRY
	BEGIN CATCH
		PRINT 'Erro no pedido ' + CAST(@OrderId04 AS VARCHAR) + ': ' + ERROR_MESSAGE()
	END CATCH

	-- FETCH fora do TRY, para o loop avançar mesmo quando há erro
	FETCH NEXT FROM TotalItensCursor INTO @OrderId04, @TotalItens04
END

CLOSE TotalItensCursor
DEALLOCATE TotalItensCursor

SELECT * FROM #TEMP_04
DROP TABLE #TEMP_04

------------------------------------------------------------------------------------------------------------------------------------------
-- 05
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @EmployeeId05 INT,
        @Quantity05   INT

DROP TABLE IF EXISTS #TEMP_05
CREATE TABLE #TEMP_05
(
	EmployeeId INT,
    Quantity   INT
)

-- Total de pedidos por funcionário no trimestre: o agrupamento é só por EmployeeID
DROP TABLE IF EXISTS #TEMP_CTE
;WITH QuantityCTE AS (
  SELECT EmployeeID,
         COUNT(*) AS Quantity
    FROM Orders
   WHERE YEAR(OrderDate) = 1997
     AND DATEPART(QUARTER, OrderDate) = 4
GROUP BY EmployeeID
)
SELECT EmployeeID,
       Quantity
  INTO #TEMP_CTE
  FROM QuantityCTE

DECLARE TotalSalesCursor CURSOR FOR
  SELECT EmployeeID,
         Quantity
    FROM #TEMP_CTE
ORDER BY Quantity DESC

OPEN TotalSalesCursor
FETCH NEXT FROM TotalSalesCursor INTO @EmployeeId05, @Quantity05

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #TEMP_05
	VALUES (@EmployeeId05, @Quantity05)

	FETCH NEXT FROM TotalSalesCursor INTO @EmployeeId05, @Quantity05
END

CLOSE TotalSalesCursor
DEALLOCATE TotalSalesCursor

-- Ordenado por desempenho
SELECT * FROM #TEMP_05 ORDER BY Quantity DESC
DROP TABLE #TEMP_CTE
DROP TABLE #TEMP_05

------------------------------------------------------------------------------------------------------------------------------------------
-- 06
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @SupplierId06 INT,
        @Phone06      VARCHAR(30),
        @Digits06     VARCHAR(30),
        @NewPhone06   VARCHAR(30)

DROP TABLE IF EXISTS #TEMP_06
CREATE TABLE #TEMP_06
(
	SupplierId INT,
	OldPhone   VARCHAR(30),
	NewPhone   VARCHAR(30)
)

DECLARE Cursor06 CURSOR FOR
SELECT SupplierID,
       Phone
  FROM Suppliers

OPEN Cursor06
FETCH NEXT FROM Cursor06 INTO @SupplierId06, @Phone06

WHILE @@FETCH_STATUS = 0
BEGIN
	BEGIN TRY
		-- Mantém só os dígitos: remove espaços, parênteses, hífens e pontos
		SET @Digits06 = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@Phone06, ' ', ''), '(', ''), ')', ''), '-', ''), '.', '')

		-- Telefone inválido: nulo, com caractere que não é dígito ou com menos de 8 dígitos
		IF (@Digits06 IS NULL OR @Digits06 LIKE '%[^0-9]%' OR LEN(@Digits06) < 8)
			THROW 50001, 'Telefone inválido para o formato padronizado', 1

		-- Formato padronizado +XX-XXXX-XXXX: os 4 últimos dígitos formam o último bloco
		SET @NewPhone06 = '+55-' + LEFT(@Digits06, LEN(@Digits06) - 4) + '-' + RIGHT(@Digits06, 4)

		INSERT INTO #TEMP_06
		VALUES (@SupplierId06, @Phone06, @NewPhone06)
	END TRY
	BEGIN CATCH
		PRINT 'Erro ao inserir o fornecedor ' + CAST(@SupplierId06 AS VARCHAR) + ': ' + ERROR_MESSAGE()
	END CATCH

	FETCH NEXT FROM Cursor06 INTO @SupplierId06, @Phone06
END

CLOSE Cursor06
DEALLOCATE Cursor06

SELECT * FROM #TEMP_06
DROP TABLE #TEMP_06

------------------------------------------------------------------------------------------------------------------------------------------
-- 07
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @OrderId07   INT,
        @ProductId07 INT,
		@UnitPrice07 MONEY

DROP TABLE IF EXISTS #TEMP_07
CREATE TABLE #TEMP_07
(
	OrderID      INT,
	ProductID    INT,
	OldUnitPrice MONEY,
	NewUnitPrice MONEY
)

DECLARE Cursor07 CURSOR FOR
SELECT OrderID,
       ProductID,
	   UnitPrice
  FROM [Order Details]
 WHERE Quantity > 10

OPEN Cursor07
FETCH NEXT FROM Cursor07 INTO @OrderId07, @ProductId07, @UnitPrice07

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #TEMP_07
	VALUES (@OrderId07, @ProductId07, @UnitPrice07, @UnitPrice07 * 0.85)

	FETCH NEXT FROM Cursor07 INTO @OrderId07, @ProductId07, @UnitPrice07
END

CLOSE Cursor07
DEALLOCATE Cursor07

SELECT * FROM #TEMP_07
DROP TABLE #TEMP_07

------------------------------------------------------------------------------------------------------------------------------------------
-- 08
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @OrderId08 INT

DROP TABLE IF EXISTS #TEMP_08
CREATE TABLE #TEMP_08
(
	OrderId     INT,
	CustomerId  VARCHAR(5),
	OrderDate   DATE,
	ShippedDate DATE,
	[Status]    VARCHAR(20) DEFAULT 'Ativo'
)

-- Só entram pedidos AINDA não enviados e feitos há mais de 30 dias. Pedido já enviado não é cancelado
DECLARE Cursor08 CURSOR FOR
SELECT OrderID
  FROM Orders
 WHERE ShippedDate IS NULL
   AND OrderDate < DATEADD(DAY, -30, GETDATE())

OPEN Cursor08
FETCH NEXT FROM Cursor08 INTO @OrderId08

WHILE @@FETCH_STATUS = 0
BEGIN
	BEGIN TRY
		IF (@OrderId08 IS NULL)
			THROW 50001, 'Não é possível inserir um registro com OrderId nulo!', 1

		INSERT INTO #TEMP_08 (OrderId, CustomerId, OrderDate, ShippedDate, [Status])
		SELECT OrderID,
		       CustomerID,
			   CAST(OrderDate AS DATE)   AS OrderDate,
			   CAST(ShippedDate AS DATE) AS ShippedDate,
			   'Cancelado'
		  FROM Orders
		 WHERE OrderID = @OrderId08
	END TRY
	BEGIN CATCH
		PRINT 'Erro ao inserir o OrderId ' + CAST(@OrderId08 AS VARCHAR) + ': ' + ERROR_MESSAGE()
	END CATCH

	-- FETCH fora do TRY, para o loop avançar mesmo quando há erro
	FETCH NEXT FROM Cursor08 INTO @OrderId08
END

CLOSE Cursor08
DEALLOCATE Cursor08

SELECT * FROM #TEMP_08
DROP TABLE #TEMP_08

------------------------------------------------------------------------------------------------------------------------------------------
-- 09
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @ProductId09 INT

DROP TABLE IF EXISTS #TEMP_09
CREATE TABLE #TEMP_09
(
	ProductId    INT,
	ProductName  VARCHAR(100),
	SupplierName VARCHAR(100),
	UnitPrice    MONEY
)

DECLARE Cursor09 CURSOR FOR
SELECT ProductID 
  FROM Products 
 WHERE Discontinued = 1

OPEN Cursor09
FETCH NEXT FROM Cursor09 INTO @ProductId09

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #TEMP_09 (ProductId, ProductName, SupplierName, UnitPrice)
	SELECT p.ProductID,
	       p.ProductName,
		   s.CompanyName,
		   p.UnitPrice
	  FROM Products  p
	  JOIN Suppliers s ON s.SupplierID = p.SupplierID
	 WHERE p.ProductID = @ProductId09

	FETCH NEXT FROM Cursor09 INTO @ProductId09
END

CLOSE Cursor09
DEALLOCATE Cursor09

SELECT * FROM #TEMP_09
DROP TABLE #TEMP_09

------------------------------------------------------------------------------------------------------------------------------------------
-- 10
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @CustomerId10 VARCHAR(5),
        @OrderDate10  DATETIME

DROP TABLE IF EXISTS #TEMP_10
CREATE TABLE #TEMP_10
(
	CustomerId VARCHAR(5),
	OrderDate  DATETIME,
	EmailDate  DATETIME
)

DECLARE Cursor10 CURSOR FOR
   SELECT c.CustomerID, 
          MAX(o.OrderDate)
     FROM Customers c
LEFT JOIN Orders    o ON c.CustomerID = o.CustomerID
 GROUP BY c.CustomerID
   HAVING MAX(o.OrderDate) < DATEADD(MONTH, -6, GETDATE()) OR MAX(o.OrderDate) IS NULL

OPEN Cursor10
FETCH NEXT FROM Cursor10 INTO @CustomerId10, @OrderDate10

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #TEMP_10 (CustomerId, OrderDate, EmailDate)
	VALUES (@CustomerId10, @OrderDate10, GETDATE())

	FETCH NEXT FROM Cursor10 INTO @CustomerId10, @OrderDate10
END

CLOSE Cursor10
DEALLOCATE Cursor10

SELECT * FROM #TEMP_10
DROP TABLE #TEMP_10

------------------------------------------------------------------------------------------------------------------------------------------
-- 11
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @OrderId11 INT,
        @Total11   DECIMAL(10,2)

DROP TABLE IF EXISTS #TEMP_11
CREATE TABLE #TEMP_11
(
	OrderId    INT,
	TotalValue MONEY
)

DECLARE Cursor11 CURSOR FOR
  SELECT o.OrderID,
         ROUND(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 2)
    FROM Orders          o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY o.OrderID

OPEN Cursor11
FETCH NEXT FROM Cursor11 INTO @OrderId11, @Total11

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #TEMP_11
	VALUES (@OrderId11, @Total11)

	FETCH NEXT FROM Cursor11 INTO @OrderId11, @Total11
END

CLOSE Cursor11
DEALLOCATE Cursor11

SELECT * FROM #TEMP_11
DROP TABLE #TEMP_11

------------------------------------------------------------------------------------------------------------------------------------------
-- 12
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @EmployeeId12 INT, 
        @ReportsTo12  INT, 
		@FirstName12  VARCHAR(10), 
		@LastName12   VARCHAR(20)

DROP TABLE IF EXISTS #TEMP_12
CREATE TABLE #TEMP_12 
(
    EmployeeID INT,
    ManagerID INT,
    EmployeeName NVARCHAR(50)
)

DECLARE Cursor12 CURSOR FOR
SELECT EmployeeID, 
       ReportsTo, 
	   FirstName, 
	   LastName
  FROM Employees

OPEN Cursor12
FETCH NEXT FROM Cursor12 INTO @EmployeeId12, @ReportsTo12, @FirstName12, @LastName12

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_12 (EmployeeID, ManagerID, EmployeeName)
    VALUES (@EmployeeId12, @ReportsTo12, @FirstName12 + ' ' + @LastName12)

    FETCH NEXT FROM Cursor12 INTO @EmployeeId12, @ReportsTo12, @FirstName12, @LastName12
END

CLOSE Cursor12
DEALLOCATE Cursor12

SELECT * FROM #TEMP_12
DROP TABLE #TEMP_12

------------------------------------------------------------------------------------------------------------------------------------------
-- 13
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @OrderId13      INT,
        @ProductId13    INT,
		@UnitPrice13    DECIMAL(10,2),
		@AvgUnitPrice13 DECIMAL(10,2)

DROP TABLE IF EXISTS #TEMP_13
CREATE TABLE #TEMP_13
(
	OrderID      INT,
	ProductID    INT,
	UnitPrice    DECIMAL(10,2),
	AvgUnitPrice DECIMAL(10,2)
)

-- A média exibida é a mesma usada no filtro: preço médio da categoria, calculado em Products
DECLARE Cursor13 CURSOR FOR
SELECT od.OrderID,
       od.ProductID,
	   od.UnitPrice,
       ca.AvgPrice
  FROM [Order Details] od
  JOIN Products        p  ON od.ProductID = p.ProductID
  JOIN (   SELECT CategoryID,
                  AVG(UnitPrice) AS AvgPrice
             FROM Products
         GROUP BY CategoryID ) ca ON ca.CategoryID = p.CategoryID
 WHERE od.UnitPrice > ca.AvgPrice

OPEN Cursor13
FETCH NEXT FROM Cursor13 INTO @OrderId13, @ProductId13, @UnitPrice13, @AvgUnitPrice13

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #TEMP_13
	VALUES (@OrderId13, @ProductId13, @UnitPrice13, @AvgUnitPrice13)

	FETCH NEXT FROM Cursor13 INTO @OrderId13, @ProductId13, @UnitPrice13, @AvgUnitPrice13
END

CLOSE Cursor13
DEALLOCATE Cursor13

SELECT * FROM #TEMP_13
DROP TABLE #TEMP_13

------------------------------------------------------------------------------------------------------------------------------------------
-- 14
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @CustomerId14 VARCHAR(5),
        @TotalOrder14 DECIMAL(10,2),
		@AvgFreight14 DECIMAL(10,2)

DROP TABLE IF EXISTS #TEMP_14
CREATE TABLE #TEMP_14
(
	CustomerId VARCHAR(5),
	TotalOrder DECIMAL(10,2),
	AvgFreight DECIMAL(10,2)
)

DECLARE Cursor14 CURSOR FOR
  SELECT CustomerID,
         COUNT(OrderId)         AS TotalOrder,
  	     ROUND(AVG(Freight), 2) AS AvgFreight
    FROM Orders
GROUP BY CustomerID

OPEN Cursor14
FETCH NEXT FROM Cursor14 INTO @CustomerId14, @TotalOrder14, @AvgFreight14

WHILE @@FETCH_STATUS = 0
BEGIN
	BEGIN TRY
		INSERT INTO #TEMP_14
		VALUES (@CustomerId14, @TotalOrder14, @AvgFreight14)
	END TRY
	BEGIN CATCH
		PRINT 'Erro ao inserir o cliente ' + @CustomerId14 + '! ' + ERROR_MESSAGE()
	END CATCH

	FETCH NEXT FROM Cursor14 INTO @CustomerId14, @TotalOrder14, @AvgFreight14
END

CLOSE Cursor14
DEALLOCATE Cursor14

SELECT * FROM #TEMP_14
DROP TABLE #TEMP_14

------------------------------------------------------------------------------------------------------------------------------------------
-- 15
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @ProductId15 INT

DROP TABLE IF EXISTS #TEMP_15
CREATE TABLE #TEMP_15
(
	ProductId INT,
	OldUnitStock SMALLINT,
	NewUnitStock SMALLINT
)

DECLARE Cursor15 CURSOR FOR
SELECT DISTINCT
       ProductID
  FROM Products

OPEN Cursor15
FETCH NEXT FROM Cursor15 INTO @ProductId15

WHILE @@FETCH_STATUS = 0
BEGIN
	-- CEILING: sem arredondar para cima, a conversão para SMALLINT trunca e estoques pequenos não aumentam (4 * 1.2 = 4.8 viraria 4)
	INSERT INTO #TEMP_15
	SELECT ProductID,
	       UnitsInStock,
		   CEILING(UnitsInStock * 1.2)
	  FROM Products
	 WHERE ProductID = @ProductId15
	   AND UnitsInStock > 0
	   AND UnitsInStock < 10

	FETCH NEXT FROM Cursor15 INTO @ProductId15
END

CLOSE Cursor15
DEALLOCATE Cursor15

SELECT * FROM #TEMP_15
DROP TABLE #TEMP_15

------------------------------------------------------------------------------------------------------------------------------------------
-- 16
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @CustomerId16 VARCHAR(5),
        @Quantity16   SMALLINT,
		@Ranking16    TINYINT

DROP TABLE IF EXISTS #TEMP_16
CREATE TABLE #TEMP_16
(
	CustomerID VARCHAR(5),
	Quantity   SMALLINT,
	Ranking    TINYINT
)

-- TOP só garante "os 10 maiores" quando a consulta tem ORDER BY
DECLARE Cursor16 CURSOR FOR
  SELECT TOP 10
         CustomerID,
         COUNT(OrderID) AS Quantity,
  	     ROW_NUMBER() OVER (ORDER BY COUNT(OrderID) DESC) AS Ranking
    FROM Orders
GROUP BY CustomerID
ORDER BY Ranking

OPEN Cursor16
FETCH NEXT FROM Cursor16 INTO @CustomerId16, @Quantity16, @Ranking16

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #TEMP_16
	VALUES (@CustomerId16, @Quantity16, @Ranking16)

	FETCH NEXT FROM Cursor16 INTO @CustomerId16, @Quantity16, @Ranking16
END

CLOSE Cursor16
DEALLOCATE Cursor16

SELECT * FROM #TEMP_16
DROP TABLE #TEMP_16

------------------------------------------------------------------------------------------------------------------------------------------
-- 17
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @OrderId17    INT,
        @CustomerId17 VARCHAR(5),
		@Total17      SMALLINT

DROP TABLE IF EXISTS #TEMP_17
CREATE TABLE #TEMP_17
(
	OrderId    INT,
	CustomerId VARCHAR(5),
	Total      SMALLINT,
	[Status]   VARCHAR(20)
)

DECLARE Cursor17 CURSOR FOR
  SELECT od.OrderID,
         o.CustomerID,
         SUM(od.Quantity) AS TotalQuantity
    FROM [Order Details] od
    JOIN Orders          o  ON o.OrderID = od.OrderID
GROUP BY od.OrderID, o.CustomerID
  HAVING SUM(Quantity) > 50

OPEN Cursor17
FETCH NEXT FROM Cursor17 INTO @OrderId17, @CustomerId17, @Total17

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #TEMP_17
	VALUES (@OrderId17, @CustomerId17, @Total17, 'Prioritário')

	FETCH NEXT FROM Cursor17 INTO @OrderId17, @CustomerId17, @Total17
END

CLOSE Cursor17
DEALLOCATE Cursor17

SELECT * FROM #TEMP_17
DROP TABLE #TEMP_17

------------------------------------------------------------------------------------------------------------------------------------------
-- 18
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @SupplierId18 INT,
        @TotalValue18 DECIMAL(10,2)

DROP TABLE IF EXISTS #TEMP_18
CREATE TABLE #TEMP_18
(
	SupplierId INT,
	TotalValue DECIMAL(10,2)
)

DECLARE Cursor18 CURSOR FOR
  SELECT SupplierID,
         SUM(UnitPrice * UnitsInStock) AS Total
    FROM Products
GROUP BY SupplierID

OPEN Cursor18
FETCH NEXT FROM Cursor18 INTO @SupplierId18, @TotalValue18

WHILE @@FETCH_STATUS = 0
BEGIN
	BEGIN TRY
		INSERT INTO #TEMP_18
		VALUES (@SupplierId18, COALESCE(@TotalValue18, 0))
	END TRY
	BEGIN CATCH
		PRINT 'Erro ao calcular o valor para o fornecedor ' + CAST(@SupplierId18 AS VARCHAR) + '! ' + ERROR_MESSAGE()
	END CATCH

	FETCH NEXT FROM Cursor18 INTO @SupplierId18, @TotalValue18
END

CLOSE Cursor18
DEALLOCATE Cursor18

SELECT * FROM #TEMP_18
DROP TABLE #TEMP_18

------------------------------------------------------------------------------------------------------------------------------------------
-- 19
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @OrderId19      INT,
        @CustomerId19   VARCHAR(5),
		@ProductId19    SMALLINT,
        @OldUnitPrice19 DECIMAL(10,2),
		@NewUnitPrice19 DECIMAL(10,2)

DROP TABLE IF EXISTS #TEMP_19
CREATE TABLE #TEMP_19
(
	OrderId      INT,
	CustomerId   VARCHAR(5),
	ProductId    SMALLINT,
	OldUnitPrice DECIMAL(10,2),
	NewUnitPrice DECIMAL(10,2)
)

DECLARE Cursor19 CURSOR FOR
SELECT o.OrderID,
       o.CustomerID,
	   od.ProductID,
       od.UnitPrice                    AS OldUnitPrice,
	   ROUND((od.UnitPrice * 1.05), 2) AS NewUnitPrice
  FROM [Order Details] od
  JOIN Orders          o  ON o.OrderID = od.OrderID
 WHERE DAY(o.OrderDate) = 25
   AND MONTH(o.OrderDate) = 12

OPEN Cursor19
FETCH NEXT FROM Cursor19 INTO @OrderId19, @CustomerId19, @ProductId19, @OldUnitPrice19, @NewUnitPrice19

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #TEMP_19
	VALUES (@OrderId19, @CustomerId19, @ProductId19, @OldUnitPrice19, @NewUnitPrice19)

	FETCH NEXT FROM Cursor19 INTO @OrderId19, @CustomerId19, @ProductId19, @OldUnitPrice19, @NewUnitPrice19
END

CLOSE Cursor19
DEALLOCATE Cursor19

SELECT * FROM #TEMP_19
DROP TABLE #TEMP_19

------------------------------------------------------------------------------------------------------------------------------------------
-- 20
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @EmployeeId20 INT,
        @TotalYears20 SMALLINT

DROP TABLE IF EXISTS #TEMP_20
CREATE TABLE #TEMP_20
(
	EmployeeId INT,
	TotalYears SMALLINT
)

-- DATEDIFF(YEAR) conta viradas de ano; o CASE desconta 1 quando o aniversário de contratação ainda não chegou neste ano
DECLARE Cursor20 CURSOR FOR
SELECT EmployeeID,
       DATEDIFF(YEAR, HireDate, GETDATE())
	       - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, HireDate, GETDATE()), HireDate) > GETDATE() THEN 1 ELSE 0 END
  FROM Employees

OPEN Cursor20
FETCH NEXT FROM Cursor20 INTO @EmployeeId20, @TotalYears20

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #TEMP_20
	VALUES (@EmployeeId20, @TotalYears20)

	FETCH NEXT FROM Cursor20 INTO @EmployeeId20, @TotalYears20
END

CLOSE Cursor20
DEALLOCATE Cursor20

SELECT * FROM #TEMP_20
DROP TABLE #TEMP_20

------------------------------------------------------------------------------------------------------------------------------------------
-- 21
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CTE21 AS
(
	  SELECT c.CategoryName,
	         SUM(od.Quantity * od.UnitPrice) AS Total,
	  	     YEAR(o.OrderDate) AS [Year]
	    FROM Orders          o
	    JOIN [Order Details] od ON od.OrderID = o.OrderID
	    JOIN Products        p  ON p.ProductID = od.ProductID
	    JOIN Categories      c  ON c.CategoryID = p.CategoryID
	GROUP BY c.CategoryName, YEAR(o.OrderDate)
)
  SELECT CategoryName,
         Total
    FROM CTE21
   WHERE [Year] = 1997
ORDER BY Total DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 22
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CTE22 AS (
    SELECT EmployeeID,
           FirstName + ' ' + LastName AS EmployeeName,
           ReportsTo,
           1                          AS [Level]
      FROM Employees
     WHERE ReportsTo IS NULL

    UNION ALL

    SELECT e.EmployeeID,
           e.FirstName + ' ' + e.LastName,
           e.ReportsTo,
           eh.[Level] + 1
      FROM Employees e
      JOIN CTE22     eh ON e.ReportsTo = eh.EmployeeID
)
  SELECT EmployeeID,
         EmployeeName,
         ReportsTo     AS ManagerID,
         [Level]
    FROM CTE22
ORDER BY [Level], EmployeeID

------------------------------------------------------------------------------------------------------------------------------------------
-- 23
------------------------------------------------------------------------------------------------------------------------------------------

-- Primeiro o total de cada pedido; depois a média e a contagem por cliente.
-- (AVG direto sobre Order Details daria a média por item, não por pedido)

;WITH OrderTotalCTE23 AS
(
	  SELECT o.CustomerID,
	         o.OrderID,
	         SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS OrderTotal
	    FROM Orders          o
	    JOIN [Order Details] od ON o.OrderID = od.OrderID
	GROUP BY o.CustomerID, o.OrderID
),
CTE23 AS
(
	  SELECT CustomerID,
	         COUNT(*)        AS TotalOrders,
	         AVG(OrderTotal) AS AvgSpending
	    FROM OrderTotalCTE23
	GROUP BY CustomerID
)
  SELECT TOP 5
         CustomerID,
         TotalOrders,
  	     ROUND(AvgSpending, 2) AS AvgSpending
    FROM CTE23
ORDER BY AvgSpending DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 24
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CTE24 AS
(
	  SELECT p.SupplierID,
	         s.CompanyName,
	         SUM(od.Quantity) AS TotalItens
	    FROM [Order Details] od
	    JOIN Products        p  ON p.ProductID = od.ProductID
	    JOIN Suppliers       s  ON s.SupplierID = p.SupplierID
	   WHERE p.Discontinued = 0
	GROUP BY p.SupplierID, s.CompanyName
)
  SELECT CompanyName,
         TotalItens
    FROM CTE24
ORDER BY TotalItens DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 25
------------------------------------------------------------------------------------------------------------------------------------------

;WITH MonthCTE25 AS
(
      SELECT YEAR(o.OrderDate)                                   AS [Year],
             MONTH(o.OrderDate)                                  AS [Month],
             SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
        FROM Orders          o
        JOIN [Order Details] od ON o.OrderID = od.OrderID
       WHERE YEAR(o.OrderDate) = 1998
    GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate)
),
SalesGrowthCTE AS
(
    SELECT [Year],
           [Month],
           TotalSales,
           LAG(TotalSales) OVER (ORDER BY Year, Month)                         AS PreviousMonthSales,
           (TotalSales - LAG(TotalSales) OVER (ORDER BY Year, Month)) 
				/ NULLIF(LAG(TotalSales) OVER (ORDER BY Year, Month), 0) * 100 AS GrowthPercent
      FROM MonthCTE25
)
  SELECT [Year],
         [Month],
         TotalSales,
         PreviousMonthSales,
         ROUND(GrowthPercent, 2) AS GrowthPercent
    FROM SalesGrowthCTE
ORDER BY [Year], [Month]

------------------------------------------------------------------------------------------------------------------------------------------
-- 26
------------------------------------------------------------------------------------------------------------------------------------------

; WITH CTE26 AS
(
	  SELECT o.ShipRegion,
	         p.ProductName,
	         SUM(od.Quantity)                                                             AS TotalQuantity,
			 ROW_NUMBER() OVER (PARTITION BY o.ShipRegion ORDER BY SUM(od.Quantity) DESC) AS Ranking
	    FROM Orders          o
	    JOIN [Order Details] od ON od.OrderID = o.OrderID
	    JOIN Products        p  ON p.ProductID = od.ProductID
	GROUP BY o.ShipRegion, p.ProductName
)
SELECT ShipRegion,
       ProductName,
	   TotalQuantity
  FROM CTE26
 WHERE Ranking <= 3
   AND ShipRegion IS NOT NULL

------------------------------------------------------------------------------------------------------------------------------------------
-- 27
------------------------------------------------------------------------------------------------------------------------------------------

-- O frete é subtraído uma única vez por pedido (SUM(o.Freight) depois do JOIN multiplicaria o frete pelo número de itens)

;WITH CTE27 AS
(
	  SELECT o.OrderID,
	         ROUND(SUM((od.Quantity * od.UnitPrice) * (1 - od.Discount)) - o.Freight, 2) AS Profit
	    FROM Orders          o
	    JOIN [Order Details] od ON od.OrderID = o.OrderID
	GROUP BY o.OrderID, o.Freight
)
  SELECT TOP 10
         OrderID,
         CAST(Profit AS DECIMAL(10,2)) AS Profit
    FROM CTE27
ORDER BY Profit DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 28
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CTE28 AS
(
      SELECT o.CustomerID,
             COUNT(DISTINCT p.CategoryID) AS CategoryCount
        FROM Orders          o
        JOIN [Order Details] od ON o.OrderID = od.OrderID
        JOIN Products        p  ON od.ProductID = p.ProductID
    GROUP BY o.CustomerID
      HAVING COUNT(DISTINCT p.CategoryID) = (SELECT COUNT(*) FROM Categories)
)
SELECT c.CustomerID,
       c.CompanyName,
       cc.CategoryCount
  FROM CTE28     cc
  JOIN Customers c  ON cc.CustomerID = c.CustomerID

------------------------------------------------------------------------------------------------------------------------------------------
-- 29
------------------------------------------------------------------------------------------------------------------------------------------

-- Os dias com venda são numerados (RowNum) e a recursão avança de um dia com venda para o seguinte.
-- Avançar pelo dia do calendário (DATEADD) interromperia o acumulado no primeiro dia sem pedido

;WITH DailySalesCTE AS (
      SELECT CAST(OrderDate AS DATE)                               AS SaleDate,
             SUM(UnitPrice * Quantity * (1 - Discount))            AS DailyTotal,
             ROW_NUMBER() OVER (ORDER BY CAST(OrderDate AS DATE))  AS RowNum
        FROM Orders          o
        JOIN [Order Details] od ON o.OrderID = od.OrderID
       WHERE MONTH(o.OrderDate) = 1
	     AND YEAR(o.OrderDate) = 1998
    GROUP BY CAST(OrderDate AS DATE)
),
CumulativeSalesCTE AS
(
    SELECT SaleDate,
           DailyTotal,
           DailyTotal AS RunningTotal,
           RowNum
      FROM DailySalesCTE
     WHERE RowNum = 1

	UNION ALL

	SELECT ds.SaleDate,
           ds.DailyTotal,
           cs.RunningTotal + ds.DailyTotal,
           ds.RowNum
      FROM DailySalesCTE ds
      JOIN CumulativeSalesCTE cs ON ds.RowNum = cs.RowNum + 1
)
  SELECT SaleDate,
         CAST(DailyTotal   AS DECIMAL(10,2)) AS DailyTotal,
         CAST(RunningTotal AS DECIMAL(10,2)) AS RunningTotal
    FROM CumulativeSalesCTE
ORDER BY SaleDate

------------------------------------------------------------------------------------------------------------------------------------------
-- 30
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CTE30 AS
(
	  SELECT s.SupplierID, 
	         s.CompanyName, 
			 COUNT(p.ProductID) AS Quantity
	    FROM Products p
	    JOIN Suppliers s ON s.SupplierID = p.SupplierID
	   WHERE p.UnitsInStock < 10
	GROUP BY s.SupplierID, s.CompanyName
)
  SELECT SupplierID,
         CompanyName,
  	     Quantity
    FROM CTE30
ORDER BY Quantity DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 31
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CTE31 AS
(
	  SELECT ShipCountry,
	         ROUND(AVG(Freight), 2) AS CountryAvgFreight
	    FROM Orders
	GROUP BY ShipCountry
)
,CTE31_Global AS
(
	SELECT ROUND(AVG(Freight), 2) AS GlobalAvgFreight
	  FROM Orders
)
    SELECT c.ShipCountry,
	       c.CountryAvgFreight,
		   cg.GlobalAvgFreight,
		   CASE WHEN c.CountryAvgFreight > cg.GlobalAvgFreight THEN 'Acima da média'
		        ELSE 'Abaixo da média'
				 END AS [Status]
      FROM CTE31        c
CROSS JOIN CTE31_Global cg
  ORDER BY c.CountryAvgFreight DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 32
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CTE32 AS
(
      SELECT p.ProductID,
             p.ProductName,
             MIN(od.UnitPrice)                     AS MinPrice,
             MAX(od.UnitPrice)                     AS MaxPrice,
             MAX(od.UnitPrice) - MIN(od.UnitPrice) AS PriceVariation
        FROM Products        p
        JOIN [Order Details] od ON p.ProductID = od.ProductID
    GROUP BY p.ProductID, p.ProductName
)
  SELECT ProductID,
         ProductName,
         MinPrice,
         MaxPrice,
         PriceVariation
    FROM CTE32
   WHERE PriceVariation > 0
ORDER BY PriceVariation DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 33
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CTE33 AS
(
	  SELECT EmployeeID,
	         COUNT(*) AS OrderByEmployee
	    FROM Orders
	GROUP BY EmployeeID
)
, CTE33_GERAL AS
(
	-- CAST para FLOAT: AVG de um inteiro devolve inteiro e descartaria a parte decimal da média
	SELECT AVG(CAST(OrderByEmployee AS FLOAT)) AS AvgOrderEmployee
	  FROM CTE33
)
	SELECT e.EmployeeID,
	       e.FirstName + ' ' + e.LastName AS FullName,
		   c.OrderByEmployee
	  FROM Employees   e
	  JOIN CTE33       c  ON c.EmployeeID = e.EmployeeID
CROSS JOIN CTE33_GERAL cg
     WHERE c.OrderByEmployee > cg.AvgOrderEmployee

------------------------------------------------------------------------------------------------------------------------------------------
-- 34
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CTE34 AS (
      SELECT YEAR(OrderDate)                                     AS [Year],
             DATEPART(QUARTER, OrderDate)                        AS [Quarter],
             SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
        FROM Orders             o
        JOIN [Order Details] od ON o.OrderID = od.OrderID
    GROUP BY YEAR(OrderDate), DATEPART(QUARTER, OrderDate)
)
  SELECT [Year],
         [Quarter],
         TotalSales,
         LAG(TotalSales) OVER (PARTITION BY [Quarter] ORDER BY [Year])                          AS PreviousYearSales,
         ROUND((TotalSales - LAG(TotalSales) OVER (PARTITION BY [Quarter] ORDER BY [Year])) / 
             NULLIF(LAG(TotalSales) OVER (PARTITION BY [Quarter] ORDER BY [Year]), 0) * 100, 2) AS PercentChange
    FROM CTE34
ORDER BY [Year], [Quarter]

------------------------------------------------------------------------------------------------------------------------------------------
-- 35
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CTE35 AS
(
      SELECT o.CustomerID,
             od.ProductID,
             COUNT(DISTINCT o.OrderID) AS OrderCount
        FROM Orders          o
        JOIN [Order Details] od ON od.OrderID = o.OrderID
    GROUP BY o.CustomerID, od.ProductID
      HAVING COUNT(DISTINCT o.OrderID) > 1
)
  SELECT c.CustomerID,
         c.CompanyName,
         p.ProductName,
         cte.OrderCount
    FROM CTE35     cte
    JOIN Customers c   ON c.CustomerID = cte.CustomerID
    JOIN Products  p   ON p.ProductID = cte.ProductID
ORDER BY c.CustomerID, cte.OrderCount DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 36
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CTE36_1 AS (
    SELECT CustomerID,
           OrderID,
           OrderDate,
           LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS PreviousOrderDate
      FROM Orders
),
CTE36_2 AS (
      -- Sem filtrar o primeiro pedido: o COUNT conta todos os pedidos e o AVG já ignora o intervalo nulo do primeiro
      SELECT CustomerID,
             COUNT(OrderID)                                                  AS TotalOrders,
             AVG(CAST(DATEDIFF(DAY, PreviousOrderDate, OrderDate) AS FLOAT)) AS AvgDaysBetween
        FROM CTE36_1
    GROUP BY CustomerID
)
  SELECT c.CustomerID,
         c.CompanyName,
         cte.TotalOrders,
         ROUND(cte.AvgDaysBetween, 0) AS AvgDaysBetweenOrders
    FROM CTE36_2   cte
    JOIN Customers c   ON c.CustomerID = cte.CustomerID
ORDER BY cte.TotalOrders DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 37
------------------------------------------------------------------------------------------------------------------------------------------

-- Nível 1 = cidade, nível 2 = região, nível 3 = país. A recursão sempre vai até o nível 3:
-- quando ShipRegion é nulo, o CONCAT ignora o trecho nulo e o país continua sendo anexado

;WITH CTE37 AS
(
    SELECT OrderID,
           CAST(ShipCity AS NVARCHAR(MAX)) AS Roadmap,
           1 AS [Level]
      FROM Orders
     WHERE ShipCity IS NOT NULL

    UNION ALL

    SELECT o.OrderID,
           CAST(CONCAT(ce.Roadmap, CASE ce.[Level] WHEN 1 THEN N', ' + o.ShipRegion
                                                   WHEN 2 THEN N', ' + o.ShipCountry
                                                   END) AS NVARCHAR(MAX)) AS Roadmap,
           ce.[Level] + 1
      FROM Orders o
      JOIN CTE37  ce ON o.OrderID = ce.OrderID
     WHERE ce.[Level] < 3
)
  SELECT OrderID,
         Roadmap AS RoadmapDelivery
    FROM CTE37
   WHERE [Level] = 3
ORDER BY OrderID ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 38
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CTE38_1 AS
(
	SELECT ProductID,
	       ProductName,
		   UnitsInStock,
		   UnitsOnOrder
	  FROM Products
	 WHERE UnitsInStock = 0
)
SELECT ProductID, 
       ProductName,  
	   UnitsInStock, 
	   UnitsOnOrder
  FROM CTE38_1
 WHERE UnitsOnOrder > 0

------------------------------------------------------------------------------------------------------------------------------------------
-- 39
------------------------------------------------------------------------------------------------------------------------------------------

-- Ticket médio = valor médio por PEDIDO. Primeiro o total de cada pedido, depois a média por funcionário
-- e a média da empresa (todos os pedidos)

;WITH OrderTotalCTE39 AS
(
      SELECT o.EmployeeID,
             o.OrderID,
             SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS OrderTotal
        FROM Orders          o
        JOIN [Order Details] od ON od.OrderID = o.OrderID
    GROUP BY o.EmployeeID, o.OrderID
),
CTE39_1 AS
(
      SELECT EmployeeID,
             AVG(OrderTotal) AS AvgTicket
        FROM OrderTotalCTE39
    GROUP BY EmployeeID
),
CTE39_2 AS
(
    SELECT AVG(OrderTotal) AS AvgCompanyTicket
      FROM OrderTotalCTE39
)
    SELECT e.EmployeeID,
           e.FirstName + ' ' + e.LastName AS FullName,
           ROUND(et.AvgTicket, 2)         AS AvgTicket,
           ROUND(ca.AvgCompanyTicket, 2)  AS AvgCompanyTicket,
           CASE WHEN et.AvgTicket > ca.AvgCompanyTicket THEN 'Acima da Média'
		        ELSE 'Abaixo da Média'
				 END AS Performance
      FROM CTE39_1 et
      JOIN Employees e ON et.EmployeeID = e.EmployeeID
CROSS JOIN CTE39_2 ca
  ORDER BY et.AvgTicket DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 40
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CTE40 AS
(
      SELECT c.CategoryID,
             c.CategoryName,
             p.ProductID,
             p.ProductName,
             SUM(od.Quantity)                                                                                    AS TotalSold,
             SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))                                                 AS TotalSales,
             SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) / 
                 SUM(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))) OVER (PARTITION BY c.CategoryID) * 100 AS SalesPercent,
             ROW_NUMBER() OVER (PARTITION BY c.CategoryID ORDER BY SUM(od.Quantity) DESC)                        AS Ranking
        FROM Categories      c
        JOIN Products        p  ON p.CategoryID = c.CategoryID
        JOIN [Order Details] od ON od.ProductID = p.ProductID
    GROUP BY c.CategoryID, c.CategoryName, p.ProductID, p.ProductName
)
  SELECT CategoryID,
         CategoryName,
         ProductID,
         ProductName,
         TotalSold,
         FORMAT(TotalSales, 'N2') AS TotalSales,
         ROUND(SalesPercent, 2)   AS SalesPercent
    FROM CTE40
   WHERE Ranking <= 5
ORDER BY CategoryID, TotalSold DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 41
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_41
CREATE TABLE #TEMP_41
(
    ProductID    INT,
    OldPrice     DECIMAL(10,2),
    NewPrice     DECIMAL(10,2),
    UpdateDate   DATETIME
)

DROP TABLE IF EXISTS #TEMP_41_LOG
CREATE TABLE #TEMP_41_LOG
(
    ProductID    INT,
    OldPrice     DECIMAL(10,2),
    NewPrice     DECIMAL(10,2),
    UpdateDate   DATETIME,
    ErrorMessage VARCHAR(255)
)

BEGIN TRY
    BEGIN TRAN

	INSERT INTO #TEMP_41
	SELECT ProductID,
	       UnitPrice          AS OldPrice,
		   (UnitPrice * 1.10) AS NewPrice,
		   GETDATE()
	  FROM Products
     WHERE UnitPrice > 0

    -- A validação olha o preço NOVO, gravado na temporária (em Products o preço não mudou)
    IF EXISTS (SELECT 1 FROM #TEMP_41 WHERE NewPrice < 0)
        THROW 50001, 'Preço negativo detectado após atualização.', 1

    COMMIT TRAN
END TRY
BEGIN CATCH
    ROLLBACK TRAN

    INSERT INTO #TEMP_41_LOG (ProductID, OldPrice, NewPrice, UpdateDate, ErrorMessage)
    VALUES (NULL, NULL, NULL, GETDATE(), ERROR_MESSAGE())

	PRINT 'Erro: ' + ERROR_MESSAGE()
END CATCH

SELECT * FROM #TEMP_41
SELECT * FROM #TEMP_41_LOG

DROP TABLE #TEMP_41
DROP TABLE #TEMP_41_LOG

------------------------------------------------------------------------------------------------------------------------------------------
-- 42
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_42
CREATE TABLE #TEMP_42
(
	OrderId      INT,
	Freight      MONEY,
	UpdatedDate  DATETIME,
	ErrorMessage VARCHAR(MAX)
)

DROP TABLE IF EXISTS #TEMP_42_LOG
CREATE TABLE #TEMP_42_LOG
(
	OrderId      INT,
	Freight      MONEY,
	UpdatedDate  DATETIME,
	ErrorMessage VARCHAR(MAX)
)

BEGIN TRY
	BEGIN TRAN

	INSERT INTO #TEMP_42
	SELECT TOP 10
	       OrderID,
		   Freight,
		   GETDATE(),
		   'Tentativa de divisão por zero'
	  FROM Orders
	 WHERE (Freight / 0) IS NOT NULL

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN

	-- O erro capturado é gravado na tabela de log (antes havia só um SELECT, e o log ficava vazio)
	INSERT INTO #TEMP_42_LOG
	SELECT TOP 10
	       OrderID,
		   Freight,
		   GETDATE(),
		   'Erro: ' + ERROR_MESSAGE()
	  FROM Orders
END CATCH

SELECT * FROM #TEMP_42
SELECT * FROM #TEMP_42_LOG

DROP TABLE #TEMP_42
DROP TABLE #TEMP_42_LOG

------------------------------------------------------------------------------------------------------------------------------------------
-- 43
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_43
CREATE TABLE #TEMP_43
(
	CustomerId  VARCHAR(5),
	CompanyName VARCHAR(100),
	UpdatedDate DATETIME,
	LogMessage  VARCHAR(MAX)
)

DROP TABLE IF EXISTS #TEMP_43_LOG
CREATE TABLE #TEMP_43_LOG
(
	CustomerId    VARCHAR(5),
	CompanyName   VARCHAR(100),
	UpdatedDate   DATETIME,
	ErrorMessage  VARCHAR(MAX)
)

BEGIN TRY
	BEGIN TRAN

	DECLARE @CustomerId43  VARCHAR(5)   = 'TESTE',
	        @CompanyName43 VARCHAR(100) = 'Cliente Teste'
	--DECLARE @CustomerId43  VARCHAR(5)   = 'ALFKI',	-- Cenario de cliente duplicado
	--        @CompanyName43 VARCHAR(100) = 'Cliente Teste'

	IF EXISTS (SELECT 1
	             FROM Customers
				WHERE CustomerId = @CustomerId43)
		THROW 50002, 'Tentativa de inserção de cliente duplicado', 1

	-- Para não alterar a base, o novo cliente é inserido em uma temporária
	INSERT INTO #TEMP_43
	VALUES (@CustomerId43, @CompanyName43, GETDATE(), 'Cliente inserido')

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN

	-- Uma linha de log para o cliente que falhou
	INSERT INTO #TEMP_43_LOG
	VALUES (@CustomerId43, @CompanyName43, GETDATE(), 'Erro: ' + ERROR_MESSAGE())

	PRINT 'Erro: ' + ERROR_MESSAGE()
END CATCH

SELECT * FROM #TEMP_43
SELECT * FROM #TEMP_43_LOG

DROP TABLE #TEMP_43
DROP TABLE #TEMP_43_LOG

------------------------------------------------------------------------------------------------------------------------------------------
-- 44
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @OrderId44        INT,
        @ShippedDate44    DATETIME,
        @NewShippedDate44 DATETIME

DROP TABLE IF EXISTS #TEMP_44
CREATE TABLE #TEMP_44
(
	OrderId INT,
	ShippedDate DATETIME,
	UpdatedDate DATETIME,
)

DROP TABLE IF EXISTS #TEMP_44_LOG
CREATE TABLE #TEMP_44_LOG
(
	OrderId INT,
	ShippedDate DATETIME,
	UpdatedDate DATETIME,
	LogMessage  VARCHAR(MAX)
)

-- Tentativa pedida no enunciado: gravar uma data FUTURA em ShippedDate (aqui, um ano à frente) nos pedidos ainda não enviados.
-- A validação rejeita a data e cada tentativa fica registrada no log
DECLARE Cursor44 CURSOR FOR
SELECT OrderID,
       ShippedDate
  FROM Orders
 WHERE ShippedDate IS NULL

OPEN Cursor44
FETCH NEXT FROM Cursor44 INTO @OrderId44, @ShippedDate44

WHILE @@FETCH_STATUS = 0
BEGIN
	BEGIN TRY
		BEGIN TRAN

		SET @NewShippedDate44 = DATEADD(YEAR, 1, GETDATE())

		IF (@NewShippedDate44 > GETDATE())
			THROW 50001, 'Data do produto enviado não pode ser superior à data atual', 1

		INSERT INTO #TEMP_44 (OrderId, ShippedDate, UpdatedDate)
		VALUES (@OrderId44, @NewShippedDate44, GETDATE())

		COMMIT TRAN
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN

		INSERT INTO #TEMP_44_LOG (OrderId, ShippedDate, UpdatedDate, LogMessage)
		VALUES (@OrderId44, @NewShippedDate44, GETDATE(), 'Erro: ' + ERROR_MESSAGE() + '. OrderId: ' + CAST(@OrderId44 AS VARCHAR))
	END CATCH

	FETCH NEXT FROM Cursor44 INTO @OrderId44, @ShippedDate44
END

CLOSE Cursor44
DEALLOCATE Cursor44

SELECT * FROM #TEMP_44
SELECT * FROM #TEMP_44_LOG

DROP TABLE #TEMP_44
DROP TABLE #TEMP_44_LOG

------------------------------------------------------------------------------------------------------------------------------------------
-- 45
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_45
CREATE TABLE #TEMP_45
(
	CategoryId   INT,
	CategoryName VARCHAR(15),
	TotalValue   MONEY,
	UpdatedDate  DATETIME
)

DROP TABLE IF EXISTS #TEMP_45_LOG
CREATE TABLE #TEMP_45_LOG
(
	CategoryId   INT,
	CategoryName VARCHAR(15),
	TotalValue   MONEY,
	UpdatedDate  DATETIME,
	LogMessage   VARCHAR(MAX)
)

BEGIN TRY
	BEGIN TRAN

	INSERT INTO #TEMP_45 (CategoryId, CategoryName, TotalValue, UpdatedDate)
	  SELECT c.CategoryID,
	         c.CategoryName,
	         SUM((od.Quantity * od.UnitPrice) * (1 - od.Discount)) AS TotalValue,
			 GETDATE()
	    FROM [Order Details] od
	    JOIN Products        p  ON p.ProductID = od.ProductID
	    JOIN Categories      c  ON c.CategoryID = p.CategoryID
	GROUP BY c.CategoryID, c.CategoryName	

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN

	INSERT INTO #TEMP_45_LOG (CategoryId, CategoryName, TotalValue, UpdatedDate, LogMessage)
	VALUES (99, 'Erro', NULL, GETDATE(), 'Erro: ' + ERROR_MESSAGE())
END CATCH

SELECT * FROM #TEMP_45
SELECT * FROM #TEMP_45_LOG

DROP TABLE #TEMP_45
DROP TABLE #TEMP_45_LOG

------------------------------------------------------------------------------------------------------------------------------------------
-- 46
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @OrderId46     INT,
        @ProductId46   INT,
		@OldDiscount46 MONEY,
		@NewDiscount46 MONEY

DROP TABLE IF EXISTS #TEMP_46
CREATE TABLE #TEMP_46
(
	OrderId     INT,
	ProductId   INT,
	OldDiscount MONEY,
	NewDiscount MONEY,
	UpdatedDate DATETIME
)

DROP TABLE IF EXISTS #TEMP_46_LOG
CREATE TABLE #TEMP_46_LOG
(
	OrderId     INT,
	ProductId   INT,
	OldDiscount MONEY,
	NewDiscount MONEY,
	UpdatedDate DATETIME,
	LogMessage  VARCHAR(MAX)
)

DECLARE Cursor46 CURSOR FOR
SELECT OrderID,
       ProductID,
	   Discount,
	   Discount - 0.1
  FROM [Order Details]

OPEN Cursor46
FETCH NEXT FROM Cursor46 INTO @OrderId46, @ProductId46, @OldDiscount46, @NewDiscount46

WHILE @@FETCH_STATUS = 0
BEGIN
	BEGIN TRY
		BEGIN TRAN
	
		IF (@NewDiscount46 < 0)
			BEGIN
				INSERT INTO #TEMP_46_LOG (OrderId, ProductId, OldDiscount, NewDiscount, UpdatedDate, LogMessage)
				VALUES (@OrderId46, @ProductId46, @OldDiscount46, @NewDiscount46, GETDATE(), 'Desconto não pode ter valor negativo')
			END
		ELSE
			BEGIN
				INSERT INTO #TEMP_46 (OrderId, ProductId, OldDiscount, NewDiscount, UpdatedDate)
				VALUES (@OrderId46, @ProductId46, @OldDiscount46, @NewDiscount46, GETDATE())
			END
	
		COMMIT TRAN
	END TRY
	
	BEGIN CATCH
		ROLLBACK TRAN
	
		PRINT 'Erro: ' + ERROR_MESSAGE()
	END CATCH

	FETCH NEXT FROM Cursor46 INTO @OrderId46, @ProductId46, @OldDiscount46, @NewDiscount46
END

CLOSE Cursor46
DEALLOCATE Cursor46

SELECT * FROM #TEMP_46
SELECT * FROM #TEMP_46_LOG

DROP TABLE #TEMP_46
DROP TABLE #TEMP_46_LOG

------------------------------------------------------------------------------------------------------------------------------------------
-- 47
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_47
CREATE TABLE #TEMP_47
(
	ProductID    INT,
	ErrorMessage VARCHAR(MAX),
	LogDate      DATETIME
)

BEGIN TRY
    BEGIN TRAN

    DELETE FROM Products
          WHERE Discontinued = 1
    
	COMMIT TRAN
END TRY
BEGIN CATCH
    ROLLBACK TRAN
    
	INSERT INTO #TEMP_47 (ProductID, ErrorMessage, LogDate)
    SELECT ProductID, 
	       ERROR_MESSAGE(), 
		   GETDATE()
      FROM Products
     WHERE Discontinued = 1;
    
	PRINT 'Erro: ' + ERROR_MESSAGE();
END CATCH

SELECT * FROM #TEMP_47
DROP TABLE #TEMP_47

------------------------------------------------------------------------------------------------------------------------------------------
-- 48
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_48
CREATE TABLE #TEMP_48
(
	OrderId    INT,
	LogData    DATETIME
)

DROP TABLE IF EXISTS #TEMP_48_LOG
CREATE TABLE #TEMP_48_LOG
(
	OrderId    INT,
	LogData    DATETIME,
	LogMessage VARCHAR(MAX)
)

BEGIN TRY
	BEGIN TRAN

	DECLARE @OrderId48 INT = 99999
	--DECLARE @OrderId48 INT = 10248	-- Cenario de chave duplicada
	
	IF EXISTS (SELECT 1 FROM Orders WHERE OrderID = @OrderId48)
		THROW 50001, 'Chave duplicada', 1

	INSERT INTO #TEMP_48
	VALUES (@OrderId48, GETDATE())

	COMMIT TRAN
END TRY

BEGIN CATCH
	ROLLBACK TRAN

	INSERT INTO #TEMP_48_LOG
	VALUES (@OrderId48, GETDATE(), 'Erro: ' + ERROR_MESSAGE())
END CATCH

SELECT * FROM #TEMP_48
SELECT * FROM #TEMP_48_LOG

DROP TABLE #TEMP_48
DROP TABLE #TEMP_48_LOG

------------------------------------------------------------------------------------------------------------------------------------------
-- 49
------------------------------------------------------------------------------------------------------------------------------------------

-- A versão anterior deste exercício criava a tabela permanente ProfitErrorLog no Northwind.
-- Se ela existir na sua base, pode ser removida com: DROP TABLE IF EXISTS ProfitErrorLog

DROP TABLE IF EXISTS #TEMP_49_LOG
CREATE TABLE #TEMP_49_LOG
(
    ErrorMessage NVARCHAR(255),
    LogDate      DATETIME
)

BEGIN TRY
    -- Valores nulos são tratados na origem: item sem preço ou sem quantidade entra com lucro zero.
    -- (NULLIF(0, 0) devolvia NULL, e dividir por NULL não gera erro: o CATCH nunca era executado)
    ;WITH OrderProfit AS (
        SELECT
            OrderID,
            SUM(ISNULL(UnitPrice, 0) * ISNULL(Quantity, 0) * (1 - ISNULL(Discount, 0))) AS Profit
        FROM [Order Details]
        GROUP BY OrderID
    )
    SELECT
        OrderID,
        CAST(Profit AS DECIMAL(10,2)) AS Profit
    FROM OrderProfit
    ORDER BY OrderID
END TRY
BEGIN CATCH
    INSERT INTO #TEMP_49_LOG (ErrorMessage, LogDate)
    VALUES (ERROR_MESSAGE(), GETDATE())

    PRINT 'Erro: ' + ERROR_MESSAGE();
END CATCH

SELECT * FROM #TEMP_49_LOG
DROP TABLE #TEMP_49_LOG

------------------------------------------------------------------------------------------------------------------------------------------
-- 50
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @EmployeeId50  INT,
        @HireDate50    DATETIME,
        @NewHireDate50 DATE

DROP TABLE IF EXISTS #TEMP_50
CREATE TABLE #TEMP_50
(
	EmployeeId INT,
	HireDate   DATETIME,
	LogDate    DATETIME,
	LogMessage VARCHAR(MAX)
)

DECLARE Cursor50 CURSOR FOR
SELECT EmployeeID,
       HireDate
  FROM Employees

OPEN Cursor50
FETCH NEXT FROM Cursor50 INTO @EmployeeId50, @HireDate50

WHILE @@FETCH_STATUS = 0
BEGIN
	BEGIN TRY
		-- Tentativa pedida no enunciado: trocar HireDate por uma data inválida. Aqui, o dia 31 do mesmo mês:
		-- nos meses com menos de 31 dias a data não existe, o DATEFROMPARTS gera erro e o erro é registrado
		SET @NewHireDate50 = DATEFROMPARTS(YEAR(@HireDate50), MONTH(@HireDate50), 31)

		PRINT 'FUNCIONOU: funcionário ' + CAST(@EmployeeId50 AS VARCHAR) + ' -> ' + CONVERT(VARCHAR(10), @NewHireDate50, 23)
	END TRY

	BEGIN CATCH
		INSERT INTO #TEMP_50
		VALUES (@EmployeeId50, @HireDate50, GETDATE(), 'ERRO: ' + ERROR_MESSAGE())
	END CATCH

	FETCH NEXT FROM Cursor50 INTO @EmployeeId50, @HireDate50
END

CLOSE Cursor50
DEALLOCATE Cursor50

SELECT * FROM #TEMP_50
DROP TABLE #TEMP_50

------------------------------------------------------------------------------------------------------------------------------------------
-- 51
------------------------------------------------------------------------------------------------------------------------------------------

-- PENDENTE: exercícios 51 a 60 ainda não resolvidos

