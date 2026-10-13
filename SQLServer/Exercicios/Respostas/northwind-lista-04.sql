
USE NORTHWIND
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
    VALUES ( @CustomerId01, @CompanyName01, ISNULL(@Region01, 'N/A') )

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
         COUNT( OrderID ) AS TotalOrders
    FROM Orders
GROUP BY CustomerID

OPEN TotalOrdersCursor
FETCH NEXT FROM TotalOrdersCursor INTO @CustomerId02, @TotalOrders02

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_02
    VALUES ( @CustomerId02, @TotalOrders02 )

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
    VALUES ( @OrderId03, @CustomerId03, 'ALTO CUSTO' )

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

SET @OrderId04 = ( SELECT MAX( OrderID ) FROM Orders ) + 1

OPEN LowStockCursor
FETCH NEXT FROM LowStockCursor INTO @ProductId04, @UnitsInStock04

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_ORDERS_04
    VALUES ( @OrderId04, 'TESTE' )

    INSERT INTO #TEMP_OD_04
    VALUES ( @OrderId04, @ProductId04, @UnitsInStock04 )

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
    --## DESCONTO DIFERENCIADO POR FORNECEDOR: 10%, 20% E 30% ##--
    INSERT INTO #TEMP_05
    VALUES ( @ProductName05,
             @SupplierId05,
             CASE WHEN @SupplierId05 = 1 THEN @UnitPrice05 * 0.9
                  WHEN @SupplierId05 = 2 THEN @UnitPrice05 * 0.8
                  WHEN @SupplierId05 = 3 THEN @UnitPrice05 * 0.7
                  ELSE @UnitPrice05
                  END
           )

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

--## MEDIA DE PEDIDOS PROCESSADOS = PEDIDOS DO FUNCIONARIO DIVIDIDOS PELOS MESES EM QUE ELE ATENDEU PEDIDOS ##--

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
  SELECT e.FirstName + ' ' + e.LastName                                   AS FullName,
         COUNT( o.OrderID )                                               AS QtyOrders,
         COUNT( DISTINCT YEAR(o.OrderDate) * 100 + MONTH(o.OrderDate) )   AS QtyMonths
    FROM Employees e
    JOIN Orders    o ON o.EmployeeID = e.EmployeeID
GROUP BY e.FirstName, e.LastName

OPEN QtyOrdersEmployeeCursor
FETCH NEXT FROM QtyOrdersEmployeeCursor INTO @FullName06, @QtyOrders06, @QtyMonths06

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_06
    VALUES ( @FullName06, @QtyOrders06, @QtyMonths06, @QtyOrders06 * 1.0 / @QtyMonths06 )

    FETCH NEXT FROM QtyOrdersEmployeeCursor INTO @FullName06, @QtyOrders06, @QtyMonths06
END

CLOSE QtyOrdersEmployeeCursor
DEALLOCATE QtyOrdersEmployeeCursor

SELECT * FROM #TEMP_06
DROP TABLE #TEMP_06

------------------------------------------------------------------------------------------------------------------------------------------
-- 07
------------------------------------------------------------------------------------------------------------------------------------------

--## SERA ADOTADO O INTERVALO ENTRE 01/01/1997 E 31/12/1997 ##--

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
    VALUES ( @CustomerId07, @QtyOrders07 )

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

--## VENDAS = VALOR DOS ITENS DOS PEDIDOS (ORDER DETAILS). FREIGHT E APENAS O FRETE ##--
--## COUNT(DISTINCT): DEPOIS DO JOIN HA UMA LINHA POR ITEM, NAO POR PEDIDO ##--

DECLARE TotalSalesCountryCursor CURSOR FOR
  SELECT o.ShipCountry,
         COUNT( DISTINCT o.OrderID )                             AS QtyOrders,
         SUM( od.Quantity * od.UnitPrice * ( 1 - od.Discount ) ) AS TotalSales
    FROM Orders           o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY o.ShipCountry
ORDER BY o.ShipCountry

OPEN TotalSalesCountryCursor
FETCH NEXT FROM TotalSalesCountryCursor INTO @Country08, @QtyOrders08, @TotalSales08

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #TEMP_08
    VALUES ( @Country08, @QtyOrders08, @TotalSales08 )

    FETCH NEXT FROM TotalSalesCountryCursor INTO @Country08, @QtyOrders08, @TotalSales08
END

CLOSE TotalSalesCountryCursor
DEALLOCATE TotalSalesCountryCursor

SELECT * FROM #TEMP_08
DROP TABLE #TEMP_08

------------------------------------------------------------------------------------------------------------------------------------------
-- 09
------------------------------------------------------------------------------------------------------------------------------------------

--## A PK DE CUSTOMERS IMPEDE DUPLICATAS REAIS: A DUPLICIDADE E SIMULADA EM UMA COPIA TEMPORARIA ##--
--## "MAIS ANTIGO" = MENOR RowId (ORDEM DE INSERCAO), JA QUE CUSTOMERS NAO TEM DATA DE CADASTRO ##--

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

--## DUPLICATAS DE TESTE ##--

INSERT INTO #TEMP_09 ( CustomerId, CompanyName, City, Country )
SELECT CustomerID,
       CompanyName,
       City,
       Country
  FROM Customers
 WHERE CustomerID IN ( 'ALFKI', 'ANATR' )

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
    --## MANTEM O REGISTRO MAIS ANTIGO E EXCLUI OS DEMAIS ##--
    DELETE FROM #TEMP_09
          WHERE CustomerId = @CustomerId09
            AND RowId      > @FirstRowId09

    FETCH NEXT FROM DuplicateCustomerCursor INTO @CustomerId09, @FirstRowId09
END

CLOSE DuplicateCustomerCursor
DEALLOCATE DuplicateCustomerCursor

--## CONFERENCIA: NAO DEVE RESTAR NENHUM CLIENTE DUPLICADO ##--

  SELECT CustomerId,
         COUNT(*) AS QtyDuplicate
    FROM #TEMP_09
GROUP BY CustomerId
  HAVING COUNT(*) > 1

SELECT * FROM #TEMP_09 WHERE CustomerId IN ( 'ALFKI', 'ANATR' )
DROP TABLE #TEMP_09

------------------------------------------------------------------------------------------------------------------------------------------
-- 10
------------------------------------------------------------------------------------------------------------------------------------------

--## DATA DE REFERENCIA: ULTIMO PEDIDO DA BASE. A SEMANA DO RELATORIO SAO OS 7 DIAS ANTERIORES A ELA ##--
--## ATRASADO = ENVIADO DEPOIS DA DATA REQUERIDA, OU AINDA NAO ENVIADO COM A DATA REQUERIDA JA VENCIDA ##--
--## O ENVIO DO E-MAIL E SIMULADO COM PRINT ##--

DECLARE @CustomerId10    VARCHAR(50),
        @DelayedOrders10 INT,
        @RefDate10       DATETIME = ( SELECT MAX(OrderDate) FROM Orders )

DECLARE DelayedOrdersCursor CURSOR FOR
  SELECT c.CompanyName,
         COUNT(*) AS DelayedOrders
    FROM Orders    o
    JOIN Customers c ON c.CustomerID = o.CustomerID
   WHERE o.RequiredDate BETWEEN DATEADD( DAY, -7, @RefDate10 ) AND @RefDate10
     AND ( o.ShippedDate > o.RequiredDate
           OR o.ShippedDate IS NULL )
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

--## O XML E ARMAZENADO EM UMA COLUNA XML DE UMA TABELA DE LOG (TEMPORARIA) ##--

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

--## FORNECEDORES PARA CADA PRODUTO ##--

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

--## PRODUTOS PARA CADA FORNECEDOR ##--

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

--## PARA NAO IMPLICAR EM ERROS NO SCRIPT, NAO SERA ADOTADA A CRIACAO DE UM PROCEDURE ##--
--## PARA NAO ALTERAR A BASE, OS NOVOS CLIENTES SAO INSERIDOS EM UMA TABELA TEMPORARIA ##--

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
SELECT T.C.value( '(CustomerId)[1]' , 'CHAR(5)'     ) AS CustomerId,
       T.C.value( '(CompanyName)[1]', 'VARCHAR(50)' ) AS CompanyName,
       T.C.value( '(City)[1]'       , 'VARCHAR(30)' ) AS City,
       T.C.value( '(Country)[1]'    , 'VARCHAR(30)' ) AS Country
  FROM @XMLData14.nodes('/Customers/Customer') AS T(C)

SELECT * FROM #TEMP_14
DROP TABLE #TEMP_14

------------------------------------------------------------------------------------------------------------------------------------------
-- 15
------------------------------------------------------------------------------------------------------------------------------------------

--## O "ULTIMO MES" E CONTADO A PARTIR DO PEDIDO MAIS RECENTE DO PROPRIO XML ##--
--## DATAS NO FORMATO AAAA-MM-DD COMPARAM CORRETAMENTE COMO TEXTO DENTRO DO XPATH ##--

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

SELECT T.C.value( '(OrderID)[1]'   , 'INT'     ) AS OrderID,
       T.C.value( '(CustomerID)[1]', 'CHAR(5)' ) AS CustomerID,
       T.C.value( '(OrderDate)[1]' , 'DATE'    ) AS OrderDate
  FROM @XMLData15.nodes('/Orders/Order[OrderDate >= sql:variable("@BeginDate15")]') AS T(C)

------------------------------------------------------------------------------------------------------------------------------------------
-- 16
------------------------------------------------------------------------------------------------------------------------------------------

--## PARA NAO ALTERAR A BASE, A ATUALIZACAO E FEITA EM UMA COPIA TEMPORARIA DE EMPLOYEES ##--

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
                        JOIN Products p ON p.ProductID = od.ProductID
                       WHERE od.OrderID = o.OrderID
                FOR XML PATH ( 'Products' ), TYPE ) AS Products
        FROM Orders o
FOR XML PATH ( 'Order' ), ROOT ( 'Orders' )

------------------------------------------------------------------------------------------------------------------------------------------
-- 18
------------------------------------------------------------------------------------------------------------------------------------------

      SELECT c1.Country,
             (        SELECT c2.CustomerID,
                             c2.CompanyName
                        FROM Customers c2
                       WHERE c2.Country = c1.Country
                FOR XML PATH ( 'Customers' ), TYPE ) AS Customers
        FROM Customers c1
    GROUP BY c1.Country
    ORDER BY c1.Country ASC
FOR XML PATH ( 'Country' ), ROOT ( 'Countries' )

------------------------------------------------------------------------------------------------------------------------------------------
-- 19
------------------------------------------------------------------------------------------------------------------------------------------

--## USAREI UMA TABELA TEMPORARIA ##--

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
SELECT T.C.value( '(ProductId)[1]'  , 'INT'         ) AS ProductId,
       T.C.value( '(ProductName)[1]', 'VARCHAR(50)' ) AS ProductName
  FROM @XMLData19.nodes('/Products/Product') AS T(C)

SELECT * FROM #TEMP_19
DROP TABLE #TEMP_19

------------------------------------------------------------------------------------------------------------------------------------------
-- 20
------------------------------------------------------------------------------------------------------------------------------------------

--## O XML TEM UM DESCONTO POR ITEM; O TOTAL E SOMADO POR PEDIDO ##--
--## METODOS DE XML NAO PODEM IR DIRETO NO GROUP BY: OS VALORES SAO EXTRAIDOS ANTES, EM UMA CTE ##--

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
    SELECT T.C.value( '(OrderID)[1]' , 'INT'   ) AS OrderID,
           T.C.value( '(Discount)[1]', 'MONEY' ) AS Discount
      FROM @XMLData20.nodes( '/Discounts/Item' ) AS T(C)
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

SET @JsonData21 = 
( SELECT CustomerID,
         CompanyName,
         Phone,
         City, 
         Country
    FROM Customers
  FOR JSON PATH
)

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
 WHERE CategoryID IN ( 1, 2 )

DECLARE @PriceAdjustments NVARCHAR(MAX) =
    '[
        {"CategoryID": 1, "Adjustment": 1.1},
        {"CategoryID": 2, "Adjustment": 0.9}
    ]'

DECLARE AdjustmentCursor CURSOR FOR
SELECT CategoryID,
       Adjustment
  FROM OPENJSON( @PriceAdjustments )
WITH ( CategoryID INT   '$.CategoryID',
       Adjustment FLOAT '$.Adjustment' );

OPEN AdjustmentCursor
FETCH NEXT FROM AdjustmentCursor INTO @CategoryId22, @Adjustment22

WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE t
       SET t.PriceAdjusted = t.Price * @Adjustment22
      FROM #TEMP_22 t
     WHERE t.CategoryId    = @CategoryId22

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

--## TOP SO E DETERMINISTICO COM ORDER BY: SAO OS 10 PRIMEIROS PEDIDOS ##--

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
                           JOIN Products         p ON p.ProductID = od.ProductID
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

--## PARA FACILITAR, NAO CRIAREI UMA PROCEDURE, MAS ARMAZENAREI NUMA TABELA TEMPORARIA ##--

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

--## CADA PROPRIEDADE DO JSON E MAPEADA PARA UMA COLUNA NO WITH ##--
--## (UMA COLUNA NVARCHAR(MAX) '$' SEM "AS JSON" RETORNA NULL QUANDO O VALOR E UM OBJETO) ##--

INSERT INTO #TEMP_24 ( LastName, FirstName, Title, Country )
SELECT LastName,
       FirstName,
       Title,
       Country
  FROM OPENJSON ( @JsonData24 )
  WITH ( LastName  VARCHAR(50) '$.LastName',
         FirstName VARCHAR(50) '$.FirstName',
         Title     VARCHAR(20) '$.Title',
         Country   VARCHAR(20) '$.Country' );

SELECT * FROM #TEMP_24
DROP TABLE #TEMP_24

------------------------------------------------------------------------------------------------------------------------------------------
-- 25
------------------------------------------------------------------------------------------------------------------------------------------

--## O HISTORICO DE CADA CLIENTE E CONVERTIDO PARA JSON E ARMAZENADO EM UMA TABELA DE LOG (TEMPORARIA), UMA LINHA POR CLIENTE ##--

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
        FOR JSON AUTO ),
       GETDATE()
  FROM Customers

SELECT * FROM #TEMP_25
DROP TABLE #TEMP_25

------------------------------------------------------------------------------------------------------------------------------------------
--## PENDENTE: EXERCICIOS 26 A 40 ##--
------------------------------------------------------------------------------------------------------------------------------------------
