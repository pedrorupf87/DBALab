
USE NORTHWIND
GO

------------------------------------------------------------------------------------------------------------------------------------------
-- 01
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @Country01      VARCHAR(50), 
        @FreightTotal01 MONEY

DROP TABLE IF EXISTS #TEMP_01
CREATE TABLE #TEMP_01
(
    Country      VARCHAR(50), 
    FreightTotal MONEY
)

DECLARE FreightTotalOrders CURSOR FOR  
  SELECT ShipCountry, 
         SUM(Freight)  
    FROM Orders  
GROUP BY ShipCountry

OPEN FreightTotalOrders
FETCH NEXT FROM FreightTotalOrders INTO @Country01, @FreightTotal01

WHILE @@FETCH_STATUS = 0  
BEGIN  
    INSERT INTO #TEMP_01 VALUES (@Country01, @FreightTotal01)

    FETCH NEXT FROM FreightTotalOrders INTO @Country01, @FreightTotal01
END

CLOSE FreightTotalOrders
DEALLOCATE FreightTotalOrders

SELECT * FROM #TEMP_01
DROP TABLE #TEMP_01

------------------------------------------------------------------------------------------------------------------------------------------
-- 02
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @ProductId02    INT,
        @ProductName02  VARCHAR(50),
        @UnitsInStock02 INT,
        @UnitPrice02    MONEY

DROP TABLE IF EXISTS #TEMP_02
CREATE TABLE #TEMP_02
(
    ProductId    INT,
    ProductName  VARCHAR(50),
    UnitsInStock INT,
    OldUnitPrice MONEY,
    NewUnitPrice MONEY
)

DECLARE DiscountCursor CURSOR FOR
SELECT ProductID,
       ProductName,
       UnitsInStock,
       UnitPrice
  FROM Products
 WHERE UnitsInStock > 50

OPEN DiscountCursor
FETCH NEXT FROM DiscountCursor INTO @ProductId02, @ProductName02, @UnitsInStock02, @UnitPrice02

WHILE @@FETCH_STATUS = 0
BEGIN
    -- O desconto de 10% é aplicado dentro do cursor, produto a produto
    INSERT INTO #TEMP_02
    VALUES ( @ProductId02, @ProductName02, @UnitsInStock02, @UnitPrice02, @UnitPrice02 * 0.9 )

    FETCH NEXT FROM DiscountCursor INTO @ProductId02, @ProductName02, @UnitsInStock02, @UnitPrice02
END

CLOSE DiscountCursor
DEALLOCATE DiscountCursor

SELECT * FROM #TEMP_02
DROP TABLE #TEMP_02

------------------------------------------------------------------------------------------------------------------------------------------
-- 03
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @CustomerId03  CHAR(5),
        @QtyOrders03   INT,
        @TotalOrders03 MONEY

DROP TABLE IF EXISTS #TEMP_03
CREATE TABLE #TEMP_03
(
    CustomerId  CHAR(5),
    QtyOrders   INT,
    TotalOrders MONEY
)

-- Totais de pedido por cliente: quantidade de pedidos e valor dos itens (Order Details). Freight é só o frete
DECLARE TotalByCustomerCursor CURSOR FOR
  SELECT o.CustomerID,
         COUNT( DISTINCT o.OrderID )                             AS QtyOrders,
         SUM( od.Quantity * od.UnitPrice * ( 1 - od.Discount ) ) AS TotalOrders
    FROM Orders           o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY o.CustomerID

OPEN TotalByCustomerCursor
FETCH NEXT FROM TotalByCustomerCursor INTO @CustomerId03, @QtyOrders03, @TotalOrders03

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_03
    VALUES ( @CustomerId03, @QtyOrders03, @TotalOrders03 )

    FETCH NEXT FROM TotalByCustomerCursor INTO @CustomerId03, @QtyOrders03, @TotalOrders03
END

CLOSE TotalByCustomerCursor
DEALLOCATE TotalByCustomerCursor

SELECT * FROM #TEMP_03
DROP TABLE #TEMP_03

------------------------------------------------------------------------------------------------------------------------------------------
-- 04
------------------------------------------------------------------------------------------------------------------------------------------

-- Irei adotar como ultimo ano igual a 1998
-- Inativo = cliente SEM nenhum pedido nos últimos dois anos (NOT EXISTS), incluindo quem nunca comprou

DECLARE @CustomerId04 CHAR(5)

DROP TABLE IF EXISTS #TEMP_04
CREATE TABLE #TEMP_04
(
    CustomerId CHAR(5),
    [Status]   VARCHAR(10)
)

DECLARE CustomerInactiveCursor CURSOR FOR
SELECT c.CustomerID
  FROM Customers c
 WHERE NOT EXISTS ( SELECT 1
                      FROM Orders o
                     WHERE o.CustomerID = c.CustomerID
                       AND o.OrderDate >= DATEADD( YEAR, -2, '19981231' ) )

OPEN CustomerInactiveCursor
FETCH NEXT FROM CustomerInactiveCursor INTO @CustomerId04

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_04 VALUES ( @CustomerId04, 'INACTIVE' )

    FETCH NEXT FROM CustomerInactiveCursor INTO @CustomerId04
END

CLOSE CustomerInactiveCursor
DEALLOCATE CustomerInactiveCursor

SELECT * FROM #TEMP_04
DROP TABLE #TEMP_04

------------------------------------------------------------------------------------------------------------------------------------------
-- 05
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @CategoryId05   INT,
        @CategoryName05 VARCHAR(40),
        @AvgPrice05     MONEY

DROP TABLE IF EXISTS #TEMP_05
CREATE TABLE #TEMP_05
(
    CategoryId   INT,
    CategoryName VARCHAR(40),
    AvgPrice     MONEY
)

DECLARE AvgPriceCursor CURSOR FOR
  SELECT c.CategoryID,
         c.CategoryName,
         AVG(p.UnitPrice)
    FROM Products p
    JOIN Categories c ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryID, c.CategoryName

OPEN AvgPriceCursor
FETCH NEXT FROM AvgPriceCursor INTO @CategoryId05, @CategoryName05, @AvgPrice05

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_05
    VALUES ( @CategoryId05, @CategoryName05, @AvgPrice05 )

    FETCH NEXT FROM AvgPriceCursor INTO @CategoryId05, @CategoryName05, @AvgPrice05
END

CLOSE AvgPriceCursor
DEALLOCATE AvgPriceCursor

-- Média de preço por categoria
SELECT * FROM #TEMP_05

-- Produtos de cada categoria, com a média da categoria ao lado
  SELECT t.CategoryName,
         p.ProductName,
         p.UnitPrice,
         t.AvgPrice
    FROM Products p
    JOIN #TEMP_05 t ON t.CategoryId = p.CategoryID
ORDER BY t.CategoryName, p.ProductName

DROP TABLE #TEMP_05

------------------------------------------------------------------------------------------------------------------------------------------
-- 06
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @ProductId06    INT,
        @ProductName06  VARCHAR(50),
        @UnitsInStock06 INT

DROP TABLE IF EXISTS #TEMP_06
CREATE TABLE #TEMP_06
(
    ProductId    INT,
    ProductName  VARCHAR(50),
    UnitsInStock INT
)

DECLARE StockCursor CURSOR FOR
SELECT ProductId,
       ProductName,
       UnitsInStock
  FROM Products
 WHERE UnitsInStock < 10
   AND Discontinued = 0

OPEN StockCursor
FETCH NEXT FROM StockCursor INTO @ProductId06, @ProductName06, @UnitsInStock06

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_06
    VALUES ( @ProductId06, @ProductName06, @UnitsInStock06 )

    FETCH NEXT FROM StockCursor INTO @ProductId06, @ProductName06, @UnitsInStock06
END

CLOSE StockCursor
DEALLOCATE StockCursor

SELECT * FROM #TEMP_06
DROP TABLE #TEMP_06

------------------------------------------------------------------------------------------------------------------------------------------
-- 07
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @OrderYear07   INT,
        @TotalOrders07 INT

DROP TABLE IF EXISTS #TEMP_07
CREATE TABLE #TEMP_07
(
    OrderYear   INT,
    TotalOrders INT
)

-- Cursor sobre os anos distintos; o total de pedidos de cada ano é contado dentro do loop
DECLARE TotalOrdersYearCursor CURSOR FOR
  SELECT DISTINCT
         YEAR(OrderDate) AS OrderYear
    FROM Orders
ORDER BY OrderYear ASC

OPEN TotalOrdersYearCursor
FETCH NEXT FROM TotalOrdersYearCursor INTO @OrderYear07

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TotalOrders07 = ( SELECT COUNT(*)
                             FROM Orders
                            WHERE YEAR(OrderDate) = @OrderYear07 )

    INSERT INTO #TEMP_07
    VALUES ( @OrderYear07, @TotalOrders07 )

    FETCH NEXT FROM TotalOrdersYearCursor INTO @OrderYear07
END

CLOSE TotalOrdersYearCursor
DEALLOCATE TotalOrdersYearCursor

SELECT * FROM #TEMP_07
DROP TABLE #TEMP_07

------------------------------------------------------------------------------------------------------------------------------------------
-- 08
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @Country08    VARCHAR(30),
        @AvgFreight08 FLOAT,
        @SDFreight08  FLOAT

DROP TABLE IF EXISTS #TEMP_08
CREATE TABLE #TEMP_08
(
    Country    VARCHAR(50),
    AvgFreight FLOAT,
    SDFreight  FLOAT
)

DECLARE FreightCountryCursor CURSOR FOR
  SELECT ShipCountry,
         ROUND(AVG(Freight), 2)   AS AvgFreight,
         ROUND(STDEV(Freight), 2) AS SDFreight
    FROM Orders
GROUP BY ShipCountry
ORDER BY ShipCountry ASC

OPEN FreightCountryCursor
FETCH NEXT FROM FreightCountryCursor INTO @Country08, @AvgFreight08, @SDFreight08

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_08
    VALUES ( @Country08, @AvgFreight08, @SDFreight08 )

    FETCH NEXT FROM FreightCountryCursor INTO @Country08, @AvgFreight08, @SDFreight08
END

CLOSE FreightCountryCursor
DEALLOCATE FreightCountryCursor

SELECT * FROM #TEMP_08
DROP TABLE #TEMP_08

------------------------------------------------------------------------------------------------------------------------------------------
-- 09
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @CustomerId09 CHAR(5), 
        @OrderId09    INT, 
        @OrderYear09  INT

DROP TABLE IF EXISTS #TEMP_09
CREATE TABLE #TEMP_09
(
    CustomerId CHAR(5), 
    OrderId    INT, 
    OrderYear  INT
)

DECLARE CustomersCursor CURSOR FOR  
SELECT DISTINCT 
       CustomerID  
  FROM Orders

OPEN CustomersCursor
FETCH NEXT FROM CustomersCursor INTO @CustomerId09

WHILE @@FETCH_STATUS = 0  
BEGIN  
    DECLARE OrdersCursor CURSOR FOR  
    SELECT OrderID, 
           YEAR(OrderDate) AS OrderYear  
      FROM Orders  
     WHERE CustomerID = @CustomerId09

    OPEN OrdersCursor
    FETCH NEXT FROM OrdersCursor INTO @OrderId09, @OrderYear09

    WHILE @@FETCH_STATUS = 0  
    BEGIN  
        INSERT INTO #TEMP_09 
        VALUES ( @CustomerId09, @OrderId09, @OrderYear09 ) 
        
        FETCH NEXT FROM OrdersCursor INTO @OrderId09, @OrderYear09
    END

    CLOSE OrdersCursor
    DEALLOCATE OrdersCursor

    FETCH NEXT FROM CustomersCursor INTO @CustomerId09  
END

CLOSE CustomersCursor  
DEALLOCATE CustomersCursor

SELECT * FROM #TEMP_09
DROP TABLE #TEMP_09

------------------------------------------------------------------------------------------------------------------------------------------
-- 10
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @OrderId10    INT,
        @TotalPrice10 MONEY

DROP TABLE IF EXISTS #TEMP_10
CREATE TABLE #TEMP_10
(
    OrderId    INT,
    TotalPrice MONEY
)

-- O valor total é do PEDIDO: soma de todos os itens (quantidade x preço unitário) de cada OrderID
DECLARE TotalPriceCursor CURSOR FOR
  SELECT OrderID,
         SUM( Quantity * UnitPrice ) AS TotalPrice
    FROM [Order Details]
GROUP BY OrderID
  HAVING SUM( Quantity * UnitPrice ) > 5000

OPEN TotalPriceCursor
FETCH NEXT FROM TotalPriceCursor INTO @OrderId10, @TotalPrice10

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_10
    VALUES ( @OrderId10, @TotalPrice10 )

    FETCH NEXT FROM TotalPriceCursor INTO @OrderId10, @TotalPrice10
END

CLOSE TotalPriceCursor
DEALLOCATE TotalPriceCursor

SELECT * FROM #TEMP_10 ORDER BY TotalPrice DESC
DROP TABLE #TEMP_10

------------------------------------------------------------------------------------------------------------------------------------------
-- 11
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @EmployeeId11 INT,
        @TotalSales11 MONEY

DROP TABLE IF EXISTS #TEMP_11
CREATE TABLE #TEMP_11
(
    EmployeeId INT,
    TotalSales MONEY
)

-- Vendas = valor dos itens dos pedidos (Order Details). Freight é só o frete
DECLARE TotalByEmployeeCursor CURSOR FOR
  SELECT o.EmployeeID,
         SUM( od.Quantity * od.UnitPrice * ( 1 - od.Discount ) ) AS TotalSales
    FROM Orders           o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY o.EmployeeID
ORDER BY o.EmployeeID

OPEN TotalByEmployeeCursor
FETCH NEXT FROM TotalByEmployeeCursor INTO @EmployeeId11, @TotalSales11

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_11
    VALUES ( @EmployeeId11, @TotalSales11 )

    FETCH NEXT FROM TotalByEmployeeCursor INTO @EmployeeId11, @TotalSales11
END

CLOSE TotalByEmployeeCursor
DEALLOCATE TotalByEmployeeCursor

SELECT * FROM #TEMP_11
DROP TABLE #TEMP_11

------------------------------------------------------------------------------------------------------------------------------------------
-- 12
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @ProductId12    INT,
        @ProductName12  VARCHAR(50),
        @UnitsInStock12 INT

DROP TABLE IF EXISTS #TEMP_12
CREATE TABLE #TEMP_12
(
    ProductId    INT,
    ProductName  VARCHAR(50),
    UnitsInStock INT
)

DROP TABLE IF EXISTS #TEMP_12_AUX
CREATE TABLE #TEMP_12_AUX
(
    ProductId    INT,
    ProductName  VARCHAR(50),
    UnitsInStock INT
)

DECLARE UpdateStockCursor CURSOR FOR
SELECT ProductID,
       ProductName,
       UnitsInStock
  FROM Products
 WHERE UnitsInStock > 100

OPEN UpdateStockCursor
FETCH NEXT FROM UpdateStockCursor INTO @ProductId12, @ProductName12, @UnitsInStock12

WHILE @@FETCH_STATUS = 0
BEGIN
    -- O estoque de origem perde 50 unidades...
    INSERT INTO #TEMP_12
    VALUES ( @ProductId12, @ProductName12, @UnitsInStock12 - 50 )

    -- ...e o outro inventário recebe exatamente essas 50 unidades
    INSERT INTO #TEMP_12_AUX
    VALUES ( @ProductId12, @ProductName12, 50 )

    FETCH NEXT FROM UpdateStockCursor INTO @ProductId12, @ProductName12, @UnitsInStock12
END

CLOSE UpdateStockCursor
DEALLOCATE UpdateStockCursor

SELECT 'TABELA ORIGINAL'
SELECT ProductID,
       ProductName,
       UnitsInStock
  FROM Products
 WHERE UnitsInStock > 100

SELECT 'ESTOQUE APÓS A RETIRADA'
SELECT * FROM #TEMP_12
SELECT 'UNIDADES MOVIDAS PARA O OUTRO INVENTÁRIO'
SELECT * FROM #TEMP_12_AUX

DROP TABLE #TEMP_12
DROP TABLE #TEMP_12_AUX

------------------------------------------------------------------------------------------------------------------------------------------
-- 13
------------------------------------------------------------------------------------------------------------------------------------------

-- "Vendas baixas" = quantidade total vendida (Order Details) abaixo de um limite. O limite de 600 unidades é arbitrário

DECLARE @ProductId13   INT,
        @ProductName13 VARCHAR(50),
        @UnitPrice13   MONEY,
        @TotalSold13   INT,
        @MinSold13     INT = 600

DROP TABLE IF EXISTS #TEMP_13
CREATE TABLE #TEMP_13
(
    ProductId   INT,
    ProductName VARCHAR(50),
    TotalSold   INT,
    OldPrice    MONEY,
    NewPrice    MONEY
)

DECLARE UpdatePriceCursor CURSOR FOR
   SELECT p.ProductID,
          p.ProductName,
          p.UnitPrice,
          ISNULL( SUM(od.Quantity), 0 ) AS TotalSold
     FROM Products         p
LEFT JOIN [Order Details] od ON od.ProductID = p.ProductID
    WHERE p.CategoryID = 1
 GROUP BY p.ProductID, p.ProductName, p.UnitPrice
   HAVING ISNULL( SUM(od.Quantity), 0 ) < @MinSold13

OPEN UpdatePriceCursor
FETCH NEXT FROM UpdatePriceCursor INTO @ProductId13, @ProductName13, @UnitPrice13, @TotalSold13

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_13
    VALUES ( @ProductId13, @ProductName13, @TotalSold13, @UnitPrice13, @UnitPrice13 * 0.95 )

    FETCH NEXT FROM UpdatePriceCursor INTO @ProductId13, @ProductName13, @UnitPrice13, @TotalSold13
END

CLOSE UpdatePriceCursor
DEALLOCATE UpdatePriceCursor

SELECT * FROM #TEMP_13
DROP TABLE #TEMP_13

------------------------------------------------------------------------------------------------------------------------------------------
-- 14
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @OrderId14    INT,
        @Freight14    MONEY,
        @TotalOrder14 MONEY,
        @FreightPct14 FLOAT

DROP TABLE IF EXISTS #TEMP_14
CREATE TABLE #TEMP_14
(
    OrderId    INT,
    Freight    MONEY,
    TotalOrder MONEY,
    FreightPct FLOAT
)

DECLARE FreightPctCursor CURSOR FOR
SELECT o.OrderID,
       o.Freight,
       SUM( od.Quantity * od.UnitPrice ) AS TotalOrder
  FROM Orders o
  JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY o.OrderID, o.Freight

OPEN FreightPctCursor
FETCH NEXT FROM FreightPctCursor INTO @OrderId14, @Freight14, @TotalOrder14

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @FreightPct14 = ROUND(( @Freight14 / @TotalOrder14 ) * 100.0, 2)

    INSERT INTO #TEMP_14
    VALUES ( @OrderId14, @Freight14, @TotalOrder14, @FreightPct14 )

    FETCH NEXT FROM FreightPctCursor INTO @OrderId14, @Freight14, @TotalOrder14
END

CLOSE FreightPctCursor
DEALLOCATE FreightPctCursor

SELECT * FROM #TEMP_14
DROP TABLE #TEMP_14

------------------------------------------------------------------------------------------------------------------------------------------
-- 15
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @ProductId15  INT,
        @CustomerId15 CHAR(5)

DROP TABLE IF EXISTS #TEMP_15
CREATE TABLE #TEMP_15
(
    CustomerId CHAR(5),
    ProductId  INT
)

DECLARE CustomerCursor CURSOR FOR
SELECT DISTINCT
       CustomerID
  FROM Customers

OPEN CustomerCursor
FETCH NEXT FROM CustomerCursor INTO @CustomerId15

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE ProductsCursor CURSOR FOR
      SELECT TOP 1 
             ProductID  
        FROM [Order Details] od
        JOIN Orders o ON o.OrderID = od.OrderID  
       WHERE o.CustomerID = @CustomerId15  
    GROUP BY ProductID  
    ORDER BY SUM(Quantity) DESC

    OPEN ProductsCursor
    FETCH NEXT FROM ProductsCursor INTO @ProductId15

    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO #TEMP_15
        VALUES ( @CustomerId15, @ProductId15 )

        FETCH NEXT FROM ProductsCursor INTO @ProductId15
    END

    CLOSE ProductsCursor
    DEALLOCATE ProductsCursor

    FETCH NEXT FROM CustomerCursor INTO @CustomerId15
END

CLOSE CustomerCursor
DEALLOCATE CustomerCursor

SELECT * FROM #TEMP_15
DROP TABLE #TEMP_15

------------------------------------------------------------------------------------------------------------------------------------------
-- 16
------------------------------------------------------------------------------------------------------------------------------------------

-- Período analisado: ano de 1997

DECLARE @Region16    VARCHAR(50),
        @BeginDate16 DATETIME = '19970101',
        @EndDate16   DATETIME = '19971231'

DROP TABLE IF EXISTS #TEMP_16
CREATE TABLE #TEMP_16
(
    Region NVARCHAR(50)
)

-- Regiões de clientes sem nenhum pedido dentro do período
DECLARE RegionCursor CURSOR FOR
SELECT DISTINCT
       c.Region
  FROM Customers c
 WHERE c.Region IS NOT NULL
   AND NOT EXISTS ( SELECT 1
                      FROM Orders    o
                      JOIN Customers c2 ON c2.CustomerID = o.CustomerID
                     WHERE c2.Region = c.Region
                       AND o.OrderDate BETWEEN @BeginDate16 AND @EndDate16 )

OPEN RegionCursor
FETCH NEXT FROM RegionCursor INTO @Region16

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_16
    VALUES ( @Region16 )
    FETCH NEXT FROM RegionCursor INTO @Region16
END

CLOSE RegionCursor
DEALLOCATE RegionCursor

SELECT * FROM #TEMP_16
DROP TABLE #TEMP_16

------------------------------------------------------------------------------------------------------------------------------------------
-- 17
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @SupplierId17 INT,
        @ProductId17  INT,
        @OrderId17    INT

DROP TABLE IF EXISTS #TEMP_17
CREATE TABLE #TEMP_17 
(
    SupplierID INT, 
    OrderID    INT
)

DECLARE SupplierCursor CURSOR FOR  
SELECT DISTINCT
       SupplierID  
  FROM Suppliers

OPEN SupplierCursor
FETCH NEXT FROM SupplierCursor INTO @SupplierId17

WHILE @@FETCH_STATUS = 0  
BEGIN  
    DECLARE ProductCursor CURSOR FOR  
    SELECT ProductID  
      FROM Products  
     WHERE SupplierID = @SupplierId17

    OPEN ProductCursor
    FETCH NEXT FROM ProductCursor INTO @ProductId17

    WHILE @@FETCH_STATUS = 0  
    BEGIN  
        DECLARE OrdersCursor CURSOR FOR  
        SELECT DISTINCT 
               OrderID  
          FROM [Order Details]  
         WHERE ProductID = @ProductId17

        OPEN OrdersCursor
        FETCH NEXT FROM OrdersCursor INTO @OrderId17

        WHILE @@FETCH_STATUS = 0  
        BEGIN  
            INSERT INTO #TEMP_17 
            VALUES ( @SupplierId17, @OrderId17 )

            FETCH NEXT FROM OrdersCursor INTO @OrderId17  
        END

        CLOSE OrdersCursor  
        DEALLOCATE OrdersCursor

        FETCH NEXT FROM ProductCursor INTO @ProductId17
    END

    CLOSE ProductCursor
    DEALLOCATE ProductCursor

    FETCH NEXT FROM SupplierCursor INTO @SupplierId17
END

CLOSE SupplierCursor
DEALLOCATE SupplierCursor

SELECT * FROM #TEMP_17 ORDER BY SupplierID
DROP TABLE #TEMP_17

------------------------------------------------------------------------------------------------------------------------------------------
-- 18
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @OrderId18 INT,
        @Freight18 MONEY

DROP TABLE IF EXISTS #TEMP_18
CREATE TABLE #TEMP_18
(
    OrderId INT,
    Freight MONEY
)

DECLARE UpdateFreightCursor CURSOR FOR
SELECT OrderID, 
       Freight  
  FROM Orders  
 WHERE OrderID IN (   SELECT OrderID  
                        FROM [Order Details]  
                    GROUP BY OrderID  
                      HAVING SUM( UnitPrice * Quantity ) > 1000 )

OPEN UpdateFreightCursor
FETCH NEXT FROM UpdateFreightCursor INTO @OrderId18, @Freight18

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_18
    VALUES ( @OrderId18, @Freight18 * 1.05 )

    FETCH NEXT FROM UpdateFreightCursor INTO @OrderId18, @Freight18
END

CLOSE UpdateFreightCursor
DEALLOCATE UpdateFreightCursor

SELECT OrderID, 
       Freight  
  FROM Orders  
 WHERE OrderID IN (   SELECT OrderID  
                        FROM [Order Details]  
                    GROUP BY OrderID  
                      HAVING SUM( UnitPrice * Quantity ) > 1000 )

SELECT OrderId,
       ROUND(Freight, 2) AS Freight
  FROM #TEMP_18

DROP TABLE #TEMP_18

------------------------------------------------------------------------------------------------------------------------------------------
-- 19
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @ProductId19     INT,
        @ProductName19   VARCHAR(50),
        @QtyOrders19     INT,
        @TotalQuantity19 INT

DROP TABLE IF EXISTS #TEMP_19
CREATE TABLE #TEMP_19
(
    ProductId     INT,
    ProductName   VARCHAR(50),
    QtyOrders     INT,
    TotalQuantity INT
)

-- O total de vendas é por PRODUTO descontinuado: em quantos pedidos entrou e quantas unidades vendeu
DECLARE TotalDiscontinuedValueCursor CURSOR FOR
  SELECT p.ProductID,
         p.ProductName,
         COUNT( DISTINCT od.OrderID ) AS QtyOrders,
         SUM( od.Quantity )           AS TotalQuantity
    FROM Products         p
    JOIN [Order Details] od ON od.ProductID = p.ProductID
   WHERE p.Discontinued = 1
GROUP BY p.ProductID, p.ProductName

OPEN TotalDiscontinuedValueCursor
FETCH NEXT FROM TotalDiscontinuedValueCursor INTO @ProductId19, @ProductName19, @QtyOrders19, @TotalQuantity19

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_19
    VALUES ( @ProductId19, @ProductName19, @QtyOrders19, @TotalQuantity19 )

    FETCH NEXT FROM TotalDiscontinuedValueCursor INTO @ProductId19, @ProductName19, @QtyOrders19, @TotalQuantity19
END

CLOSE TotalDiscontinuedValueCursor
DEALLOCATE TotalDiscontinuedValueCursor

SELECT * FROM #TEMP_19
DROP TABLE #TEMP_19

------------------------------------------------------------------------------------------------------------------------------------------
-- 20
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @ProductId20    INT,
        @ProductName20  VARCHAR(50),
        @UnitsInStock20 INT

-- O alerta é registrado em uma tabela auxiliar, como pede o enunciado
DROP TABLE IF EXISTS #TEMP_20
CREATE TABLE #TEMP_20
(
    ProductId    INT,
    ProductName  VARCHAR(50),
    UnitsInStock INT,
    AlertMessage VARCHAR(200),
    AlertDate    DATETIME
)

DECLARE CriticalStockCursor CURSOR FOR
SELECT ProductID,
       ProductName,
       UnitsInStock
  FROM Products
 WHERE UnitsInStock < 5

OPEN CriticalStockCursor
FETCH NEXT FROM CriticalStockCursor INTO @ProductId20, @ProductName20, @UnitsInStock20

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_20
    VALUES ( @ProductId20,
             @ProductName20,
             @UnitsInStock20,
             'O produto ' + CAST( @ProductId20 AS VARCHAR ) + ' - ' + @ProductName20 + ' encontra-se abaixo do estoque mínimo.',
             GETDATE() )

    FETCH NEXT FROM CriticalStockCursor INTO @ProductId20, @ProductName20, @UnitsInStock20
END

CLOSE CriticalStockCursor
DEALLOCATE CriticalStockCursor

SELECT * FROM #TEMP_20
DROP TABLE #TEMP_20

