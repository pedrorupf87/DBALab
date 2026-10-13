
USE NORTHWIND
GO

--## VALOR DE CADA PEDIDO = SOMA DOS ITENS (PRECO x QUANTIDADE, COM DESCONTO) ##--
--## USADO NESTA LISTA SEMPRE QUE O ENUNCIADO FALA EM "VALOR DO PEDIDO" OU "VENDAS". FREIGHT E APENAS O FRETE ##--

DROP TABLE IF EXISTS #ORDER_VALUE
  SELECT o.OrderID,
         o.CustomerID,
         o.EmployeeID,
         o.OrderDate,
         o.ShipRegion,
         CAST(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS MONEY) AS OrderValue
    INTO #ORDER_VALUE
    FROM Orders           o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY o.OrderID, o.CustomerID, o.EmployeeID, o.OrderDate, o.ShipRegion

------------------------------------------------------------------------------------------------------------------------------------------
-- 01
------------------------------------------------------------------------------------------------------------------------------------------

SELECT o.OrderID,
       e.FirstName + ' ' + e.LastName                                                                     AS FullName,
       CAST(o.OrderDate AS DATE)                                                                          AS OrderDate,
       COUNT(*) OVER (PARTITION BY o.EmployeeID ORDER BY o.OrderDate, o.OrderID ROWS UNBOUNDED PRECEDING) AS TotalAcumulated
  FROM Orders    o
  JOIN Employees e ON e.EmployeeID = o.EmployeeID

------------------------------------------------------------------------------------------------------------------------------------------
-- 02
------------------------------------------------------------------------------------------------------------------------------------------

SELECT CustomerID,
       OrderID,
       CAST(OrderDate AS DATE)                                                                               AS OrderDate,
       OrderValue,
       AVG(OrderValue) OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID ROWS 2 PRECEDING)           AS MediaMovel
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 03
------------------------------------------------------------------------------------------------------------------------------------------

SELECT p.CategoryID,
       p.ProductName,
       SUM(od.Quantity * od.UnitPrice) OVER (PARTITION BY p.CategoryID ORDER BY od.OrderID) AS TotalPrice
  FROM [Order Details] od
  JOIN Products p ON p.ProductID = od.ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 04
------------------------------------------------------------------------------------------------------------------------------------------

    SELECT p.CategoryID,
           p.ProductName,
           SUM(od.Quantity * od.UnitPrice)                                                                                 AS TotalSales,
           SUM(SUM(od.Quantity * od.UnitPrice)) OVER (PARTITION BY p.CategoryID)                                           AS TotalCategory,
           SUM(od.Quantity * od.UnitPrice) * 100.0 / SUM(SUM(od.Quantity * od.UnitPrice)) OVER (PARTITION BY p.CategoryID) AS PctContribution
    FROM Products p
    JOIN [Order Details] od ON p.ProductID = od.ProductID
GROUP BY p.CategoryID, p.ProductName

------------------------------------------------------------------------------------------------------------------------------------------
-- 05
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT OrderID,
         CustomerID,
         COUNT(OrderID) OVER (PARTITION BY CustomerID) AS Quantity
    FROM Orders

------------------------------------------------------------------------------------------------------------------------------------------
-- 06
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT OrderID,
         CustomerID,
         MIN(CAST(OrderDate AS DATE)) OVER (PARTITION BY CustomerID) AS FirstOrderDate
    FROM Orders

------------------------------------------------------------------------------------------------------------------------------------------
-- 07
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT OrderID,
         CustomerID,
         OrderValue,
         AVG(OrderValue) OVER (PARTITION BY CustomerID) AS AvgOrderValue
    FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 08
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT OrderID,
         CustomerID,
         OrderValue,
         AVG(OrderValue) OVER (PARTITION BY CustomerID)              AS AvgOrderValue,
         OrderValue - AVG(OrderValue) OVER (PARTITION BY CustomerID) AS DiffAvgOrderValue
    FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 09
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT c.CategoryName,
         p.ProductName,
         RANK() OVER (PARTITION BY c.CategoryName ORDER BY SUM(od.Quantity * od.UnitPrice) DESC) AS Ranking
    FROM Products         p
    JOIN Categories       c ON c.CategoryID = p.CategoryID
    JOIN [Order Details] od ON od.ProductID = p.ProductID
GROUP BY c.CategoryName, p.ProductName

------------------------------------------------------------------------------------------------------------------------------------------
-- 10
------------------------------------------------------------------------------------------------------------------------------------------

--## SEM ROWS, O QUADRO PADRAO (RANGE) SOMA JUNTOS OS PEDIDOS DO MESMO DIA: E O ACUMULADO DIARIO ##--

SELECT OrderID,
       CustomerID,
       CAST(OrderDate AS DATE)                                           AS OrderDate,
       SUM(OrderValue) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS TotalByDay
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 11
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT c.CategoryName,
         p.ProductName,
         DENSE_RANK() OVER (PARTITION BY c.CategoryName ORDER BY SUM( od.Quantity * od.UnitPrice) DESC) AS Ranking
    FROM Products         p
    JOIN Categories       c ON c.CategoryID = p.CategoryID
    JOIN [Order Details] od ON od.ProductID = p.ProductID
GROUP BY c.CategoryName, p.ProductName

------------------------------------------------------------------------------------------------------------------------------------------
-- 12
------------------------------------------------------------------------------------------------------------------------------------------

--## OPCAO 01 ##--

SELECT CustomerID,
       MIN(OrderValue)                   AS MinOrderValue,
       MAX(OrderValue)                   AS MaxOrderValue,
       MAX(OrderValue) - MIN(OrderValue) AS DifferenceOrderValue
  FROM #ORDER_VALUE
GROUP BY CustomerID

--## OPCAO 02 ##--

SELECT DISTINCT CustomerID,
       MAX(OrderValue) OVER (PARTITION BY CustomerID) - MIN(OrderValue) OVER (PARTITION BY CustomerID) AS DifferenceOrderValue
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 13
------------------------------------------------------------------------------------------------------------------------------------------

SELECT CustomerID,
       OrderID,
       AVG(OrderValue) OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS AvgAcumulated
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 14
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT EmployeeID,
         ISNULL(ShipRegion, 'Not Informed')                                                                    AS ShipRegion,
         SUM(OrderValue)                                                                                       AS TotalSales,
         SUM(SUM(OrderValue)) OVER (PARTITION BY ShipRegion ORDER BY EmployeeID ROWS UNBOUNDED PRECEDING)      AS TotalByRegion
    FROM #ORDER_VALUE
GROUP BY EmployeeID, ShipRegion

------------------------------------------------------------------------------------------------------------------------------------------
-- 15
------------------------------------------------------------------------------------------------------------------------------------------

SELECT OrderID,
       OrderValue,
       ROW_NUMBER() OVER (ORDER BY OrderValue DESC) AS RankSales
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 16
------------------------------------------------------------------------------------------------------------------------------------------

;WITH RankCategoryCTE AS
(
SELECT c.CategoryName,
       p.ProductName,
       RANK() OVER (PARTITION BY c.CategoryName ORDER BY SUM( od.Quantity) DESC) AS Ranking
  FROM Products         p
  JOIN [Order Details] od ON od.ProductID = p.ProductID
  JOIN Categories       c ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryName,
       p.ProductName
)
SELECT *
  FROM RankCategoryCTE
 WHERE Ranking <= 3

------------------------------------------------------------------------------------------------------------------------------------------
-- 17
------------------------------------------------------------------------------------------------------------------------------------------

--## VENDAS TOTALIZADAS POR MES E COMPARADAS COM O MES ANTERIOR ##--

;WITH MonthSales17CTE AS
(
  SELECT YEAR(OrderDate)  AS [Year],
         MONTH(OrderDate) AS [Month],
         SUM(OrderValue)  AS TotalMonthSales
    FROM #ORDER_VALUE
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)
SELECT [Year],
       [Month],
       TotalMonthSales,
       LAG(TotalMonthSales) OVER (ORDER BY [Year], [Month])                               AS LastMonthSales,
       CAST((TotalMonthSales - LAG(TotalMonthSales) OVER (ORDER BY [Year], [Month])) * 100.0
                / NULLIF(LAG(TotalMonthSales) OVER (ORDER BY [Year], [Month]), 0) AS DECIMAL(10,2)) AS DiferencaPercentual
  FROM MonthSales17CTE

------------------------------------------------------------------------------------------------------------------------------------------
-- 18
------------------------------------------------------------------------------------------------------------------------------------------

--## RANKING DOS CLIENTES PELA QUANTIDADE DE PEDIDOS FEITOS EM CADA ANO ##--

  SELECT YEAR(OrderDate)                                                    AS [Year],
         CustomerID,
         COUNT(*)                                                           AS QtyOrders,
         RANK() OVER (PARTITION BY YEAR(OrderDate) ORDER BY COUNT(*) DESC)  AS AnualRanking
    FROM Orders
GROUP BY YEAR(OrderDate), CustomerID

------------------------------------------------------------------------------------------------------------------------------------------
-- 19
------------------------------------------------------------------------------------------------------------------------------------------

SELECT EmployeeID,
       YEAR(OrderDate)                                                                                                         AS [Year],
       OrderID,
       SUM(OrderValue) OVER (PARTITION BY EmployeeID, YEAR(OrderDate) ORDER BY OrderDate, OrderID ROWS UNBOUNDED PRECEDING)    AS YearAcumulatedTotal
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 20
------------------------------------------------------------------------------------------------------------------------------------------

--## VENDAS TOTALIZADAS POR PRODUTO E MES; A MEDIA MOVEL USA O MES ATUAL E OS 4 ANTERIORES ##--
--## ROWS CONTA LINHAS: SO EQUIVALE A 5 MESES PORQUE HA UMA LINHA POR MES (MES SEM VENDA DO PRODUTO NAO GERA LINHA) ##--

;WITH ProductMonth20CTE AS
(
  SELECT od.ProductID,
         DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1) AS SalesMonth,
         SUM(od.Quantity * od.UnitPrice)                         AS TotalMonth
    FROM [Order Details] od
    JOIN Orders           o ON o.OrderID = od.OrderID
GROUP BY od.ProductID, DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1)
)
SELECT p.ProductID,
       p.ProductName,
       c.SalesMonth,
       c.TotalMonth,
       AVG(c.TotalMonth) OVER (PARTITION BY c.ProductID ORDER BY c.SalesMonth ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS MovingAvg
  FROM ProductMonth20CTE c
  JOIN Products          p ON p.ProductID = c.ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 21
------------------------------------------------------------------------------------------------------------------------------------------

SELECT OrderID,
       CustomerID,
       LEAD(OrderID)    OVER (ORDER BY OrderDate) AS NextOrder,
       LEAD(CustomerID) OVER (ORDER BY OrderDate) AS NextCustomer
  FROM Orders

------------------------------------------------------------------------------------------------------------------------------------------
-- 22
------------------------------------------------------------------------------------------------------------------------------------------

SELECT OrderID,
       CustomerID,
       OrderValue,
       ISNULL(LEAD(OrderValue) OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID), 0)              AS NextOrderValue,
       ISNULL(LEAD(OrderValue) OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID) - OrderValue, 0) AS DiffNextOrderValue
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 23
------------------------------------------------------------------------------------------------------------------------------------------

--## PRODUCTS GUARDA SO O ESTOQUE ATUAL, SEM HISTORICO MENSAL (LAG POR ProductID COMPARARIA UM PRODUTO COM OUTRO) ##--
--## O ESTOQUE DE CADA FIM DE MES E RECONSTRUIDO: ESTOQUE ATUAL + UNIDADES VENDIDAS DEPOIS DAQUELE MES (IGNORA REPOSICOES) ##--

;WITH MonthSold23CTE AS
(
  SELECT od.ProductID,
         DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1) AS SalesMonth,
         SUM(od.Quantity)                                        AS QtySold
    FROM [Order Details] od
    JOIN Orders           o ON o.OrderID = od.OrderID
GROUP BY od.ProductID, DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1)
),
MonthStock23CTE AS
(
SELECT m.ProductID,
       m.SalesMonth,
       p.UnitsInStock + ISNULL(SUM(m.QtySold) OVER (PARTITION BY m.ProductID ORDER BY m.SalesMonth DESC
                                                    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0) AS StockEndOfMonth
  FROM MonthSold23CTE m
  JOIN Products       p ON p.ProductID = m.ProductID
)
SELECT p.ProductName,
       s.SalesMonth,
       s.StockEndOfMonth,
       LAG(s.StockEndOfMonth) OVER (PARTITION BY s.ProductID ORDER BY s.SalesMonth) AS LastMonthStock
  FROM MonthStock23CTE s
  JOIN Products        p ON p.ProductID = s.ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 24
------------------------------------------------------------------------------------------------------------------------------------------

--## PRODUCTS GUARDA SO O PRECO ATUAL. O HISTORICO VEM DOS PRECOS PRATICADOS EM ORDER DETAILS, ##--
--## ORDENADOS PELA PRIMEIRA DATA EM QUE CADA PRECO APARECEU ##--

;WITH PriceHistory24CTE AS
(
  SELECT od.ProductID,
         od.UnitPrice,
         MIN(o.OrderDate) AS FirstOrderDate
    FROM [Order Details] od
    JOIN Orders           o ON o.OrderID = od.OrderID
GROUP BY od.ProductID, od.UnitPrice
)
SELECT p.ProductName,
       CAST(h.FirstOrderDate AS DATE)                                                                         AS PriceSince,
       h.UnitPrice,
       ISNULL(LAG(h.UnitPrice) OVER (PARTITION BY h.ProductID ORDER BY h.FirstOrderDate), 0)                  AS LastPrice,
       ISNULL(h.UnitPrice - LAG(h.UnitPrice) OVER (PARTITION BY h.ProductID ORDER BY h.FirstOrderDate), 0)    AS DiffLastPrice
  FROM PriceHistory24CTE h
  JOIN Products          p ON p.ProductID = h.ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 25
------------------------------------------------------------------------------------------------------------------------------------------

SELECT OrderID,
       CustomerID,
       OrderValue,
       ISNULL(LEAD(OrderValue) OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID), 0) AS NextOrderValue
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 26
------------------------------------------------------------------------------------------------------------------------------------------

;WITH MonthGrowningCTE AS
(
  SELECT YEAR(OrderDate)                                                                   AS [Year],
         MONTH(OrderDate)                                                                  AS [Month],
         SUM(OrderValue)                                                                   AS TotalMonthSales,
         ISNULL(LAG(SUM(OrderValue)) OVER (ORDER BY YEAR(OrderDate), MONTH(OrderDate)), 0) AS LastMonthSales,
         (SUM(OrderValue) - LAG(SUM(OrderValue)) OVER (ORDER BY YEAR(OrderDate), MONTH(OrderDate))) * 100.0 /
			LAG(SUM(OrderValue)) OVER (ORDER BY YEAR(OrderDate), MONTH(OrderDate))         AS PctGrowning
    FROM #ORDER_VALUE
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)
SELECT [Year],
       [Month],
       TotalMonthSales,
       LastMonthSales,
       FORMAT(ISNULL(PctGrowning, 0), 'N2') AS PctGrowning
  FROM MonthGrowningCTE

------------------------------------------------------------------------------------------------------------------------------------------
-- 27
------------------------------------------------------------------------------------------------------------------------------------------

SELECT CustomerID,
       OrderValue,
	   ISNULL(LAG(OrderValue) OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID), 0)              AS LastOrderValue,
	   ISNULL(OrderValue - LAG(OrderValue) OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID), 0) AS DiffLastOrderValue
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 28
------------------------------------------------------------------------------------------------------------------------------------------

SELECT p.ProductName,
       o.OrderID,
       od.Quantity,
	   LEAD(CAST(o.RequiredDate AS DATE)) OVER (PARTITION BY od.ProductID ORDER BY o.RequiredDate) AS NextRequiredDate
  FROM Orders           o
  JOIN [Order Details] od ON od.OrderID  = o.OrderID
  JOIN Products         p ON p.ProductID = od.ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 29
------------------------------------------------------------------------------------------------------------------------------------------

--## INTERVALO, EM DIAS, ENTRE CADA PEDIDO E O PEDIDO ANTERIOR DO MESMO CLIENTE; DEPOIS, A MEDIA POR CLIENTE ##--

;WITH DaysBetween29CTE AS
(
SELECT CustomerID,
       OrderID,
       DATEDIFF(DAY, LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID), OrderDate) AS DaysSinceLastOrder
  FROM Orders
)
  SELECT CustomerID,
         COUNT(*)                                                             AS QtyOrders,
         CAST(AVG(CAST(DaysSinceLastOrder AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS AvgDaysBetweenOrders
    FROM DaysBetween29CTE
GROUP BY CustomerID

------------------------------------------------------------------------------------------------------------------------------------------
-- 30
------------------------------------------------------------------------------------------------------------------------------------------

SELECT CustomerID,
       OrderID,
       OrderValue                                                                             AS ActualValue,
       ISNULL(LAG(OrderValue) OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID), 0)  AS LastValue,
       CASE WHEN OrderValue > LAG(OrderValue) OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID) THEN 'High'
            ELSE 'Less or equal'
          END AS Comparison
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 31
------------------------------------------------------------------------------------------------------------------------------------------

--## VENDAS TOTALIZADAS POR MES; A MEDIA MOVEL USA O MES ATUAL E OS 11 ANTERIORES ##--

;WITH MonthSales31CTE AS
(
  SELECT DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS SalesMonth,
         SUM(OrderValue)                                     AS TotalMonth
    FROM #ORDER_VALUE
GROUP BY DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1)
)
SELECT SalesMonth,
       TotalMonth,
       AVG(TotalMonth) OVER (ORDER BY SalesMonth ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS MovingAvg
  FROM MonthSales31CTE

------------------------------------------------------------------------------------------------------------------------------------------
-- 32
------------------------------------------------------------------------------------------------------------------------------------------

--## PRIMEIRO O TOTAL DE CADA FUNCIONARIO POR TRIMESTRE; SO DEPOIS O LAG BUSCA O TRIMESTRE ANTERIOR ##--

;WITH QuarterSales32CTE AS
(
  SELECT EmployeeID,
         YEAR(OrderDate)              AS [Year],
         DATEPART(QUARTER, OrderDate) AS [Quarter],
         SUM(OrderValue)              AS TotalQuarter
    FROM #ORDER_VALUE
GROUP BY EmployeeID, YEAR(OrderDate), DATEPART(QUARTER, OrderDate)
)
SELECT e.FirstName + ' ' + e.LastName                                                    AS FullName,
       q.[Year],
       q.[Quarter],
       q.TotalQuarter                                                                    AS TotalActualQuarter,
       LAG(q.TotalQuarter) OVER (PARTITION BY q.EmployeeID ORDER BY q.[Year], q.[Quarter]) AS TotalLastQuarter
  FROM QuarterSales32CTE q
  JOIN Employees         e ON e.EmployeeID = q.EmployeeID

------------------------------------------------------------------------------------------------------------------------------------------
-- 33
------------------------------------------------------------------------------------------------------------------------------------------

--## ROWS CONTA LINHAS (PEDIDOS), NAO DIAS, E O SQL SERVER NAO ACEITA RANGE COM INTERVALO DE DATAS ##--
--## A JANELA DE 30 DIAS E FEITA COM CROSS APPLY: PEDIDOS DO MESMO CLIENTE NOS 30 DIAS ATE A DATA DO PEDIDO ##--

    SELECT ov.CustomerID,
           ov.OrderID,
           CAST(ov.OrderDate AS DATE) AS OrderDate,
           w.Total30Days
      FROM #ORDER_VALUE ov
CROSS APPLY ( SELECT SUM(ov2.OrderValue) AS Total30Days
                FROM #ORDER_VALUE ov2
               WHERE ov2.CustomerID = ov.CustomerID
                 AND ov2.OrderDate  > DATEADD(DAY, -30, ov.OrderDate)
                 AND ov2.OrderDate <= ov.OrderDate ) w

------------------------------------------------------------------------------------------------------------------------------------------
-- 34
------------------------------------------------------------------------------------------------------------------------------------------

SELECT CustomerID,
       YEAR(OrderDate)                                                              AS [Year],
       CAST(MIN(OrderDate) OVER (PARTITION BY CustomerID, YEAR(OrderDate)) AS DATE) AS FirstOrder,
       CAST(MAX(OrderDate) OVER (PARTITION BY CustomerID, YEAR(OrderDate)) AS DATE) AS LastOrder
  FROM Orders

------------------------------------------------------------------------------------------------------------------------------------------
-- 35
------------------------------------------------------------------------------------------------------------------------------------------

--## A ESTACAO E CALCULADA ANTES, EM UMA CTE, PARA PODER SER USADA NO PARTITION BY ##--
--## (UM ALIAS ENTRE ASPAS NO PARTITION BY E APENAS UM TEXTO CONSTANTE) ##--

;WITH SeasonSales35CTE AS
(
  SELECT od.ProductID,
         CASE WHEN MONTH(o.OrderDate) IN (12, 1, 2) THEN 'Winter'
              WHEN MONTH(o.OrderDate) IN (3, 4, 5)  THEN 'Spring'
              WHEN MONTH(o.OrderDate) IN (6, 7, 8)  THEN 'Summer'
              ELSE 'Autumn'
          END                       AS Season,
         od.Quantity * od.UnitPrice AS SaleValue
    FROM [Order Details] od
    JOIN Orders           o ON o.OrderID = od.OrderID
)
SELECT DISTINCT
       p.ProductName,
       s.Season,
       AVG(s.SaleValue) OVER (PARTITION BY s.ProductID, s.Season) AS AvgSeasons
  FROM SeasonSales35CTE s
  JOIN Products         p ON p.ProductID = s.ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 36
------------------------------------------------------------------------------------------------------------------------------------------

--## MESMA TECNICA DO EXERCICIO 33: JANELA DESLIZANTE DE 7 DIAS COM CROSS APPLY ##--

    SELECT ov.CustomerID,
           ov.OrderID,
           CAST(ov.OrderDate AS DATE) AS OrderDate,
           w.Total7Days
      FROM #ORDER_VALUE ov
CROSS APPLY ( SELECT SUM(ov2.OrderValue) AS Total7Days
                FROM #ORDER_VALUE ov2
               WHERE ov2.CustomerID = ov.CustomerID
                 AND ov2.OrderDate  > DATEADD(DAY, -7, ov.OrderDate)
                 AND ov2.OrderDate <= ov.OrderDate ) w

------------------------------------------------------------------------------------------------------------------------------------------
-- 37
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT CustomerID,
         YEAR(OrderDate)                                                        AS [Year],
         DATEPART(WEEK, OrderDate)                                              AS [Week],
         SUM(OrderValue)                                                        AS TotalWeek,
         RANK() OVER (PARTITION BY CustomerID ORDER BY SUM(OrderValue) DESC)    AS WeekRanking
    FROM #ORDER_VALUE
GROUP BY CustomerID, YEAR(OrderDate), DATEPART(WEEK, OrderDate)

------------------------------------------------------------------------------------------------------------------------------------------
-- 38
------------------------------------------------------------------------------------------------------------------------------------------

--## PARTICAO POR FUNCIONARIO, ANO E TRIMESTRE: O ACUMULADO RECOMECA A CADA TRIMESTRE ##--

SELECT ov.OrderID,
       e.FirstName + ' ' + e.LastName   AS FullName,
       CAST(ov.OrderDate AS DATE)       AS OrderDate,
       YEAR(ov.OrderDate)               AS [Year],
       DATEPART(QUARTER, ov.OrderDate)  AS [Quarter],
       SUM(ov.OrderValue) OVER (PARTITION BY ov.EmployeeID, YEAR(ov.OrderDate), DATEPART(QUARTER, ov.OrderDate)
                                    ORDER BY ov.OrderDate, ov.OrderID ROWS UNBOUNDED PRECEDING) AS TotalQuarter
  FROM #ORDER_VALUE ov
  JOIN Employees     e ON e.EmployeeID = ov.EmployeeID

------------------------------------------------------------------------------------------------------------------------------------------
-- 39
------------------------------------------------------------------------------------------------------------------------------------------

--## TOTAL DE VENDAS POR TRIMESTRE, COMPARADO COM O TRIMESTRE ANTERIOR ##--

;WITH QuarterSales39CTE AS
(
  SELECT YEAR(OrderDate)              AS [Year],
         DATEPART(QUARTER, OrderDate) AS [Quarter],
         SUM(OrderValue)              AS TotalQuarter
    FROM #ORDER_VALUE
GROUP BY YEAR(OrderDate), DATEPART(QUARTER, OrderDate)
)
SELECT [Year],
       [Quarter],
       TotalQuarter,
       ISNULL(LAG(TotalQuarter) OVER (ORDER BY [Year], [Quarter]), 0)                AS LastTotalQuarter,
       ISNULL(TotalQuarter - LAG(TotalQuarter) OVER (ORDER BY [Year], [Quarter]), 0) AS DiffLastQuarter
  FROM QuarterSales39CTE

------------------------------------------------------------------------------------------------------------------------------------------
-- 40
------------------------------------------------------------------------------------------------------------------------------------------

SELECT OrderID,
       CustomerID,
       YEAR(OrderDate)  AS [Year],
       MONTH(OrderDate) AS [Month],
       OrderValue,
       SUM(OrderValue) OVER (PARTITION BY YEAR(OrderDate), MONTH(OrderDate) ORDER BY OrderDate, OrderID ROWS UNBOUNDED PRECEDING) AS TotalMonth
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 41
------------------------------------------------------------------------------------------------------------------------------------------

--## PERCENT_RANK: POSICAO PERCENTUAL DO PEDIDO ENTRE TODOS (0 = MENOR VALOR, 1 = MAIOR VALOR) ##--

SELECT OrderID,
       CustomerID,
       OrderValue,
       CAST(PERCENT_RANK() OVER (ORDER BY OrderValue) * 100 AS DECIMAL(5,2))    AS Percentile,
       CAST(OrderValue * 100.0 / SUM(OrderValue) OVER () AS DECIMAL(5,2))       AS PctOfTotalSales
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 42
------------------------------------------------------------------------------------------------------------------------------------------

--## VENDAS TOTALIZADAS POR PRODUTO; ACIMA DO PERCENTIL 90 = PERCENT_RANK >= 0.9 DENTRO DA CATEGORIA ##--

;WITH PercentileCTE AS
(
	  SELECT p.ProductName,
	         c.CategoryName,
	         SUM(od.Quantity * od.UnitPrice)                                                          AS TotalSales,
	         PERCENT_RANK() OVER (PARTITION BY c.CategoryID ORDER BY SUM(od.Quantity * od.UnitPrice)) AS PctRank
	    FROM Products         p
	    JOIN Categories       c ON c.CategoryID = p.CategoryID
	    JOIN [Order Details] od ON od.ProductID = p.ProductID
	GROUP BY c.CategoryID, c.CategoryName, p.ProductName
)
SELECT ProductName,
       CategoryName,
	   TotalSales,
	   PctRank
  FROM PercentileCTE
 WHERE PctRank >= 0.9

--## PENDENTE: EXERCICIOS 43 A 100 ##--

