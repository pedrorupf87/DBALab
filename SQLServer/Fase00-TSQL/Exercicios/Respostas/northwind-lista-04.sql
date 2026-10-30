
USE Northwind
GO

------------------------------------------------------------------------------------------------------------------------------------------
-- 01
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @CustomerId01  CHAR(5),
        @CompanyName01 VARCHAR(50),
        @Region01      VARCHAR(15)

DROP TABLE IF EXISTS #TEMP_01
CREATE TABLE #TEMP_01
(
    CustomerId  CHAR(5),
    CompanyName VARCHAR(50),
    Region      VARCHAR(15)
)

DECLARE RegionNullCursor CURSOR FOR
 SELECT CustomerID,
        CompanyName,
        Region
   FROM Customers
  WHERE Region IS NULL

OPEN RegionNullCursor
FETCH NEXT FROM RegionNullCursor INTO @CustomerId01, @CompanyName01, @Region01

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_01
    VALUES (@CustomerId01, @CompanyName01, ISNULL(@Region01, 'N/A'))

    FETCH NEXT FROM RegionNullCursor INTO @CustomerId01, @CompanyName01, @Region01
END

CLOSE RegionNullCursor
DEALLOCATE RegionNullCursor

SELECT CustomerID,
       CompanyName,
       Region
  FROM Customers
 WHERE Region IS NULL

SELECT * FROM #TEMP_01
DROP TABLE #TEMP_01

------------------------------------------------------------------------------------------------------------------------------------------
-- 02
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @CustomerId02  CHAR(5),
        @TotalOrders02 INT

DROP TABLE IF EXISTS #TEMP_02
CREATE TABLE #TEMP_02
(
    CustomerId  CHAR(5),
    TotalOrders INT
)

DECLARE TotalOrdersCursor CURSOR FOR
  SELECT CustomerID,
         COUNT(OrderID) AS TotalOrders
    FROM Orders
GROUP BY CustomerID

OPEN TotalOrdersCursor
FETCH NEXT FROM TotalOrdersCursor INTO @CustomerId02, @TotalOrders02

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_02
    VALUES (@CustomerId02, @TotalOrders02)

    FETCH NEXT FROM TotalOrdersCursor INTO @CustomerId02, @TotalOrders02
END

CLOSE TotalOrdersCursor
DEALLOCATE TotalOrdersCursor

SELECT * FROM #TEMP_02
DROP TABLE #TEMP_02

------------------------------------------------------------------------------------------------------------------------------------------
-- 03
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @OrderId03    INT,
        @CustomerId03 CHAR(5)

DROP TABLE IF EXISTS #TEMP_03
CREATE TABLE #TEMP_03
(
    OrderId       INT,
    CustomerId    CHAR(5),
    FreightStatus VARCHAR(20)
)

DECLARE FreightStatusCursor CURSOR FOR
 SELECT OrderID,
        CustomerID
   FROM Orders
  WHERE Freight > 200

OPEN FreightStatusCursor
FETCH NEXT FROM FreightStatusCursor INTO @OrderId03, @CustomerId03

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_03
    VALUES (@OrderId03, @CustomerId03, 'ALTO CUSTO')

    FETCH NEXT FROM FreightStatusCursor INTO @OrderId03, @CustomerId03
END

CLOSE FreightStatusCursor
DEALLOCATE FreightStatusCursor

SELECT * FROM #TEMP_03
DROP TABLE #TEMP_03

------------------------------------------------------------------------------------------------------------------------------------------
-- 04
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @ProductId04    INT,
        @OrderId04      INT,
        @UnitsInStock04 SMALLINT

DROP TABLE IF EXISTS #TEMP_ORDERS_04
CREATE TABLE #TEMP_ORDERS_04
(
    OrderId    INT,
    CustomerId CHAR(5)
)

DROP TABLE IF EXISTS #TEMP_OD_04
CREATE TABLE #TEMP_OD_04
(
    OrderId   INT,
    ProductId INT,
    Quantity  SMALLINT
)

DECLARE LowStockCursor CURSOR FOR
 SELECT ProductID,
        UnitsInStock
   FROM Products
  WHERE UnitsInStock < 10
    AND Discontinued = 0

SET @OrderId04 = (SELECT MAX(OrderID) FROM Orders) + 1

OPEN LowStockCursor
FETCH NEXT FROM LowStockCursor INTO @ProductId04, @UnitsInStock04

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_ORDERS_04
    VALUES (@OrderId04, 'TESTE')

    INSERT INTO #TEMP_OD_04
    VALUES (@OrderId04, @ProductId04, @UnitsInStock04)

    SET @OrderId04 = @OrderId04 + 1

    FETCH NEXT FROM LowStockCursor INTO @ProductId04, @UnitsInStock04
END

CLOSE LowStockCursor
DEALLOCATE LowStockCursor

SELECT * FROM #TEMP_ORDERS_04
SELECT * FROM #TEMP_OD_04

DROP TABLE #TEMP_ORDERS_04
DROP TABLE #TEMP_OD_04

------------------------------------------------------------------------------------------------------------------------------------------
-- 05
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @ProductName05 VARCHAR(50),
        @SupplierId05  INT,
        @UnitPrice05   MONEY

DROP TABLE IF EXISTS #TEMP_05
CREATE TABLE #TEMP_05
(
    ProductName VARCHAR(50),
    SupplierId  INT,
    UnitPrice   MONEY
)

DECLARE UpdatePriceCursor CURSOR FOR
 SELECT ProductName,
        SupplierID,
        UnitPrice
   FROM Products
  WHERE SupplierID IN (1, 2, 3)

OPEN UpdatePriceCursor
FETCH NEXT FROM UpdatePriceCursor INTO @ProductName05, @SupplierId05, @UnitPrice05

WHILE @@FETCH_STATUS = 0
BEGIN
    --Desconto diferenciado por fornecedor, que pode ser de 10%, 20% ou 30%
    INSERT INTO #TEMP_05
    VALUES (@ProductName05,
            @SupplierId05,
            CASE WHEN @SupplierId05 = 1 THEN @UnitPrice05 * 0.9
                 WHEN @SupplierId05 = 2 THEN @UnitPrice05 * 0.8
                 WHEN @SupplierId05 = 3 THEN @UnitPrice05 * 0.7
                 ELSE @UnitPrice05
                  END)

    FETCH NEXT FROM UpdatePriceCursor INTO @ProductName05, @SupplierId05, @UnitPrice05
END

CLOSE UpdatePriceCursor
DEALLOCATE UpdatePriceCursor

SELECT ProductName,
       SupplierID,
       UnitPrice
  FROM Products
 WHERE SupplierID IN (1, 2, 3)

SELECT * FROM #TEMP_05
DROP TABLE #TEMP_05

------------------------------------------------------------------------------------------------------------------------------------------
-- 06
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @FullName06  VARCHAR(50),
        @QtyOrders06 INT,
        @QtyMonths06 INT

DROP TABLE IF EXISTS #TEMP_06
CREATE TABLE #TEMP_06
(
    FullName          VARCHAR(50),
    QtyOrders         INT,
    QtyMonths         INT,
    AvgOrdersPerMonth DECIMAL(10,2)
)

DECLARE QtyOrdersEmployeeCursor CURSOR FOR
  SELECT e.FirstName + ' ' + e.LastName                               AS FullName,
         COUNT(o.OrderID)                                             AS QtyOrders,
         COUNT(DISTINCT YEAR(o.OrderDate) * 100 + MONTH(o.OrderDate)) AS QtyMonths
    FROM Employees e
    JOIN Orders    o ON o.EmployeeID = e.EmployeeID
GROUP BY e.FirstName, e.LastName

OPEN QtyOrdersEmployeeCursor
FETCH NEXT FROM QtyOrdersEmployeeCursor INTO @FullName06, @QtyOrders06, @QtyMonths06

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_06
    VALUES (@FullName06, @QtyOrders06, @QtyMonths06, @QtyOrders06 * 1.0 / @QtyMonths06)

    FETCH NEXT FROM QtyOrdersEmployeeCursor INTO @FullName06, @QtyOrders06, @QtyMonths06
END

CLOSE QtyOrdersEmployeeCursor
DEALLOCATE QtyOrdersEmployeeCursor

SELECT * FROM #TEMP_06
DROP TABLE #TEMP_06

------------------------------------------------------------------------------------------------------------------------------------------
-- 07
------------------------------------------------------------------------------------------------------------------------------------------

-- Sera adotado o intervalo entre 01/01/1997 e 31/12/1997
DECLARE @CustomerId07 CHAR(5),
        @QtyOrders07  INT

DROP TABLE IF EXISTS #TEMP_07
CREATE TABLE #TEMP_07
(
    CustomerId CHAR(5),
    QtyOrders  INT
)

DECLARE MaxOrdersCursor CURSOR FOR
  SELECT TOP 5
         CustomerID,
         COUNT(*) AS QtyOrders
    FROM Orders
   WHERE OrderDate BETWEEN '19970101' AND '19971231'
GROUP BY CustomerID
ORDER BY QtyOrders DESC

OPEN MaxOrdersCursor
FETCH NEXT FROM MaxOrdersCursor INTO @CustomerId07, @QtyOrders07

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_07
    VALUES (@CustomerId07, @QtyOrders07)

    FETCH NEXT FROM MaxOrdersCursor INTO @CustomerId07, @QtyOrders07
END

CLOSE MaxOrdersCursor
DEALLOCATE MaxOrdersCursor

SELECT * FROM #TEMP_07
DROP TABLE #TEMP_07

------------------------------------------------------------------------------------------------------------------------------------------
-- 08
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @Country08    VARCHAR(50),
        @QtyOrders08  INT,
        @TotalSales08 MONEY

DROP TABLE IF EXISTS #TEMP_08
CREATE TABLE #TEMP_08
(
    Country    VARCHAR(50),
    QtyOrders  INT,
    TotalSales MONEY
)

DECLARE TotalSalesCountryCursor CURSOR FOR
  SELECT o.ShipCountry,
         COUNT(DISTINCT o.OrderID)                           AS QtyOrders,
         SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalSales
    FROM Orders          o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY o.ShipCountry
ORDER BY o.ShipCountry

OPEN TotalSalesCountryCursor
FETCH NEXT FROM TotalSalesCountryCursor INTO @Country08, @QtyOrders08, @TotalSales08

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_08
    VALUES (@Country08, @QtyOrders08, @TotalSales08)

    FETCH NEXT FROM TotalSalesCountryCursor INTO @Country08, @QtyOrders08, @TotalSales08
END

CLOSE TotalSalesCountryCursor
DEALLOCATE TotalSalesCountryCursor

SELECT * FROM #TEMP_08
DROP TABLE #TEMP_08

------------------------------------------------------------------------------------------------------------------------------------------
-- 09
------------------------------------------------------------------------------------------------------------------------------------------

-- A PK de Customers impede duplicatas reais, e a duplicidade e simulada em uma temp
DECLARE @CustomerId09 CHAR(5),
        @FirstRowId09 INT

DROP TABLE IF EXISTS #TEMP_09
CREATE TABLE #TEMP_09
(
    RowId       INT IDENTITY(1,1),
    CustomerId  CHAR(5),
    CompanyName VARCHAR(40),
    City        VARCHAR(15),
    Country     VARCHAR(15)
)

INSERT INTO #TEMP_09 ( CustomerId, CompanyName, City, Country )
SELECT CustomerID,
       CompanyName,
       City,
       Country
  FROM Customers

-- Duplicatas de teste
INSERT INTO #TEMP_09 ( CustomerId, CompanyName, City, Country )
SELECT CustomerID,
       CompanyName,
       City,
       Country
  FROM Customers
 WHERE CustomerID IN ('ALFKI', 'ANATR')

DECLARE DuplicateCustomerCursor CURSOR FOR
  SELECT CustomerId,
         MIN(RowId) AS FirstRowId
    FROM #TEMP_09
GROUP BY CustomerId
  HAVING COUNT(*) > 1

OPEN DuplicateCustomerCursor
FETCH NEXT FROM DuplicateCustomerCursor INTO @CustomerId09, @FirstRowId09

WHILE @@FETCH_STATUS = 0
BEGIN
    --## Mantem o registro mais antigo e exclui os demais
    DELETE FROM #TEMP_09
          WHERE CustomerId = @CustomerId09
            AND RowId > @FirstRowId09

    FETCH NEXT FROM DuplicateCustomerCursor INTO @CustomerId09, @FirstRowId09
END

CLOSE DuplicateCustomerCursor
DEALLOCATE DuplicateCustomerCursor

--Validacao
  SELECT CustomerId,
         COUNT(*) AS QtyDuplicate
    FROM #TEMP_09
GROUP BY CustomerId
  HAVING COUNT(*) > 1

SELECT * FROM #TEMP_09 WHERE CustomerId IN ('ALFKI', 'ANATR')
DROP TABLE #TEMP_09

------------------------------------------------------------------------------------------------------------------------------------------
-- 10
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @CustomerId10    VARCHAR(50),
        @DelayedOrders10 INT,
        @RefDate10       DATETIME = (SELECT MAX(OrderDate) FROM Orders)

DECLARE DelayedOrdersCursor CURSOR FOR
  SELECT c.CompanyName,
         COUNT(*) AS DelayedOrders
    FROM Orders    o
    JOIN Customers c ON c.CustomerID = o.CustomerID
   WHERE o.RequiredDate BETWEEN DATEADD( DAY, -7, @RefDate10 ) 
     AND @RefDate10
     AND (o.ShippedDate > o.RequiredDate
          OR o.ShippedDate IS NULL)
GROUP BY c.CompanyName

OPEN DelayedOrdersCursor
FETCH NEXT FROM DelayedOrdersCursor INTO @CustomerId10, @DelayedOrders10

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'O cliente ' + @CustomerId10 + ' possui ' + CAST( @DelayedOrders10 AS VARCHAR(3) ) + ' pedido(s) atrasado(s)!'

    FETCH NEXT FROM DelayedOrdersCursor INTO @CustomerId10, @DelayedOrders10
END

CLOSE DelayedOrdersCursor
DEALLOCATE DelayedOrdersCursor

------------------------------------------------------------------------------------------------------------------------------------------
-- 11
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_11
CREATE TABLE #TEMP_11
(
    LogDate   DATETIME,
    OrdersXml XML
)

INSERT INTO #TEMP_11 ( LogDate, OrdersXml )
SELECT GETDATE(),
       (      SELECT Orders.OrderID,
                     Orders.CustomerID,
                     Orders.OrderDate,
                     (      SELECT [Order Details].ProductID,
                                   [Order Details].UnitPrice,
                                   [Order Details].Quantity
                              FROM [Order Details]
                             WHERE [Order Details].OrderID = Orders.OrderID
                      FOR XML PATH ('OrderDetail'), TYPE ) AS OrderDetails
                FROM Orders
        FOR XML PATH ('Order'), ROOT('Orders'), TYPE )

SELECT * FROM #TEMP_11
DROP TABLE #TEMP_11

------------------------------------------------------------------------------------------------------------------------------------------
-- 12
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @XMLData12 XML = 
        '<Orders>
            <Order>
                <OrderID>10248</OrderID>
                <CustomerID>VINET</CustomerID>
                <OrderDate>1996-07-04</OrderDate>
            </Order>
            <Order>
                <OrderID>10249</OrderID>
                <CustomerID>TOMSP</CustomerID>
                <OrderDate>1996-07-05</OrderDate>
            </Order>
        </Orders>'

SELECT T.C.value('(OrderID)[1]', 'INT')            AS OrderID,
       T.C.value('(CustomerID)[1]', 'NVARCHAR(5)') AS CustomerID,
       T.C.value('(OrderDate)[1]', 'DATE')         AS OrderDate
  FROM @XMLData12.nodes('/Orders/Order') AS T(C)

------------------------------------------------------------------------------------------------------------------------------------------
-- 13
------------------------------------------------------------------------------------------------------------------------------------------

-- Fornecedores para cada produto
      SELECT Products.ProductID,
             Products.ProductName,
             Products.SupplierID,
             (       SELECT Suppliers.CompanyName,
                            Suppliers.Phone,
                            Suppliers.City,
                            Suppliers.Country
                       FROM Suppliers
                      WHERE Suppliers.SupplierID = Products.SupplierID
               FOR XML PATH ('Supplier'), TYPE ) AS Suppliers
        FROM Products
FOR XML PATH ('Product'), ROOT ('Products')

--## Produtos para cada fornecedor
      SELECT Suppliers.SupplierID,
             Suppliers.CompanyName,
             (      SELECT Products.ProductID,
                           Products.ProductName,
                           Products.UnitPrice
                      FROM Products
                     WHERE Products.SupplierID = Suppliers.SupplierID
              FOR XML PATH ('Product'), TYPE ) AS Products
        FROM Suppliers
    ORDER BY Suppliers.SupplierID
FOR XML PATH ('Supplier'), ROOT ('Suppliers')

------------------------------------------------------------------------------------------------------------------------------------------
-- 14
------------------------------------------------------------------------------------------------------------------------------------------

--Sera usada uma tabela temporaria, ao inves de criar uma procedure
DROP TABLE IF EXISTS #TEMP_14
CREATE TABLE #TEMP_14
(
    CustomerId  CHAR(5),
    CompanyName VARCHAR(50),
    City        VARCHAR(30),
    Country     VARCHAR(30)
)

DECLARE @XMLData14 XML =
        '<Customers>
            <Customer>
                <CustomerId>TST01</CustomerId>
                <CompanyName>Empresa Alfa</CompanyName>
                <City>BRASILIA</City>
                <Country>Brazil</Country>
            </Customer>
            <Customer>
                <CustomerId>TST02</CustomerId>
                <CompanyName>Empresa Beta</CompanyName>
                <City>SAO PAULO</City>
                <Country>Brazil</Country>
            </Customer>
         </Customers>'

INSERT INTO #TEMP_14 ( CustomerId, CompanyName, City, Country )
SELECT T.C.value('(CustomerId)[1]' , 'CHAR(5)'    ) AS CustomerId,
       T.C.value('(CompanyName)[1]', 'VARCHAR(50)') AS CompanyName,
       T.C.value('(City)[1]'       , 'VARCHAR(30)') AS City,
       T.C.value('(Country)[1]'    , 'VARCHAR(30)') AS Country
  FROM @XMLData14.nodes('/Customers/Customer') AS T(C)

SELECT * FROM #TEMP_14
DROP TABLE #TEMP_14

------------------------------------------------------------------------------------------------------------------------------------------
-- 15
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @XMLData15 XML =
        '<Orders>
            <Order>
                <OrderID>11008</OrderID>
                <CustomerID>ERNSH</CustomerID>
                <OrderDate>1998-04-08</OrderDate>
            </Order>
            <Order>
                <OrderID>10926</OrderID>
                <CustomerID>ANATR</CustomerID>
                <OrderDate>1998-03-04</OrderDate>
            </Order>
            <Order>
                <OrderID>11045</OrderID>
                <CustomerID>BOTTM</CustomerID>
                <OrderDate>1998-04-23</OrderDate>
            </Order>
            <Order>
                <OrderID>11077</OrderID>
                <CustomerID>RATTC</CustomerID>
                <OrderDate>1998-05-06</OrderDate>
            </Order>
         </Orders>'

DECLARE @LastDate15  DATE,
        @BeginDate15 VARCHAR(10)

SELECT @LastDate15 = MAX( T.C.value( '(OrderDate)[1]', 'DATE' ) )
  FROM @XMLData15.nodes('/Orders/Order') AS T(C)

SET @BeginDate15 = CONVERT( VARCHAR(10), DATEADD( MONTH, -1, @LastDate15 ), 23 )

SELECT T.C.value('(OrderID)[1]'   , 'INT'    ) AS OrderID,
       T.C.value('(CustomerID)[1]', 'CHAR(5)') AS CustomerID,
       T.C.value('(OrderDate)[1]' , 'DATE'   ) AS OrderDate
  FROM @XMLData15.nodes('/Orders/Order[OrderDate >= sql:variable("@BeginDate15")]') AS T(C)

------------------------------------------------------------------------------------------------------------------------------------------
-- 16
------------------------------------------------------------------------------------------------------------------------------------------

-- Para nao alterar a base, a atualizacao e feita em uma temporaria
DROP TABLE IF EXISTS #TEMP_16
CREATE TABLE #TEMP_16
(
    EmployeeId INT,
    FullName   VARCHAR(50),
    OldTitle   VARCHAR(30),
    NewTitle   VARCHAR(30)
)

INSERT INTO #TEMP_16
SELECT EmployeeID,
       FirstName + ' ' + LastName,
       Title,
       Title
  FROM Employees

DECLARE @XMLData16 XML =
    '<Employees>
        <Employee>
            <EmployeeID>1</EmployeeID>
            <Title>Manager</Title>
        </Employee>
        <Employee>
            <EmployeeID>2</EmployeeID>
            <Title>Senior Developer</Title>
        </Employee>
    </Employees>';

UPDATE e
   SET e.NewTitle = T.C.value('(Title)[1]', 'VARCHAR(30)')
  FROM #TEMP_16 e
  JOIN @XMLData16.nodes('/Employees/Employee') AS T(C) ON e.EmployeeId = T.C.value('(EmployeeID)[1]', 'INT')

SELECT * FROM #TEMP_16
DROP TABLE #TEMP_16

------------------------------------------------------------------------------------------------------------------------------------------
-- 17
------------------------------------------------------------------------------------------------------------------------------------------

      SELECT o.OrderID,
             o.CustomerID,
             o.Freight,
             (        SELECT od.ProductID,
                             p.ProductName,
                             od.Quantity,
                             od.UnitPrice,
                             od.Discount
                        FROM [Order Details] od
                        JOIN Products        p  ON p.ProductID = od.ProductID
                       WHERE od.OrderID = o.OrderID
                FOR XML PATH ('Products'), TYPE ) AS Products
        FROM Orders o
FOR XML PATH ('Order'), ROOT ('Orders')

------------------------------------------------------------------------------------------------------------------------------------------
-- 18
------------------------------------------------------------------------------------------------------------------------------------------

      SELECT c1.Country,
             (        SELECT c2.CustomerID,
                             c2.CompanyName
                        FROM Customers c2
                       WHERE c2.Country = c1.Country
                FOR XML PATH ('Customers'), TYPE) AS Customers
        FROM Customers c1
    GROUP BY c1.Country
    ORDER BY c1.Country ASC
FOR XML PATH ('Country'), ROOT ('Countries')

------------------------------------------------------------------------------------------------------------------------------------------
-- 19
------------------------------------------------------------------------------------------------------------------------------------------

-- Usarei uma tabela temporaria
DROP TABLE IF EXISTS #TEMP_19
CREATE TABLE #TEMP_19
(
    ProductId INT,
    ProductName VARCHAR(50)
)

DECLARE @XMLData19 XML =
        '<Products>
            <Product>
                <ProductId>80</ProductId>
                <ProductName>PICANHA MATURADA</ProductName>
            </Product>
            <Product>
                <ProductId>81</ProductId>
                <ProductName>PE DE FRANGO</ProductName>
            </Product>
         </Products>'

INSERT INTO #TEMP_19 ( ProductId, ProductName )
SELECT T.C.value('(ProductId)[1]'  , 'INT'        ) AS ProductId,
       T.C.value('(ProductName)[1]', 'VARCHAR(50)') AS ProductName
  FROM @XMLData19.nodes('/Products/Product') AS T(C)

SELECT * FROM #TEMP_19
DROP TABLE #TEMP_19

------------------------------------------------------------------------------------------------------------------------------------------
-- 20
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @XMLData20 XML =
    '<Discounts>
        <Item>
            <OrderID>10248</OrderID>
            <ProductID>11</ProductID>
            <Discount>10.50</Discount>
        </Item>
        <Item>
            <OrderID>10248</OrderID>
            <ProductID>42</ProductID>
            <Discount>4.25</Discount>
        </Item>
        <Item>
            <OrderID>10249</OrderID>
            <ProductID>14</ProductID>
            <Discount>5.00</Discount>
        </Item>
    </Discounts>'

;WITH Discounts20CTE AS
(
    SELECT T.C.value('(OrderID)[1]' , 'INT'  ) AS OrderID,
           T.C.value('(Discount)[1]', 'MONEY') AS Discount
      FROM @XMLData20.nodes('/Discounts/Item') AS T(C)
)
  SELECT OrderID,
         COUNT(*)      AS QtyItens,
         SUM(Discount) AS TotalDiscount
    FROM Discounts20CTE
GROUP BY OrderID

------------------------------------------------------------------------------------------------------------------------------------------
-- 21
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @JsonData21 NVARCHAR(MAX)

DROP TABLE IF EXISTS #TEMP_21
CREATE TABLE #TEMP_21
(
    JsonData NVARCHAR(MAX)
)

SET @JsonData21 = (SELECT CustomerID,
                          CompanyName,
                          Phone,
                          City, 
                          Country
                     FROM Customers
                      FOR JSON PATH)

INSERT INTO #TEMP_21
SELECT @JsonData21

SELECT * FROM #TEMP_21
DROP TABLE #TEMP_21

------------------------------------------------------------------------------------------------------------------------------------------
-- 22
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @CategoryId22 INT,
        @Adjustment22 FLOAT

DROP TABLE IF EXISTS #TEMP_22
CREATE TABLE #TEMP_22
(
    CategoryId    INT,
    ProductName   VARCHAR(50),
    Price         MONEY,
    PriceAdjusted MONEY
)

INSERT INTO #TEMP_22
SELECT CategoryID,
       ProductName,
       UnitPrice,
       UnitPrice
  FROM Products
 WHERE CategoryID IN (1, 2)

DECLARE @PriceAdjustments NVARCHAR(MAX) =
    '[
        {"CategoryID": 1, "Adjustment": 1.1},
        {"CategoryID": 2, "Adjustment": 0.9}
    ]'

DECLARE AdjustmentCursor CURSOR FOR
 SELECT CategoryID,
        Adjustment
   FROM OPENJSON(@PriceAdjustments)
   WITH (CategoryID INT   '$.CategoryID',
         Adjustment FLOAT '$.Adjustment');

OPEN AdjustmentCursor
FETCH NEXT FROM AdjustmentCursor INTO @CategoryId22, @Adjustment22

WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE t
       SET t.PriceAdjusted = t.Price * @Adjustment22
      FROM #TEMP_22 t
     WHERE t.CategoryId = @CategoryId22

     FETCH NEXT FROM AdjustmentCursor INTO @CategoryId22, @Adjustment22
END

CLOSE AdjustmentCursor
DEALLOCATE AdjustmentCursor

SELECT * FROM #TEMP_22
DROP TABLE #TEMP_22

------------------------------------------------------------------------------------------------------------------------------------------
-- 23
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @JsonData23 NVARCHAR(MAX)

DROP TABLE IF EXISTS #TEMP_23
CREATE TABLE #TEMP_23
(
    JsonData NVARCHAR(MAX)
)

SET @JsonData23 =
(        SELECT TOP 10
                o.OrderID,
                o.CustomerID,
                o.OrderDate,
                (        SELECT od.ProductID,
                                 p.ProductName,
                                od.Quantity,
                                od.UnitPrice
                           FROM [Order Details] od
                           JOIN Products        p  ON p.ProductID = od.ProductID
                          WHERE od.OrderID = o.OrderID
                  FOR JSON PATH
                ) AS OrderDetails,
                s.CompanyName
           FROM Orders   o
           JOIN Shippers s ON s.ShipperID = o.ShipVia
       ORDER BY o.OrderID
  FOR JSON PATH
)

INSERT INTO #TEMP_23
SELECT @JsonData23

SELECT * FROM #TEMP_23
DROP TABLE #TEMP_23

------------------------------------------------------------------------------------------------------------------------------------------
-- 24
------------------------------------------------------------------------------------------------------------------------------------------

--Para facilitar, ao inves de procedure, usarei uma temporaria
DROP TABLE IF EXISTS #TEMP_24
CREATE TABLE #TEMP_24
(
    LastName  VARCHAR(50),
    FirstName VARCHAR(50),
    Title     VARCHAR(20),
    Country   VARCHAR(20)
)

DECLARE @JsonData24 NVARCHAR(MAX) =
    '[
        {"LastName": "Smith", "FirstName": "John", "Title": "Manager", "Country": "USA"},
        {"LastName": "Doe", "FirstName": "Jane", "Title": "Developer", "Country": "UK"}
     ]'

INSERT INTO #TEMP_24 ( LastName, FirstName, Title, Country )
SELECT LastName,
       FirstName,
       Title,
       Country
  FROM OPENJSON ( @JsonData24 )
  WITH (LastName  VARCHAR(50) '$.LastName',
        FirstName VARCHAR(50) '$.FirstName',
        Title     VARCHAR(20) '$.Title',
        Country   VARCHAR(20) '$.Country');

SELECT * FROM #TEMP_24
DROP TABLE #TEMP_24

------------------------------------------------------------------------------------------------------------------------------------------
-- 25
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_25
CREATE TABLE #TEMP_25
(
    CustomerId   CHAR(5),
    OrderHistory NVARCHAR(MAX),
    LogDate      DATETIME
)

INSERT INTO #TEMP_25 ( CustomerId, OrderHistory, LogDate )
SELECT Customers.CustomerID,
       (       SELECT OrderID,
                      OrderDate,
                      Freight
                 FROM Orders
                WHERE Orders.CustomerID = Customers.CustomerID
             ORDER BY OrderID
        FOR JSON AUTO),
       GETDATE()
  FROM Customers

SELECT * FROM #TEMP_25
DROP TABLE #TEMP_25

------------------------------------------------------------------------------------------------------------------------------------------
-- 26
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @JsonData26 NVARCHAR(MAX) =
    '[
        {"CustomerID": "ALFKI", "Email": 1, "Phone": 0, "Mail": 1},
        {"CustomerID": "ANATR", "Email": 1, "Phone": 1, "Mail": 0},
        {"CustomerID": "ANTON", "Email": 0, "Phone": 1, "Mail": 0}
     ]'

DROP TABLE IF EXISTS #TEMP_26
CREATE TABLE #TEMP_26
(
    CustomerId   CHAR(5),
    CompanyName  VARCHAR(40),
    PrefersEmail BIT,
    PrefersPhone BIT,
    PrefersMail  BIT
)

INSERT INTO #TEMP_26 (CustomerId, CompanyName, PrefersEmail, PrefersPhone, PrefersMail)
SELECT c.CustomerID,
       c.CompanyName,
       p.Email,
       p.Phone,
       p.Mail
  FROM OPENJSON(@JsonData26)
  WITH (CustomerID CHAR(5) '$.CustomerID',
        Email      BIT     '$.Email',
        Phone      BIT     '$.Phone',
        Mail       BIT     '$.Mail') p
  JOIN Customers c ON c.CustomerID = p.CustomerID

SELECT *
  FROM #TEMP_26
 WHERE PrefersEmail = 1

DROP TABLE #TEMP_26

------------------------------------------------------------------------------------------------------------------------------------------
-- 27
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @JsonData27 NVARCHAR(MAX)

DROP TABLE IF EXISTS #TEMP_27
CREATE TABLE #TEMP_27
(
    SentAt   DATETIME,
    JsonData NVARCHAR(MAX)
)

SET @JsonData27 =
(        SELECT s.SupplierID,
                s.CompanyName,
                s.Country,
                (        SELECT p.ProductID,
                                p.ProductName,
                                p.UnitPrice,
                                p.UnitsInStock
                           FROM Products p
                          WHERE p.SupplierID = s.SupplierID
                  FOR JSON PATH) AS Products
           FROM Suppliers s
       ORDER BY s.SupplierID
  FOR JSON PATH)

INSERT INTO #TEMP_27 (SentAt, JsonData)
VALUES (GETDATE(), @JsonData27)

SELECT * FROM #TEMP_27
DROP TABLE #TEMP_27

------------------------------------------------------------------------------------------------------------------------------------------
-- 28
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @JsonData28 NVARCHAR(MAX) =
    '{
        "OrderID": 10248,
        "Items": [
            {"ProductID": 11, "UnitPrice": 14.00, "Quantity": 12, "Discount": 0.00},
            {"ProductID": 42, "UnitPrice": 9.80,  "Quantity": 10, "Discount": 0.00},
            {"ProductID": 72, "UnitPrice": 34.80, "Quantity": 5,  "Discount": 0.05}
        ]
     }'

DECLARE @OrderId28 INT = JSON_VALUE(@JsonData28, '$.OrderID')

SELECT @OrderId28                                                              AS OrderID,
       CAST(SUM(i.UnitPrice * i.Quantity * (1 - i.Discount)) AS NUMERIC(10,2)) AS OrderTotal
  FROM OPENJSON(@JsonData28, '$.Items')
  WITH (ProductID INT   '$.ProductID',
        UnitPrice MONEY '$.UnitPrice',
        Quantity  INT   '$.Quantity',
        Discount  FLOAT '$.Discount') i

------------------------------------------------------------------------------------------------------------------------------------------
-- 29
------------------------------------------------------------------------------------------------------------------------------------------

-- No lugar da funcao, a validacao e a carga ficam em temporarias
DROP TABLE IF EXISTS #TEMP_ORDERS_29
CREATE TABLE #TEMP_ORDERS_29
(
    OrderId    INT,
    CustomerId CHAR(5),
    OrderDate  DATE
)

DROP TABLE IF EXISTS #TEMP_OD_29
CREATE TABLE #TEMP_OD_29
(
    OrderId   INT,
    ProductId INT,
    UnitPrice MONEY,
    Quantity  SMALLINT
)

DROP TABLE IF EXISTS #TEMP_ERROS_29
CREATE TABLE #TEMP_ERROS_29
(
    OrderId   INT,
    ProductId INT,
    Motivo    VARCHAR(80)
)

DECLARE @JsonData29 NVARCHAR(MAX) =
    '[
        {
            "OrderID": 99001,
            "CustomerID": "ALFKI",
            "OrderDate": "1998-05-01",
            "Items": [
                {"ProductID": 1, "UnitPrice": 18.00, "Quantity": 5},
                {"ProductID": 999, "UnitPrice": 10.00, "Quantity": 2}
            ]
        },
        {
            "OrderID": 99002,
            "CustomerID": "XXXXX",
            "OrderDate": "1998-05-02",
            "Items": [
                {"ProductID": 2, "UnitPrice": 19.00, "Quantity": 3}
            ]
        }
     ]'

DECLARE @OrderId29    INT,
        @CustomerId29 CHAR(5),
        @OrderDate29  DATE,
        @Items29      NVARCHAR(MAX)

DECLARE JsonOrdersCursor CURSOR FOR
 SELECT OrderID,
        CustomerID,
        OrderDate,
        Items
   FROM OPENJSON(@JsonData29)
   WITH (OrderID    INT           '$.OrderID',
         CustomerID CHAR(5)       '$.CustomerID',
         OrderDate  DATE          '$.OrderDate',
         Items      NVARCHAR(MAX) '$.Items' AS JSON)

OPEN JsonOrdersCursor
FETCH NEXT FROM JsonOrdersCursor INTO @OrderId29, @CustomerId29, @OrderDate29, @Items29

WHILE @@FETCH_STATUS = 0
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Customers WHERE CustomerID = @CustomerId29)
        INSERT INTO #TEMP_ERROS_29 (OrderId, ProductId, Motivo)
        VALUES (@OrderId29, NULL, 'Cliente inexistente')
    ELSE
    BEGIN
        INSERT INTO #TEMP_ORDERS_29 (OrderId, CustomerId, OrderDate)
        VALUES (@OrderId29, @CustomerId29, @OrderDate29)

        INSERT INTO #TEMP_OD_29 (OrderId, ProductId, UnitPrice, Quantity)
        SELECT @OrderId29,
               i.ProductID,
               i.UnitPrice,
               i.Quantity
          FROM OPENJSON(@Items29)
          WITH (ProductID INT   '$.ProductID',
                UnitPrice MONEY '$.UnitPrice',
                Quantity  INT   '$.Quantity') i
          JOIN Products p ON p.ProductID = i.ProductID

        INSERT INTO #TEMP_ERROS_29 (OrderId, ProductId, Motivo)
           SELECT @OrderId29,
                  i.ProductID,
                  'Produto inexistente'
             FROM OPENJSON(@Items29)
             WITH (ProductID INT '$.ProductID') i
        LEFT JOIN Products p ON p.ProductID = i.ProductID
            WHERE p.ProductID IS NULL
    END

    FETCH NEXT FROM JsonOrdersCursor INTO @OrderId29, @CustomerId29, @OrderDate29, @Items29
END

CLOSE JsonOrdersCursor
DEALLOCATE JsonOrdersCursor

SELECT * FROM #TEMP_ORDERS_29
SELECT * FROM #TEMP_OD_29
SELECT * FROM #TEMP_ERROS_29

DROP TABLE #TEMP_OD_29
DROP TABLE #TEMP_ORDERS_29
DROP TABLE #TEMP_ERROS_29

------------------------------------------------------------------------------------------------------------------------------------------
-- 30
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @JsonData30 NVARCHAR(MAX) =
    '[
        {"CustomerID": "ALFKI", "ContactType": "Email", "ContactDate": "1998-04-01"},
        {"CustomerID": "ALFKI", "ContactType": "Phone", "ContactDate": "1998-04-15"},
        {"CustomerID": "ALFKI", "ContactType": "Email", "ContactDate": "1998-05-01"},
        {"CustomerID": "ANATR", "ContactType": "Phone", "ContactDate": "1998-03-20"},
        {"CustomerID": "ANATR", "ContactType": "Phone", "ContactDate": "1998-04-20"}
     ]'

DROP TABLE IF EXISTS #TEMP_30
CREATE TABLE #TEMP_30
(
    CustomerId  CHAR(5),
    ContactType VARCHAR(20),
    QtyContacts INT
)

INSERT INTO #TEMP_30 (CustomerId, ContactType, QtyContacts)
SELECT CustomerID,
       ContactType,
       COUNT(*) AS QtyContacts
  FROM OPENJSON(@JsonData30)
  WITH (CustomerID  CHAR(5)     '$.CustomerID',
        ContactType VARCHAR(20) '$.ContactType',
        ContactDate DATE        '$.ContactDate')
 GROUP BY CustomerID, ContactType

SELECT * FROM #TEMP_30 ORDER BY CustomerId, ContactType
DROP TABLE #TEMP_30

------------------------------------------------------------------------------------------------------------------------------------------
-- 31
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @CategoryId31 INT,
        @Factor31     DECIMAL(10, 4)

DROP TABLE IF EXISTS #TEMP_31
CREATE TABLE #TEMP_31
(
    ProductId INT,
    CategoryId INT,
    OldPrice  MONEY,
    NewPrice  MONEY
)

DECLARE @XmlData31 XML =
    '<Adjustments>
        <Category CategoryID="1" Factor="1.10"/>
        <Category CategoryID="2" Factor="0.95"/>
     </Adjustments>'

INSERT INTO #TEMP_31 (ProductId, CategoryId, OldPrice, NewPrice)
SELECT ProductID,
       CategoryID,
       UnitPrice,
       UnitPrice
  FROM Products
 WHERE CategoryID IN (1, 2)

DECLARE PriceXmlCursor CURSOR FOR
 SELECT T.C.value('@CategoryID', 'INT'),
        T.C.value('@Factor', 'DECIMAL(10, 4)')
   FROM @XmlData31.nodes('/Adjustments/Category') AS T(C)

OPEN PriceXmlCursor
FETCH NEXT FROM PriceXmlCursor INTO @CategoryId31, @Factor31

WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE #TEMP_31
       SET NewPrice = OldPrice * @Factor31
     WHERE CategoryId = @CategoryId31

    FETCH NEXT FROM PriceXmlCursor INTO @CategoryId31, @Factor31
END

CLOSE PriceXmlCursor
DEALLOCATE PriceXmlCursor

-- Historico da alteracao em JSON
SELECT (SELECT ProductId,
               CategoryId,
               OldPrice,
               NewPrice
          FROM #TEMP_31
           FOR JSON PATH) AS HistoryJson

-- Historico da alteracao em query
SELECT * FROM #TEMP_31
DROP TABLE #TEMP_31

------------------------------------------------------------------------------------------------------------------------------------------
-- 32
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_32
CREATE TABLE #TEMP_32
(
    OrdersXml  XML,
    OrdersJson NVARCHAR(MAX)
)

-- Aqui eu fiz um TOP 5 pedidos apenas para mostrar que o XML e o JSON legiveis
-- Senao ia virar um trambolho de dados...
INSERT INTO #TEMP_32 (OrdersXml, OrdersJson)
SELECT (        SELECT TOP 5
                       o.OrderID,
                       o.CustomerID,
                       o.OrderDate,
                       (        SELECT od.ProductID,
                                       od.Quantity,
                                       od.UnitPrice
                                  FROM [Order Details] od
                                 WHERE od.OrderID = o.OrderID
                          FOR XML PATH('OrderDetail'), TYPE) AS OrderDetails
                  FROM Orders o
              ORDER BY o.OrderID
           FOR XML PATH('Order'), ROOT('Orders'), TYPE),
       (        SELECT TOP 5
                       o.OrderID,
                       o.CustomerID,
                       o.OrderDate,
                       (        SELECT od.ProductID,
                                       od.Quantity,
                                       od.UnitPrice
                                  FROM [Order Details] od
                                 WHERE od.OrderID = o.OrderID
                          FOR JSON PATH) AS OrderDetails
                  FROM Orders o
              ORDER BY o.OrderID
           FOR JSON PATH)

SELECT * FROM #TEMP_32
DROP TABLE #TEMP_32

------------------------------------------------------------------------------------------------------------------------------------------
-- 33
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @CustomerId33 CHAR(5),
        @QtyEmail33   INT,
        @QtyPhone33   INT

DROP TABLE IF EXISTS #TEMP_33
CREATE TABLE #TEMP_33
(
    CustomerId CHAR(5),
    QtyEmail   INT,
    QtyPhone   INT
)

DECLARE @JsonData33 NVARCHAR(MAX) =
    '[
        {"CustomerID": "ALFKI", "ContactType": "Email"},
        {"CustomerID": "ALFKI", "ContactType": "Phone"},
        {"CustomerID": "ALFKI", "ContactType": "Email"},
        {"CustomerID": "ANATR", "ContactType": "Phone"}
     ]'

DECLARE InteractionCursor CURSOR FOR
 SELECT DISTINCT CustomerID
   FROM OPENJSON(@JsonData33)
   WITH (CustomerID CHAR(5) '$.CustomerID')

OPEN InteractionCursor
FETCH NEXT FROM InteractionCursor INTO @CustomerId33

WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @QtyEmail33 = COUNT(*)
      FROM OPENJSON(@JsonData33)
      WITH (CustomerID  CHAR(5)     '$.CustomerID',
            ContactType VARCHAR(20) '$.ContactType')
     WHERE CustomerID = @CustomerId33
       AND ContactType = 'Email'

    SELECT @QtyPhone33 = COUNT(*)
      FROM OPENJSON(@JsonData33)
      WITH (CustomerID  CHAR(5)     '$.CustomerID',
            ContactType VARCHAR(20) '$.ContactType')
     WHERE CustomerID = @CustomerId33
       AND ContactType = 'Phone'

    INSERT INTO #TEMP_33 (CustomerId, QtyEmail, QtyPhone)
    VALUES (@CustomerId33, @QtyEmail33, @QtyPhone33)

    FETCH NEXT FROM InteractionCursor INTO @CustomerId33
END

CLOSE InteractionCursor
DEALLOCATE InteractionCursor

      SELECT CustomerId,
             QtyEmail,
             QtyPhone
        FROM #TEMP_33
FOR XML PATH('Customer'), ROOT('InteractionReport')

SELECT * FROM #TEMP_33
DROP TABLE #TEMP_33

------------------------------------------------------------------------------------------------------------------------------------------
-- 34
------------------------------------------------------------------------------------------------------------------------------------------

-- No lugar da procedure, coloquei um XML de entrada, carga em tabela temporaria e resposta de erros em JSON
DROP TABLE IF EXISTS #TEMP_ORDERS_34
CREATE TABLE #TEMP_ORDERS_34
(
    OrderId    INT,
    CustomerId CHAR(5)
)

DROP TABLE IF EXISTS #TEMP_OD_34
CREATE TABLE #TEMP_OD_34
(
    OrderId   INT,
    ProductId INT,
    Quantity  SMALLINT
)

DROP TABLE IF EXISTS #TEMP_ERROS_34
CREATE TABLE #TEMP_ERROS_34
(
    ErrorJson NVARCHAR(MAX)
)

DECLARE @XmlData34 XML =
    '<Orders>
        <Order OrderID="99101" CustomerID="VINET">
            <Item ProductID="11" Quantity="5"/>
            <Item ProductID="9999" Quantity="1"/>
        </Order>
        <Order OrderID="99102" CustomerID="ZZZZZ">
            <Item ProductID="14" Quantity="2"/>
        </Order>
     </Orders>'

DECLARE @OrderId34    INT,
        @CustomerId34 CHAR(5),
        @Items34      XML

DECLARE XmlOrderCursor CURSOR FOR
 SELECT T.C.value('@OrderID', 'INT'),
        T.C.value('@CustomerID', 'CHAR(5)'),
        T.C.query('Item')
   FROM @XmlData34.nodes('/Orders/Order') AS T(C)

OPEN XmlOrderCursor
FETCH NEXT FROM XmlOrderCursor INTO @OrderId34, @CustomerId34, @Items34

WHILE @@FETCH_STATUS = 0
BEGIN
    -- WITHOUT_ARRAY_WRAPPER tira os colchetes que o FOR JSON PATH coloca em volta do resultado
    IF NOT EXISTS (SELECT 1 FROM Customers WHERE CustomerID = @CustomerId34)
        INSERT INTO #TEMP_ERROS_34 (ErrorJson)
        VALUES ((SELECT @OrderId34            AS OrderID,
                        @CustomerId34         AS CustomerID,
                        'Cliente inexistente' AS Motivo
                  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))
    ELSE
    BEGIN
        INSERT INTO #TEMP_ORDERS_34 (OrderId, CustomerId)
        VALUES (@OrderId34, @CustomerId34)

        INSERT INTO #TEMP_OD_34 (OrderId, ProductId, Quantity)
        SELECT @OrderId34,
               I.N.value('@ProductID', 'INT'),
               I.N.value('@Quantity', 'SMALLINT')
          FROM @Items34.nodes('/Item') AS I(N)
          JOIN Products p ON p.ProductID = I.N.value('@ProductID', 'INT')

        INSERT INTO #TEMP_ERROS_34 (ErrorJson)
        SELECT (SELECT @OrderId34                     AS OrderID,
                       I.N.value('@ProductID', 'INT') AS ProductID,
                       'Produto inexistente'          AS Motivo
                  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
          FROM @Items34.nodes('/Item') AS I(N)
         WHERE NOT EXISTS (SELECT 1
                             FROM Products p
                            WHERE p.ProductID = I.N.value('@ProductID', 'INT'))
    END

    FETCH NEXT FROM XmlOrderCursor INTO @OrderId34, @CustomerId34, @Items34
END

CLOSE XmlOrderCursor
DEALLOCATE XmlOrderCursor

SELECT * FROM #TEMP_ORDERS_34
SELECT * FROM #TEMP_OD_34
SELECT * FROM #TEMP_ERROS_34

DROP TABLE #TEMP_OD_34
DROP TABLE #TEMP_ORDERS_34
DROP TABLE #TEMP_ERROS_34

------------------------------------------------------------------------------------------------------------------------------------------
-- 35
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @ProductId35 INT,
        @Delta35     SMALLINT,
        @Before35    SMALLINT

DROP TABLE IF EXISTS #TEMP_STOCK_35
CREATE TABLE #TEMP_STOCK_35
(
    ProductId    INT,
    UnitsInStock SMALLINT
)

DROP TABLE IF EXISTS #TEMP_LOG_35
CREATE TABLE #TEMP_LOG_35
(
    AdjustmentJson NVARCHAR(MAX)
)

INSERT INTO #TEMP_STOCK_35 (ProductId, UnitsInStock)
SELECT ProductID,
       UnitsInStock
  FROM Products
 WHERE ProductID IN (1, 2, 3)

DECLARE @XmlData35 XML =
    '<StockChanges>
        <Product ProductID="1" Delta="10"/>
        <Product ProductID="2" Delta="-3"/>
        <Product ProductID="3" Delta="5"/>
        <Product ProductID="999" Delta="4"/>
        <Product ProductID="2" Delta="-50"/>
     </StockChanges>'

DECLARE StockXmlCursor CURSOR FOR
 SELECT T.C.value('@ProductID', 'INT'),
        T.C.value('@Delta', 'SMALLINT')
   FROM @XmlData35.nodes('/StockChanges/Product') AS T(C)

OPEN StockXmlCursor
FETCH NEXT FROM StockXmlCursor INTO @ProductId35, @Delta35

WHILE @@FETCH_STATUS = 0
BEGIN
    -- SET com subquery zera a variavel quando nao acha o produto
    -- (SELECT @var = ... sem linhas manteria o valor da iteracao anterior)
    SET @Before35 = (SELECT UnitsInStock
                       FROM #TEMP_STOCK_35
                      WHERE ProductId = @ProductId35)

    IF @Before35 IS NULL
        INSERT INTO #TEMP_LOG_35 (AdjustmentJson)
        VALUES ((SELECT @ProductId35          AS ProductID,
                        @Delta35              AS Delta,
                        'Produto inexistente' AS Motivo
                  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))
    ELSE IF @Before35 + @Delta35 < 0
        -- Products tem CK_UnitsInStock (UnitsInStock >= 0)
        INSERT INTO #TEMP_LOG_35 (AdjustmentJson)
        VALUES ((SELECT @ProductId35         AS ProductID,
                        @Before35            AS BeforeQty,
                        @Delta35             AS Delta,
                        'Estoque negativo'   AS Motivo
                  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))
    ELSE
    BEGIN
        UPDATE #TEMP_STOCK_35
           SET UnitsInStock = UnitsInStock + @Delta35
         WHERE ProductId = @ProductId35

        INSERT INTO #TEMP_LOG_35 (AdjustmentJson)
        VALUES ((SELECT @ProductId35         AS ProductID,
                        @Before35            AS BeforeQty,
                        @Before35 + @Delta35 AS AfterQty,
                        @Delta35             AS Delta
                  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))
    END

    FETCH NEXT FROM StockXmlCursor INTO @ProductId35, @Delta35
END

CLOSE StockXmlCursor
DEALLOCATE StockXmlCursor

SELECT * FROM #TEMP_STOCK_35
SELECT * FROM #TEMP_LOG_35

DROP TABLE #TEMP_LOG_35
DROP TABLE #TEMP_STOCK_35

------------------------------------------------------------------------------------------------------------------------------------------
-- 36
------------------------------------------------------------------------------------------------------------------------------------------

-- Customers chegam em JSON e Orders em XML. Pedido sem cliente valido nao entra.
DROP TABLE IF EXISTS #TEMP_CUSTOMERS_36
CREATE TABLE #TEMP_CUSTOMERS_36
(
    CustomerId  CHAR(5),
    CompanyName VARCHAR(40)
)

DROP TABLE IF EXISTS #TEMP_ORDERS_36
CREATE TABLE #TEMP_ORDERS_36
(
    OrderId    INT,
    CustomerId CHAR(5)
)

DROP TABLE IF EXISTS #TEMP_REJEITADOS_36
CREATE TABLE #TEMP_REJEITADOS_36
(
    OrderId    INT,
    CustomerId CHAR(5),
    Motivo     VARCHAR(40)
)

DECLARE @JsonCustomers36 NVARCHAR(MAX) =
    '[
        {"CustomerID": "ALFKI", "CompanyName": "Alfreds Futterkiste"},
        {"CustomerID": "NEW01", "CompanyName": "Cliente Novo"}
     ]'

DECLARE @XmlOrders36 XML =
    '<Orders>
        <Order OrderID="98001" CustomerID="ALFKI"/>
        <Order OrderID="98002" CustomerID="NEW01"/>
        <Order OrderID="98003" CustomerID="?????"/>
     </Orders>'

BEGIN TRY
    BEGIN TRAN

    INSERT INTO #TEMP_CUSTOMERS_36 (CustomerId, CompanyName)
    SELECT CustomerID,
           CompanyName
      FROM OPENJSON(@JsonCustomers36)
      WITH (CustomerID  CHAR(5)     '$.CustomerID',
            CompanyName VARCHAR(40) '$.CompanyName')

    INSERT INTO #TEMP_ORDERS_36 (OrderId, CustomerId)
    SELECT T.C.value('@OrderID', 'INT'),
           T.C.value('@CustomerID', 'CHAR(5)')
      FROM @XmlOrders36.nodes('/Orders/Order') AS T(C)
     WHERE EXISTS (SELECT 1
                     FROM #TEMP_CUSTOMERS_36 c
                    WHERE c.CustomerId = T.C.value('@CustomerID', 'CHAR(5)'))

    INSERT INTO #TEMP_REJEITADOS_36 (OrderId, CustomerId, Motivo)
    SELECT T.C.value('@OrderID', 'INT'),
           T.C.value('@CustomerID', 'CHAR(5)'),
           'Cliente ausente no JSON'
      FROM @XmlOrders36.nodes('/Orders/Order') AS T(C)
     WHERE NOT EXISTS (SELECT 1
                         FROM #TEMP_CUSTOMERS_36 c
                        WHERE c.CustomerId = T.C.value('@CustomerID', 'CHAR(5)'))

    COMMIT TRAN
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN

    PRINT 'ERRO: ' + ERROR_MESSAGE()
END CATCH

SELECT * FROM #TEMP_CUSTOMERS_36
SELECT * FROM #TEMP_ORDERS_36
SELECT * FROM #TEMP_REJEITADOS_36

DROP TABLE #TEMP_REJEITADOS_36
DROP TABLE #TEMP_ORDERS_36
DROP TABLE #TEMP_CUSTOMERS_36

------------------------------------------------------------------------------------------------------------------------------------------
-- 37
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @CustomerId37 CHAR(5)

DROP TABLE IF EXISTS #TEMP_37
CREATE TABLE #TEMP_37
(
    CustomerId CHAR(5),
    OrdersJson NVARCHAR(MAX)
)

DECLARE @XmlData37 XML =
    '<Orders>
        <Order CustomerID="VINET" OrderID="10248" OrderDate="1996-07-04" ProductID="11"/>
        <Order CustomerID="VINET" OrderID="10248" OrderDate="1996-07-04" ProductID="42"/>
        <Order CustomerID="TOMSP" OrderID="10249" OrderDate="1996-07-05" ProductID="14"/>
     </Orders>'

DECLARE XmlCustomerCursor CURSOR FOR
 SELECT DISTINCT T.C.value('@CustomerID', 'CHAR(5)')
   FROM @XmlData37.nodes('/Orders/Order') AS T(C)

OPEN XmlCustomerCursor
FETCH NEXT FROM XmlCustomerCursor INTO @CustomerId37

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_37 (CustomerId, OrdersJson)
    SELECT @CustomerId37,
           (SELECT T.C.value('@OrderID', 'INT')    AS OrderID,
                   T.C.value('@OrderDate', 'DATE') AS OrderDate,
                   T.C.value('@ProductID', 'INT')  AS ProductID
              FROM @XmlData37.nodes('/Orders/Order') AS T(C)
             WHERE T.C.value('@CustomerID', 'CHAR(5)') = @CustomerId37
              FOR JSON PATH)

    FETCH NEXT FROM XmlCustomerCursor INTO @CustomerId37
END

CLOSE XmlCustomerCursor
DEALLOCATE XmlCustomerCursor

SELECT * FROM #TEMP_37
DROP TABLE #TEMP_37

------------------------------------------------------------------------------------------------------------------------------------------
-- 38
------------------------------------------------------------------------------------------------------------------------------------------

-- JSON traz o preco corrente e o XML traz o preco corrigido
-- Aqui nesta questao, a divergencia entre os valores e ajustada e apresentada na temporaria de proposito
-- O FULL JOIN aponta tambem os produtos que existem em apenas uma das fontes
DECLARE @ProductId38 INT,
        @JsonIndex38 INT,
        @XmlPrice38  MONEY

DROP TABLE IF EXISTS #TEMP_38
CREATE TABLE #TEMP_38
(
    ProductId INT,
    JsonIndex INT,
    JsonPrice MONEY,
    XmlPrice  MONEY,
    Status    VARCHAR(20),
    Fixed     BIT
)

DECLARE @JsonData38 NVARCHAR(MAX) =
    '[
        {"ProductID": 1, "UnitPrice": 18.00},
        {"ProductID": 2, "UnitPrice": 19.00},
        {"ProductID": 3, "UnitPrice": 10.00},
        {"ProductID": 4, "UnitPrice": 22.00}
     ]'

DECLARE @XmlData38 XML =
    '<Products>
        <Product ProductID="1" UnitPrice="18.00"/>
        <Product ProductID="2" UnitPrice="17.50"/>
        <Product ProductID="3" UnitPrice="10.00"/>
        <Product ProductID="5" UnitPrice="21.35"/>
     </Products>'

-- O [key] do OPENJSON sem WITH e a posicao do item no array, usada depois no JSON_MODIFY
INSERT INTO #TEMP_38 (ProductId, JsonIndex, JsonPrice, XmlPrice, Status, Fixed)
          SELECT COALESCE(j.ProductID, x.ProductID),
                 j.JsonIndex,
                 j.UnitPrice,
                 x.UnitPrice,
                 CASE WHEN j.ProductID IS NULL        THEN 'Ausente no JSON'
                      WHEN x.ProductID IS NULL        THEN 'Ausente no XML'
                      WHEN j.UnitPrice <> x.UnitPrice THEN 'Preco divergente'
                      ELSE 'OK'
                  END,
                 0
            FROM (SELECT CAST(a.[key] AS INT) AS JsonIndex,
                         p.ProductID,
                         p.UnitPrice
                    FROM OPENJSON(@JsonData38) a
             CROSS APPLY OPENJSON(a.value)
                    WITH (ProductID INT   '$.ProductID',
                          UnitPrice MONEY '$.UnitPrice') p) j
 FULL OUTER JOIN (SELECT T.C.value('@ProductID', 'INT')   AS ProductID,
                         T.C.value('@UnitPrice', 'MONEY') AS UnitPrice
                    FROM @XmlData38.nodes('/Products/Product') AS T(C)) x
              ON x.ProductID = j.ProductID

DECLARE FixPriceCursor CURSOR FOR
 SELECT ProductId,
        JsonIndex,
        XmlPrice
   FROM #TEMP_38
  WHERE Status = 'Preco divergente'

OPEN FixPriceCursor
FETCH NEXT FROM FixPriceCursor INTO @ProductId38, @JsonIndex38, @XmlPrice38

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Corrige o proprio documento JSON, na posicao do produto no array
    SET @JsonData38 = JSON_MODIFY(@JsonData38,
                                  '$[' + CAST(@JsonIndex38 AS VARCHAR(10)) + '].UnitPrice',
                                  CAST(@XmlPrice38 AS DECIMAL(10, 2)))

    UPDATE #TEMP_38
       SET JsonPrice = @XmlPrice38,
           Fixed = 1
     WHERE ProductId = @ProductId38

    FETCH NEXT FROM FixPriceCursor INTO @ProductId38, @JsonIndex38, @XmlPrice38
END

CLOSE FixPriceCursor
DEALLOCATE FixPriceCursor

SELECT * FROM #TEMP_38
SELECT @JsonData38 AS JsonCorrigido
DROP TABLE #TEMP_38

------------------------------------------------------------------------------------------------------------------------------------------
-- 39
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_LOG_39
CREATE TABLE #TEMP_LOG_39
(
    OpType  VARCHAR(20),
    OpJson  NVARCHAR(MAX),
    OpDate  DATE
)

DROP TABLE IF EXISTS #TEMP_PRICE_39
CREATE TABLE #TEMP_PRICE_39
(
    ProductId INT,
    UnitPrice MONEY
)

-- Restricao de leitura para: apenas os produtos 1 e 2
-- para o log e o XML do dia ficarem legiveis, e nao ficarem um trambolho...
INSERT INTO #TEMP_PRICE_39 (ProductId, UnitPrice)
SELECT ProductID,
       UnitPrice
  FROM Products
 WHERE ProductID IN (1, 2)

-- Duas operacoes de preco e uma de estoque, cada uma registrada em JSON
UPDATE #TEMP_PRICE_39
   SET UnitPrice = UnitPrice * 1.10
 WHERE ProductId = 1

INSERT INTO #TEMP_LOG_39 (OpType, OpJson, OpDate)
VALUES ('PRECO',
        (SELECT 1 AS ProductID, UnitPrice AS NewPrice
           FROM #TEMP_PRICE_39
          WHERE ProductId = 1
           FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
        CAST(GETDATE() AS DATE))

UPDATE #TEMP_PRICE_39
   SET UnitPrice = UnitPrice * 0.90
 WHERE ProductId = 2

INSERT INTO #TEMP_LOG_39 (OpType, OpJson, OpDate)
VALUES ('PRECO',
        (SELECT 2 AS ProductID, UnitPrice AS NewPrice
           FROM #TEMP_PRICE_39
          WHERE ProductId = 2
           FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
        CAST(GETDATE() AS DATE))

INSERT INTO #TEMP_LOG_39 (OpType, OpJson, OpDate)
VALUES ('ESTOQUE',
        (SELECT 1 AS ProductID, 10 AS Delta
          FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
        CAST(GETDATE() AS DATE))

-- Log do dia consolidado em XML, agrupado pelo tipo da operacao
      SELECT l.OpType,
             (        SELECT JSON_VALUE(l2.OpJson, '$.ProductID') AS ProductID,
                             l2.OpJson
                        FROM #TEMP_LOG_39 l2
                       WHERE l2.OpType = l.OpType
                         AND l2.OpDate = CAST(GETDATE() AS DATE)
                FOR XML PATH('Operation'), TYPE) AS Operations
        FROM #TEMP_LOG_39 l
       WHERE l.OpDate = CAST(GETDATE() AS DATE)
    GROUP BY l.OpType
FOR XML PATH('OpType'), ROOT('DailyLog')

SELECT * FROM #TEMP_LOG_39
DROP TABLE #TEMP_LOG_39
DROP TABLE #TEMP_PRICE_39

------------------------------------------------------------------------------------------------------------------------------------------
-- 40
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @ProductId40   INT,
        @ProductName40 VARCHAR(40),
        @UnitPrice40   MONEY

DROP TABLE IF EXISTS #TEMP_PRODUCTS_40
CREATE TABLE #TEMP_PRODUCTS_40
(
    ProductId   INT,
    ProductName VARCHAR(40),
    UnitPrice   MONEY
)

DROP TABLE IF EXISTS #TEMP_AUDIT_40
CREATE TABLE #TEMP_AUDIT_40
(
    AuditJson NVARCHAR(MAX)
)

DECLARE @XmlData40 XML =
    '<Products>
        <Product ProductID="80" ProductName="PICANHA MATURADA" UnitPrice="89.90"/>
        <Product ProductID="81" ProductName="QUEIJO COALHO" UnitPrice="22.50"/>
     </Products>'

DECLARE MigrateXmlCursor CURSOR FOR
 SELECT T.C.value('@ProductID', 'INT'),
        T.C.value('@ProductName', 'VARCHAR(40)'),
        T.C.value('@UnitPrice', 'MONEY')
   FROM @XmlData40.nodes('/Products/Product') AS T(C)

OPEN MigrateXmlCursor
FETCH NEXT FROM MigrateXmlCursor INTO @ProductId40, @ProductName40, @UnitPrice40

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_PRODUCTS_40 (ProductId, ProductName, UnitPrice)
    VALUES (@ProductId40, @ProductName40, @UnitPrice40)

    INSERT INTO #TEMP_AUDIT_40 (AuditJson)
    VALUES ((SELECT @ProductId40   AS ProductID,
                    @ProductName40 AS ProductName,
                    @UnitPrice40   AS UnitPrice,
                    'INSERT'       AS [Action]
              FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))

    FETCH NEXT FROM MigrateXmlCursor INTO @ProductId40, @ProductName40, @UnitPrice40
END

CLOSE MigrateXmlCursor
DEALLOCATE MigrateXmlCursor

-- Espelho em JSON, do que foi carregado a partir do XML
SELECT (SELECT ProductId,
               ProductName,
               UnitPrice
          FROM #TEMP_PRODUCTS_40
           FOR JSON PATH) AS ProductsJson

SELECT * FROM #TEMP_PRODUCTS_40
SELECT * FROM #TEMP_AUDIT_40

DROP TABLE #TEMP_AUDIT_40
DROP TABLE #TEMP_PRODUCTS_40