
USE Northwind
GO

-- Valor de cada pedido e dado pela soma dos itens, considerando o desconto
-- Usado nesta lista sempre que o enunciado nesta lista sempre que o enunciado fala em "VALOR DO PEDIDO" ou "VENDAS". FREIGHT e apenas o frete

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
       CAST(OrderDate AS DATE)                                                                     AS OrderDate,
       OrderValue,
       AVG(OrderValue) OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID ROWS 2 PRECEDING) AS MediaMovel
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 03
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT p.CategoryID,
         p.ProductName,
         SUM(od.Quantity * od.UnitPrice)                                                                                       AS TotalProduct,
         SUM(SUM(od.Quantity * od.UnitPrice)) OVER (PARTITION BY p.CategoryID ORDER BY p.ProductName ROWS UNBOUNDED PRECEDING) AS TotalPrice
    FROM [Order Details] od
    JOIN Products        p  ON p.ProductID = od.ProductID
GROUP BY p.CategoryID, p.ProductName
ORDER BY p.CategoryID, p.ProductName

------------------------------------------------------------------------------------------------------------------------------------------
-- 04
------------------------------------------------------------------------------------------------------------------------------------------

    SELECT p.CategoryID,
           p.ProductName,
           SUM(od.Quantity * od.UnitPrice)                                                                                 AS TotalSales,
           SUM(SUM(od.Quantity * od.UnitPrice)) OVER (PARTITION BY p.CategoryID)                                           AS TotalCategory,
           SUM(od.Quantity * od.UnitPrice) * 100.0 / SUM(SUM(od.Quantity * od.UnitPrice)) OVER (PARTITION BY p.CategoryID) AS PctContribution
    FROM Products        p
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
    FROM Products        p
    JOIN Categories      c  ON c.CategoryID = p.CategoryID
    JOIN [Order Details] od ON od.ProductID = p.ProductID
GROUP BY c.CategoryName, p.ProductName

------------------------------------------------------------------------------------------------------------------------------------------
-- 10
------------------------------------------------------------------------------------------------------------------------------------------

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
    FROM Products        p
    JOIN Categories      c  ON c.CategoryID = p.CategoryID
    JOIN [Order Details] od ON od.ProductID = p.ProductID
GROUP BY c.CategoryName, p.ProductName

------------------------------------------------------------------------------------------------------------------------------------------
-- 12
------------------------------------------------------------------------------------------------------------------------------------------

SELECT CustomerID,
       MIN(OrderValue)                   AS MinOrderValue,
       MAX(OrderValue)                   AS MaxOrderValue,
       MAX(OrderValue) - MIN(OrderValue) AS DifferenceOrderValue
  FROM #ORDER_VALUE
GROUP BY CustomerID

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
         ISNULL(ShipRegion, 'Nao informado')                                                               AS ShipRegion,
         SUM(OrderValue)                                                                                  AS TotalSales,
         SUM(SUM(OrderValue)) OVER (PARTITION BY ShipRegion ORDER BY EmployeeID ROWS UNBOUNDED PRECEDING) AS TotalByRegion
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
  FROM Products        p
  JOIN [Order Details] od ON od.ProductID = p.ProductID
  JOIN Categories      c  ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryName,
       p.ProductName
)
SELECT *
  FROM RankCategoryCTE
 WHERE Ranking <= 3

------------------------------------------------------------------------------------------------------------------------------------------
-- 17
------------------------------------------------------------------------------------------------------------------------------------------

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
       LAG(TotalMonthSales) OVER (ORDER BY [Year], [Month])                                         AS LastMonthSales,
       CAST((TotalMonthSales - LAG(TotalMonthSales) OVER (ORDER BY [Year], [Month])) * 100.0
                / NULLIF(LAG(TotalMonthSales) OVER (ORDER BY [Year], [Month]), 0) AS DECIMAL(10,2)) AS DiferencaPercentual
  FROM MonthSales17CTE

------------------------------------------------------------------------------------------------------------------------------------------
-- 18
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT YEAR(OrderDate)                                                   AS [Year],
         CustomerID,
         COUNT(*)                                                          AS QtyOrders,
         RANK() OVER (PARTITION BY YEAR(OrderDate) ORDER BY COUNT(*) DESC) AS AnualRanking
    FROM Orders
GROUP BY YEAR(OrderDate), CustomerID

------------------------------------------------------------------------------------------------------------------------------------------
-- 19
------------------------------------------------------------------------------------------------------------------------------------------

SELECT EmployeeID,
       YEAR(OrderDate)                                                                                                      AS [Year],
       OrderID,
       SUM(OrderValue) OVER (PARTITION BY EmployeeID, YEAR(OrderDate) ORDER BY OrderDate, OrderID ROWS UNBOUNDED PRECEDING) AS YearAcumulatedTotal
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 20
------------------------------------------------------------------------------------------------------------------------------------------

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

;WITH MonthSold23CTE AS
(
  SELECT od.ProductID,
         DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1) AS SalesMonth,
         SUM(od.Quantity)                                        AS QtySold
    FROM [Order Details] od
    JOIN Orders          o  ON o.OrderID = od.OrderID
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

;WITH PriceHistory24CTE AS
(
  SELECT od.ProductID,
         od.UnitPrice,
         MIN(o.OrderDate) AS FirstOrderDate
    FROM [Order Details] od
    JOIN Orders          o  ON o.OrderID = od.OrderID
GROUP BY od.ProductID, od.UnitPrice
)
SELECT p.ProductName,
       CAST(h.FirstOrderDate AS DATE)                                                                      AS PriceSince,
       h.UnitPrice,
       ISNULL(LAG(h.UnitPrice) OVER (PARTITION BY h.ProductID ORDER BY h.FirstOrderDate), 0)               AS LastPrice,
       ISNULL(h.UnitPrice - LAG(h.UnitPrice) OVER (PARTITION BY h.ProductID ORDER BY h.FirstOrderDate), 0) AS DiffLastPrice
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
			LAG(SUM(OrderValue)) OVER (ORDER BY YEAR(OrderDate), MONTH(OrderDate))               AS PctGrowning
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
  FROM Orders          o
  JOIN [Order Details] od ON od.OrderID  = o.OrderID
  JOIN Products        p  ON p.ProductID = od.ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 29
------------------------------------------------------------------------------------------------------------------------------------------

;WITH DaysBetween29CTE AS
(
SELECT CustomerID,
       OrderID,
       DATEDIFF(DAY, LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID), OrderDate) AS DaysSinceLastOrder
  FROM Orders
)
  SELECT CustomerID,
         COUNT(*)                                                              AS QtyOrders,
         CAST(AVG(CAST(DaysSinceLastOrder AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS AvgDaysBetweenOrders
    FROM DaysBetween29CTE
GROUP BY CustomerID

------------------------------------------------------------------------------------------------------------------------------------------
-- 30
------------------------------------------------------------------------------------------------------------------------------------------

SELECT CustomerID,
       OrderID,
       OrderValue                                                                            AS ActualValue,
       ISNULL(LAG(OrderValue) OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID), 0) AS LastValue,
       CASE WHEN OrderValue > LAG(OrderValue) OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID) THEN 'High'
            ELSE 'Less or equal'
             END                                                                             AS Comparison
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 31
------------------------------------------------------------------------------------------------------------------------------------------

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

;WITH QuarterSales32CTE AS
(
  SELECT EmployeeID,
         YEAR(OrderDate)              AS [Year],
         DATEPART(QUARTER, OrderDate) AS [Quarter],
         SUM(OrderValue)              AS TotalQuarter
    FROM #ORDER_VALUE
GROUP BY EmployeeID, YEAR(OrderDate), DATEPART(QUARTER, OrderDate)
)
SELECT e.FirstName + ' ' + e.LastName                                                      AS FullName,
       q.[Year],
       q.[Quarter],
       q.TotalQuarter                                                                      AS TotalActualQuarter,
       LAG(q.TotalQuarter) OVER (PARTITION BY q.EmployeeID ORDER BY q.[Year], q.[Quarter]) AS TotalLastQuarter
  FROM QuarterSales32CTE q
  JOIN Employees         e ON e.EmployeeID = q.EmployeeID

------------------------------------------------------------------------------------------------------------------------------------------
-- 33
------------------------------------------------------------------------------------------------------------------------------------------

    SELECT ov.CustomerID,
           ov.OrderID,
           CAST(ov.OrderDate AS DATE) AS OrderDate,
           w.Total30Days
      FROM #ORDER_VALUE ov
CROSS APPLY (SELECT SUM(ov2.OrderValue) AS Total30Days
               FROM #ORDER_VALUE ov2
              WHERE ov2.CustomerID = ov.CustomerID
                AND ov2.OrderDate > DATEADD(DAY, -30, ov.OrderDate)
                AND ov2.OrderDate <= ov.OrderDate) w

------------------------------------------------------------------------------------------------------------------------------------------
-- 34
------------------------------------------------------------------------------------------------------------------------------------------

SELECT DISTINCT
       CustomerID,
       YEAR(OrderDate)                                                              AS [Year],
       CAST(MIN(OrderDate) OVER (PARTITION BY CustomerID, YEAR(OrderDate)) AS DATE) AS FirstOrder,
       CAST(MAX(OrderDate) OVER (PARTITION BY CustomerID, YEAR(OrderDate)) AS DATE) AS LastOrder
  FROM Orders

------------------------------------------------------------------------------------------------------------------------------------------
-- 35
------------------------------------------------------------------------------------------------------------------------------------------

;WITH SeasonSales35CTE AS
(
  SELECT od.ProductID,
         CASE WHEN MONTH(o.OrderDate) IN (12, 1, 2) THEN 'Winter'
              WHEN MONTH(o.OrderDate) IN (3, 4, 5)  THEN 'Spring'
              WHEN MONTH(o.OrderDate) IN (6, 7, 8)  THEN 'Summer'
              ELSE 'Autumn'
               END                  AS Season,
         od.Quantity * od.UnitPrice AS SaleValue
    FROM [Order Details] od
    JOIN Orders          o  ON o.OrderID = od.OrderID
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

    SELECT ov.CustomerID,
           ov.OrderID,
           CAST(ov.OrderDate AS DATE) AS OrderDate,
           w.Total7Days
      FROM #ORDER_VALUE ov
CROSS APPLY (SELECT SUM(ov2.OrderValue) AS Total7Days
               FROM #ORDER_VALUE ov2
              WHERE ov2.CustomerID = ov.CustomerID
                AND ov2.OrderDate > DATEADD(DAY, -7, ov.OrderDate)
                AND ov2.OrderDate <= ov.OrderDate) w

------------------------------------------------------------------------------------------------------------------------------------------
-- 37
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT CustomerID,
         YEAR(OrderDate)                                                     AS [Year],
         DATEPART(WEEK, OrderDate)                                           AS [Week],
         SUM(OrderValue)                                                     AS TotalWeek,
         RANK() OVER (PARTITION BY CustomerID ORDER BY SUM(OrderValue) DESC) AS WeekRanking
    FROM #ORDER_VALUE
GROUP BY CustomerID, YEAR(OrderDate), DATEPART(WEEK, OrderDate)

------------------------------------------------------------------------------------------------------------------------------------------
-- 38
------------------------------------------------------------------------------------------------------------------------------------------

SELECT ov.OrderID,
       e.FirstName + ' ' + e.LastName                                                                           AS FullName,
       CAST(ov.OrderDate AS DATE)                                                                               AS OrderDate,
       YEAR(ov.OrderDate)                                                                                       AS [Year],
       DATEPART(QUARTER, ov.OrderDate)                                                                          AS [Quarter],
       SUM(ov.OrderValue) OVER (PARTITION BY ov.EmployeeID, YEAR(ov.OrderDate), DATEPART(QUARTER, ov.OrderDate)
                                    ORDER BY ov.OrderDate, ov.OrderID ROWS UNBOUNDED PRECEDING)                 AS TotalQuarter
  FROM #ORDER_VALUE ov
  JOIN Employees    e  ON e.EmployeeID = ov.EmployeeID

------------------------------------------------------------------------------------------------------------------------------------------
-- 39
------------------------------------------------------------------------------------------------------------------------------------------

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
       YEAR(OrderDate)                                                                                                            AS [Year],
       MONTH(OrderDate)                                                                                                           AS [Month],
       OrderValue,
       SUM(OrderValue) OVER (PARTITION BY YEAR(OrderDate), MONTH(OrderDate) ORDER BY OrderDate, OrderID ROWS UNBOUNDED PRECEDING) AS TotalMonth
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 41
------------------------------------------------------------------------------------------------------------------------------------------

SELECT OrderID,
       CustomerID,
       OrderValue,
       CAST(PERCENT_RANK() OVER (ORDER BY OrderValue) * 100 AS DECIMAL(5,2)) AS Percentile,
       CAST(OrderValue * 100.0 / SUM(OrderValue) OVER () AS DECIMAL(5,2))    AS PctOfTotalSales
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 42
------------------------------------------------------------------------------------------------------------------------------------------

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

------------------------------------------------------------------------------------------------------------------------------------------
-- 43
------------------------------------------------------------------------------------------------------------------------------------------

;WITH EmployeeRegion43CTE AS
(
  SELECT EmployeeID,
         ISNULL(ShipRegion, 'Nao informado') AS ShipRegion,
         SUM(OrderValue)                    AS TotalSales
    FROM #ORDER_VALUE
GROUP BY EmployeeID, ISNULL(ShipRegion, 'Nao informado')
)
SELECT e.FirstName + ' ' + e.LastName                                                                    AS FullName,
       r.ShipRegion,
       r.TotalSales,
       CAST(PERCENT_RANK() OVER (PARTITION BY r.ShipRegion ORDER BY r.TotalSales) * 100 AS DECIMAL(5,2)) AS Percentile
  FROM EmployeeRegion43CTE r
  JOIN Employees           e ON e.EmployeeID = r.EmployeeID

------------------------------------------------------------------------------------------------------------------------------------------
-- 44
------------------------------------------------------------------------------------------------------------------------------------------

;WITH TopOrders44CTE AS
(
SELECT CustomerID,
       OrderValue,
       ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderValue DESC, OrderID) AS Ranking
  FROM #ORDER_VALUE
),
TwoHighest44CTE AS
(
  SELECT CustomerID,
         MAX(CASE WHEN Ranking = 1 THEN OrderValue END) AS HighestOrder,
         MAX(CASE WHEN Ranking = 2 THEN OrderValue END) AS SecondOrder
    FROM TopOrders44CTE
   WHERE Ranking <= 2
GROUP BY CustomerID
)
SELECT CustomerID,
       HighestOrder,
       SecondOrder,
       CAST((HighestOrder - SecondOrder) * 100.0 / NULLIF(SecondOrder, 0) AS DECIMAL(10,2)) AS PctDiff
  FROM TwoHighest44CTE
 WHERE SecondOrder IS NOT NULL

------------------------------------------------------------------------------------------------------------------------------------------
-- 45
------------------------------------------------------------------------------------------------------------------------------------------

SELECT OrderID,
       CustomerID,
       OrderValue,
       CAST(PERCENT_RANK() OVER (PARTITION BY CustomerID ORDER BY OrderValue) * 100 AS DECIMAL(5,2)) AS PercentRank
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 46
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CategorySales46CTE AS
(
SELECT p.CategoryID,
       od.OrderID,
       ((od.UnitPrice * od.Quantity) * (1 - od.Discount))                                                      AS LineValue,
       PERCENT_RANK() OVER (PARTITION BY p.CategoryID ORDER BY od.UnitPrice * od.Quantity * (1 - od.Discount)) AS PctRank
  FROM [Order Details] od
  JOIN Products        p  ON p.ProductID = od.ProductID
)
  SELECT c.CategoryName,
         CAST(AVG(s.LineValue) AS DECIMAL(10,2)) AS AvgAboveP50
    FROM CategorySales46CTE s
    JOIN Categories         c ON c.CategoryID = s.CategoryID
   WHERE s.PctRank > 0.5
GROUP BY c.CategoryName

------------------------------------------------------------------------------------------------------------------------------------------
-- 47
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT p.ProductName,
         CAST(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS DECIMAL(10,2))                             AS TotalSales,
         CAST(CUME_DIST() OVER (ORDER BY SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))) AS DECIMAL(10,4)) AS CumeDist
    FROM Products        p
    JOIN [Order Details] od ON od.ProductID = p.ProductID
GROUP BY p.ProductName

------------------------------------------------------------------------------------------------------------------------------------------
-- 48
------------------------------------------------------------------------------------------------------------------------------------------

;WITH EmployeeRegion48CTE AS
(
  SELECT EmployeeID,
         ISNULL(ShipRegion, 'Nao informado')                                                             AS ShipRegion,
         CAST(SUM(OrderValue) AS DECIMAL(10,2))                                                         AS TotalSales,
         PERCENT_RANK() OVER (PARTITION BY ISNULL(ShipRegion, 'Nao informado') ORDER BY SUM(OrderValue)) AS PctRank
    FROM #ORDER_VALUE
GROUP BY EmployeeID, ISNULL(ShipRegion, 'Nao informado')
)
SELECT e.FirstName + ' ' + e.LastName AS FullName,
       r.ShipRegion,
       r.TotalSales,
       r.PctRank
  FROM EmployeeRegion48CTE r
  JOIN Employees           e ON e.EmployeeID = r.EmployeeID
 WHERE r.PctRank >= 0.9

------------------------------------------------------------------------------------------------------------------------------------------
-- 49
------------------------------------------------------------------------------------------------------------------------------------------

;WITH Percentile49CTE AS
(
SELECT OrderID,
       OrderValue,
       PERCENT_RANK() OVER (ORDER BY OrderValue) AS PctRank
  FROM #ORDER_VALUE
)
SELECT AVG(OrderValue) AS AvgBelowP25
  FROM Percentile49CTE
 WHERE PctRank < 0.25

------------------------------------------------------------------------------------------------------------------------------------------
-- 50
------------------------------------------------------------------------------------------------------------------------------------------

SELECT OrderID,
       CustomerID,
       CAST(OrderValue AS DECIMAL(10,2))                                                          AS OrderValue,
       CAST(OrderValue * 100.0 / SUM(OrderValue) OVER (PARTITION BY CustomerID) AS DECIMAL(10,2)) AS PctOfCustomer
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 51
------------------------------------------------------------------------------------------------------------------------------------------

;WITH ProductSales51CTE AS
(
  SELECT p.ProductName,
         SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
    FROM Products        p
    JOIN [Order Details] od ON od.ProductID = p.ProductID
GROUP BY p.ProductName
),
Running51CTE AS
(
SELECT ProductName,
       TotalSales,
       SUM(TotalSales) OVER (ORDER BY TotalSales DESC ROWS UNBOUNDED PRECEDING) AS AcumSales,
       SUM(TotalSales) OVER ()                                                  AS GrandTotal
  FROM ProductSales51CTE
),
-- Inclui o produto que faz o acumulado ultrapassar 10% do total
Threshold51CTE AS
(
SELECT ProductName,
       TotalSales,
       AcumSales,
       GrandTotal,
       LAG(AcumSales, 1, 0) OVER (ORDER BY TotalSales DESC) AS PreviousAcum
  FROM Running51CTE
)
SELECT ProductName,
       CAST(TotalSales AS DECIMAL(10,2))                     AS TotalSales,
       CAST(AcumSales AS DECIMAL(10,2))                      AS AcumSales,
       CAST(AcumSales * 100.0 / GrandTotal AS DECIMAL(10,2)) AS PctAcum
  FROM Threshold51CTE
 WHERE PreviousAcum < GrandTotal * 0.10

------------------------------------------------------------------------------------------------------------------------------------------
-- 52
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @Year52    INT,
        @Quarter52 INT

SELECT @Year52    = YEAR(MAX(OrderDate)),
       @Quarter52 = DATEPART(QUARTER, MAX(OrderDate))
  FROM #ORDER_VALUE

SELECT CustomerID,
       OrderID,
       CAST(OrderDate AS DATE)                                                                                                    AS OrderDate,
       CAST(OrderValue AS DECIMAL(10,2))                                                                                          AS OrderValue,
       CAST(SUM(OrderValue) OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID ROWS UNBOUNDED PRECEDING) AS DECIMAL(10,2)) AS AcumQuarter
  FROM #ORDER_VALUE
 WHERE YEAR(OrderDate) = @Year52
   AND DATEPART(QUARTER, OrderDate) = @Quarter52

------------------------------------------------------------------------------------------------------------------------------------------
-- 53
------------------------------------------------------------------------------------------------------------------------------------------

;WITH AboveAvg53CTE AS
(
SELECT CustomerID,
       OrderID,
       OrderValue,
       AVG(OrderValue) OVER (PARTITION BY CustomerID) AS AvgCustomer
  FROM #ORDER_VALUE
)
  SELECT CustomerID,
         COUNT(*) AS QtyOrdersAboveAvg
    FROM AboveAvg53CTE
   WHERE OrderValue > AvgCustomer
GROUP BY CustomerID

------------------------------------------------------------------------------------------------------------------------------------------
-- 54
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT p.ProductName,
         SUM(od.Quantity)                             AS QtySold,
         RANK() OVER (ORDER BY SUM(od.Quantity) DESC) AS Ranking
    FROM Products        p
    JOIN Categories      c  ON c.CategoryID = p.CategoryID
    JOIN [Order Details] od ON od.ProductID = p.ProductID
   WHERE c.CategoryName = 'Beverages'
GROUP BY p.ProductName

------------------------------------------------------------------------------------------------------------------------------------------
-- 55
------------------------------------------------------------------------------------------------------------------------------------------

;WITH Customers55CTE AS
(
  SELECT o.CustomerID
    FROM Orders          o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY o.CustomerID
  HAVING COUNT(DISTINCT od.ProductID) > 5
)
SELECT o.OrderID,
       o.CustomerID,
       CAST(o.OrderDate AS DATE) AS OrderDate
  FROM Orders          o
  JOIN Customers55CTE  c ON c.CustomerID = o.CustomerID

------------------------------------------------------------------------------------------------------------------------------------------
-- 56
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CustomerRegion56CTE AS
(
  SELECT ISNULL(ShipRegion, 'Nao informado')                                                          AS ShipRegion,
         CustomerID,
         SUM(OrderValue)                                                                             AS TotalSales,
         RANK() OVER (PARTITION BY ISNULL(ShipRegion, 'Nao informado') ORDER BY SUM(OrderValue) DESC) AS Ranking
    FROM #ORDER_VALUE
GROUP BY ISNULL(ShipRegion, 'Nao informado'), CustomerID
)
SELECT v.ShipRegion,
       v.CustomerID,
       v.OrderID,
       CAST(v.OrderValue AS DECIMAL(10,2))                                                                                                AS OrderValue,
       CAST(SUM(v.OrderValue) OVER (PARTITION BY v.ShipRegion ORDER BY v.OrderDate, v.OrderID ROWS UNBOUNDED PRECEDING) AS DECIMAL(10,2)) AS AcumTop3
  FROM (SELECT ISNULL(ShipRegion, 'Nao informado') AS ShipRegion,
               CustomerID,
               OrderID,
               OrderDate,
               OrderValue
          FROM #ORDER_VALUE) v
  JOIN CustomerRegion56CTE   c ON c.ShipRegion = v.ShipRegion
                              AND c.CustomerID = v.CustomerID
 WHERE c.Ranking <= 3

------------------------------------------------------------------------------------------------------------------------------------------
-- 57
------------------------------------------------------------------------------------------------------------------------------------------

;WITH LastMonth57CTE AS
(
  SELECT YEAR(OrderDate)                                                           AS [Year],
         MONTH(OrderDate)                                                          AS [Month],
         RANK() OVER (PARTITION BY YEAR(OrderDate) ORDER BY MONTH(OrderDate) DESC) AS MonthRank
    FROM #ORDER_VALUE
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
),
ProductYear57CTE AS
(
  SELECT YEAR(o.OrderDate)                                                           AS [Year],
         MONTH(o.OrderDate)                                                          AS [Month],
         p.ProductName,
         SUM(od.Quantity)                                                            AS QtySold,
         RANK() OVER (PARTITION BY YEAR(o.OrderDate) ORDER BY SUM(od.Quantity) DESC) AS Ranking
    FROM [Order Details] od
    JOIN Orders          o  ON o.OrderID = od.OrderID
    JOIN Products        p  ON p.ProductID = od.ProductID
    JOIN LastMonth57CTE  m  ON m.[Year] = YEAR(o.OrderDate) AND m.[Month] = MONTH(o.OrderDate) AND m.MonthRank = 1
GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate), p.ProductName
)
SELECT [Year],
       [Month],
       ProductName,
       QtySold
  FROM ProductYear57CTE
 WHERE Ranking = 1

------------------------------------------------------------------------------------------------------------------------------------------
-- 58
------------------------------------------------------------------------------------------------------------------------------------------

;WITH ProductCategory58CTE AS
(
  SELECT c.CategoryName,
         p.ProductName,
         SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))                                                         AS TotalSales,
         RANK() OVER (PARTITION BY c.CategoryName ORDER BY SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) DESC) AS Ranking
    FROM Products        p
    JOIN Categories      c  ON c.CategoryID = p.CategoryID
    JOIN [Order Details] od ON od.ProductID = p.ProductID
GROUP BY c.CategoryName, p.ProductName
)
  SELECT CategoryName,
         CAST(AVG(TotalSales) AS DECIMAL(10,2)) AS AvgTop5
    FROM ProductCategory58CTE
   WHERE Ranking <= 5
GROUP BY CategoryName

------------------------------------------------------------------------------------------------------------------------------------------
-- 59
------------------------------------------------------------------------------------------------------------------------------------------

-- Foi adotado o ano de 1997
;WITH EmployeeYear59CTE AS
(
  SELECT EmployeeID,
         CAST(SUM(OrderValue) AS DECIMAL(10,2))      AS TotalSales,
         RANK() OVER (ORDER BY SUM(OrderValue) DESC) AS Ranking
    FROM #ORDER_VALUE
   WHERE YEAR(OrderDate) = 1997
GROUP BY EmployeeID
)
SELECT e.FirstName + ' ' + e.LastName AS FullName,
       y.TotalSales
  FROM EmployeeYear59CTE y
  JOIN Employees         e ON e.EmployeeID = y.EmployeeID
 WHERE y.Ranking = 1

------------------------------------------------------------------------------------------------------------------------------------------
-- 60
------------------------------------------------------------------------------------------------------------------------------------------

-- Como nao ha uma coluna VIP, foi adotado o TOP 10 de clientes pelo valor total de pedidos
;WITH Vip60CTE AS
(
  SELECT CustomerID,
         SUM(OrderValue) AS TotalSales,
         ROW_NUMBER() OVER (ORDER BY SUM(OrderValue) DESC) AS Ranking
    FROM #ORDER_VALUE
GROUP BY CustomerID
)
SELECT v.CustomerID,
       o.OrderID,
       CAST(o.OrderValue AS DECIMAL(10,2))                                                                                                AS OrderValue,
       CAST(SUM(o.OrderValue) OVER (PARTITION BY v.CustomerID ORDER BY o.OrderDate, o.OrderID ROWS UNBOUNDED PRECEDING) AS DECIMAL(10,2)) AS AcumVip
  FROM #ORDER_VALUE o
  JOIN Vip60CTE     v ON v.CustomerID = o.CustomerID
 WHERE v.Ranking <= 10

------------------------------------------------------------------------------------------------------------------------------------------
-- 61
------------------------------------------------------------------------------------------------------------------------------------------

SELECT EmployeeID,
       ISNULL(ShipRegion, 'Nao informado')                                                                     AS ShipRegion,
       YEAR(OrderDate)                                                                                         AS [Year],
       OrderID,
       CAST(SUM(OrderValue) OVER (PARTITION BY EmployeeID, ISNULL(ShipRegion, 'Nao informado'), YEAR(OrderDate)
                                 ORDER BY OrderDate, OrderID ROWS UNBOUNDED PRECEDING) AS DECIMAL(10,2))       AS AcumSales
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 62
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT o.CustomerID,
         p.ProductName,
         CAST(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS DECIMAL(10,2))                                       AS TotalSales,
         CAST(SUM(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))) OVER (PARTITION BY o.CustomerID) AS DECIMAL(10,2)) AS TotalCustomer
    FROM Orders          o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    JOIN Products        p  ON p.ProductID = od.ProductID
GROUP BY o.CustomerID, p.ProductName

------------------------------------------------------------------------------------------------------------------------------------------
-- 63
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT YEAR(o.OrderDate)                                                                                                  AS [Year],
         MONTH(o.OrderDate)                                                                                                 AS [Month],
         c.CategoryName,
         od.OrderID,
         CAST(SUM(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))) OVER (PARTITION BY YEAR(o.OrderDate), MONTH(o.OrderDate), c.CategoryID
                                                            ORDER BY od.OrderID ROWS UNBOUNDED PRECEDING) AS DECIMAL(10,2)) AS AcumMonthCategory
    FROM Orders          o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    JOIN Products        p  ON p.ProductID = od.ProductID
    JOIN Categories      c  ON c.CategoryID = p.CategoryID
GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate), c.CategoryID, c.CategoryName, od.OrderID

------------------------------------------------------------------------------------------------------------------------------------------
-- 64
------------------------------------------------------------------------------------------------------------------------------------------

SELECT ISNULL(ShipRegion, 'Nao informado')                                                                              AS ShipRegion,
       OrderID,
       CAST(OrderValue AS DECIMAL(10,2))                                                                                AS OrderValue,
       CAST(SUM(OrderValue) OVER (PARTITION BY ShipRegion ORDER BY OrderDate, OrderID ROWS UNBOUNDED PRECEDING) * 100.0
            / SUM(OrderValue) OVER (PARTITION BY ShipRegion) AS DECIMAL(10,2))                                          AS PctAcum
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 65
------------------------------------------------------------------------------------------------------------------------------------------

-- Como o banco Northwind nao tem uma tabela de subcategorias, vou usar a de Categorias mesmo
  SELECT c.CategoryName,
         p.ProductName,
         CAST(AVG(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))) OVER (PARTITION BY c.CategoryID) AS DECIMAL(10,2)) AS AvgCategorySales
    FROM Products        p
    JOIN Categories      c  ON c.CategoryID = p.CategoryID
    JOIN [Order Details] od ON od.ProductID = p.ProductID
GROUP BY c.CategoryID, c.CategoryName, p.ProductName

------------------------------------------------------------------------------------------------------------------------------------------
-- 66
------------------------------------------------------------------------------------------------------------------------------------------

;WITH YearSales66CTE AS
(
  SELECT CustomerID,
         YEAR(OrderDate) AS [Year],
         SUM(OrderValue) AS TotalYear
    FROM #ORDER_VALUE
GROUP BY CustomerID, YEAR(OrderDate)
),
Growth66CTE AS
(
SELECT CustomerID,
       [Year],
       TotalYear,
       (TotalYear - LAG(TotalYear) OVER (PARTITION BY CustomerID ORDER BY [Year])) * 100.0
           / NULLIF(LAG(TotalYear) OVER (PARTITION BY CustomerID ORDER BY [Year]), 0) AS PctGrowth
  FROM YearSales66CTE
),
RankGrowth66CTE AS
(
SELECT CustomerID,
       [Year],
       TotalYear,
       PctGrowth,
       RANK() OVER (PARTITION BY [Year] ORDER BY PctGrowth DESC) AS Ranking
  FROM Growth66CTE
 WHERE PctGrowth IS NOT NULL
)
SELECT CustomerID,
       [Year],
       CAST(TotalYear AS DECIMAL(10,2)) AS TotalYear,
       CAST(PctGrowth AS DECIMAL(10,2)) AS PctGrowth
  FROM RankGrowth66CTE
 WHERE Ranking = 1

------------------------------------------------------------------------------------------------------------------------------------------
-- 67
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT e.FirstName + ' ' + e.LastName                                                                            AS FullName,
         c.CategoryName,
         CAST(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS DECIMAL(10,2))                                AS TotalSales,
         RANK() OVER (PARTITION BY c.CategoryID ORDER BY SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) DESC) AS Ranking
    FROM Orders          o
    JOIN Employees       e  ON e.EmployeeID = o.EmployeeID
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    JOIN Products        p  ON p.ProductID = od.ProductID
    JOIN Categories      c  ON c.CategoryID = p.CategoryID
GROUP BY e.FirstName, e.LastName, c.CategoryID, c.CategoryName

------------------------------------------------------------------------------------------------------------------------------------------
-- 68
------------------------------------------------------------------------------------------------------------------------------------------

SELECT CustomerID,
       YEAR(OrderDate)                                                                                   AS [Year],
       DATEPART(QUARTER, OrderDate)                                                                      AS [Quarter],
       OrderID,
       CAST(SUM(OrderValue) OVER (PARTITION BY CustomerID, YEAR(OrderDate), DATEPART(QUARTER, OrderDate)
                                 ORDER BY OrderDate, OrderID ROWS UNBOUNDED PRECEDING) AS DECIMAL(10,2)) AS AcumQuarter
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 69
------------------------------------------------------------------------------------------------------------------------------------------

SELECT OrderID,
       YEAR(OrderDate)                                                                              AS [Year],
       MONTH(OrderDate)                                                                             AS [Month],
       CAST(OrderValue AS DECIMAL(10,2))                                                            AS OrderValue,
       CAST(AVG(OrderValue) OVER (PARTITION BY YEAR(OrderDate), MONTH(OrderDate)) AS DECIMAL(10,2)) AS AvgSameMonth
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 70
------------------------------------------------------------------------------------------------------------------------------------------

;WITH ProductRegion70CTE AS
(
  SELECT ISNULL(o.ShipRegion, 'Nao informado')                AS ShipRegion,
         p.ProductName,
         SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
    FROM Orders          o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    JOIN Products        p  ON p.ProductID = od.ProductID
GROUP BY ISNULL(o.ShipRegion, 'Nao informado'), p.ProductName
)
SELECT ShipRegion,
       ProductName,
       CAST(TotalSales AS DECIMAL(10,2))                                                                                       AS TotalSales,
       CAST(SUM(TotalSales) OVER (PARTITION BY ShipRegion ORDER BY TotalSales DESC ROWS UNBOUNDED PRECEDING) AS DECIMAL(10,2)) AS AcumSales,
       RANK() OVER (PARTITION BY ShipRegion ORDER BY TotalSales DESC)                                                          AS Ranking
  FROM ProductRegion70CTE

------------------------------------------------------------------------------------------------------------------------------------------
-- 71
------------------------------------------------------------------------------------------------------------------------------------------

SELECT e.FirstName + ' ' + e.LastName AS FullName,
       ov.OrderID,
       CAST(ov.OrderDate AS DATE)     AS OrderDate,
       CAST(SUM(ov.OrderValue) OVER (PARTITION BY ov.EmployeeID 
                                     ORDER BY ov.OrderDate, ov.OrderID ROWS UNBOUNDED PRECEDING) AS DECIMAL(10,2))                    AS AcumSales,
       CAST(AVG(ov.OrderValue) OVER (PARTITION BY ov.EmployeeID ORDER BY ov.OrderDate, ov.OrderID ROWS 2 PRECEDING) AS DECIMAL(10,2)) AS MovingAvg
  FROM #ORDER_VALUE ov
  JOIN Employees    e  ON e.EmployeeID = ov.EmployeeID

------------------------------------------------------------------------------------------------------------------------------------------
-- 72
------------------------------------------------------------------------------------------------------------------------------------------

;WITH ProductMonth72CTE AS
(
  SELECT od.ProductID,
         DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1) AS SalesMonth,
         SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))     AS TotalMonth
    FROM [Order Details] od
    JOIN Orders          o  ON o.OrderID = od.OrderID
GROUP BY od.ProductID, DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1)
),
Rolling72CTE AS
(
     SELECT m.ProductID,
            m.SalesMonth,
            w.Rolling6Months
       FROM ProductMonth72CTE m
CROSS APPLY (SELECT SUM(m2.TotalMonth) AS Rolling6Months
               FROM ProductMonth72CTE m2
              WHERE m2.ProductID  = m.ProductID
                AND m2.SalesMonth >  DATEADD(MONTH, -6, m.SalesMonth)
                AND m2.SalesMonth <= m.SalesMonth) w
)
SELECT p.ProductName,
       r.SalesMonth,
       CAST(r.Rolling6Months AS DECIMAL(10,2))                                AS Rolling6Months,
       RANK() OVER (PARTITION BY r.SalesMonth ORDER BY r.Rolling6Months DESC) AS Ranking
  FROM Rolling72CTE r
  JOIN Products     p ON p.ProductID = r.ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 73
------------------------------------------------------------------------------------------------------------------------------------------

SELECT OrderID,
       CustomerID,
       CAST(OrderValue AS DECIMAL(10,2))                                                                  AS OrderValue,
       CAST(SUM(OrderValue) OVER (ORDER BY OrderDate, OrderID ROWS UNBOUNDED PRECEDING) AS DECIMAL(10,2)) AS AcumSales,
       RANK() OVER (ORDER BY OrderValue DESC)                                                             AS Ranking
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 74
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CategorySales74CTE AS
(
  SELECT c.CategoryName,
         p.ProductName,
         SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
    FROM Products        p
    JOIN Categories      c  ON c.CategoryID = p.CategoryID
    JOIN [Order Details] od ON od.ProductID = p.ProductID
GROUP BY c.CategoryName, p.ProductName
)
SELECT CategoryName,
       ProductName,
       CAST(TotalSales AS DECIMAL(10,2))                                                                               AS TotalSales,
       CAST(SUM(TotalSales) OVER (PARTITION BY CategoryName ORDER BY TotalSales DESC ROWS UNBOUNDED PRECEDING) * 100.0
            / SUM(TotalSales) OVER (PARTITION BY CategoryName) AS DECIMAL(10,2))                                       AS PctAcum,
       CAST(AVG(TotalSales) OVER (PARTITION BY CategoryName) AS DECIMAL(10,2))                                         AS AvgCategory
  FROM CategorySales74CTE

------------------------------------------------------------------------------------------------------------------------------------------
-- 75
------------------------------------------------------------------------------------------------------------------------------------------

;WITH ProductMonth75CTE AS
(
  SELECT p.CategoryID,
         p.ProductID,
         p.ProductName,
         DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1) AS SalesMonth,
         SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))     AS TotalMonth
    FROM Products        p
    JOIN [Order Details] od ON od.ProductID = p.ProductID
    JOIN Orders          o  ON o.OrderID = od.OrderID
GROUP BY p.CategoryID, p.ProductID, p.ProductName, DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1)
)
     SELECT c.CategoryName,
            m.ProductName,
            m.SalesMonth,
            CAST(w.Sum3Months / 3 AS DECIMAL(10,2))                                          AS MovingAvg,
            RANK() OVER (PARTITION BY m.CategoryID, m.SalesMonth ORDER BY m.TotalMonth DESC) AS Ranking
       FROM ProductMonth75CTE m
       JOIN Categories        c ON c.CategoryID = m.CategoryID
CROSS APPLY (SELECT SUM(m2.TotalMonth) AS Sum3Months
               FROM ProductMonth75CTE m2
              WHERE m2.ProductID  = m.ProductID
                AND m2.SalesMonth >  DATEADD(MONTH, -3, m.SalesMonth)
                AND m2.SalesMonth <= m.SalesMonth) w

------------------------------------------------------------------------------------------------------------------------------------------
-- 76
------------------------------------------------------------------------------------------------------------------------------------------

;WITH YearCustomer76CTE AS
(
  SELECT CustomerID,
         YEAR(OrderDate) AS [Year],
         SUM(OrderValue) AS TotalYear
    FROM #ORDER_VALUE
GROUP BY CustomerID, YEAR(OrderDate)
)
SELECT CustomerID,
       [Year],
       CAST(TotalYear AS DECIMAL(10,2))                                                                              AS TotalYear,
       CAST(SUM(TotalYear) OVER (PARTITION BY CustomerID ORDER BY [Year] ROWS UNBOUNDED PRECEDING) AS DECIMAL(10,2)) AS AcumSales,
       CAST((TotalYear - LAG(TotalYear) OVER (PARTITION BY CustomerID ORDER BY [Year])) * 100.0
            / NULLIF(LAG(TotalYear) OVER (PARTITION BY CustomerID ORDER BY [Year]), 0) AS DECIMAL(10,2))             AS PctDiffYear
  FROM YearCustomer76CTE

------------------------------------------------------------------------------------------------------------------------------------------
-- 77
------------------------------------------------------------------------------------------------------------------------------------------

;WITH QuarterEmployee77CTE AS
(
  SELECT EmployeeID,
         ISNULL(ShipRegion, 'Nao informado')                AS ShipRegion,
         YEAR(OrderDate)                                    AS [Year],
         DATEPART(QUARTER, OrderDate)                       AS [Quarter],
         YEAR(OrderDate) * 4 + DATEPART(QUARTER, OrderDate) AS QuarterIdx,
         SUM(OrderValue)                                    AS TotalQuarter
    FROM #ORDER_VALUE
GROUP BY EmployeeID, ISNULL(ShipRegion, 'Nao informado'), YEAR(OrderDate), DATEPART(QUARTER, OrderDate)
)
     SELECT e.FirstName + ' ' + e.LastName                                                              AS FullName,
            q.ShipRegion,
            q.[Year],
            q.[Quarter],
            CAST(w.Sum4Quarters / 4 AS DECIMAL(10,2))                                                   AS MovingAvgQuarter,
            RANK() OVER (PARTITION BY q.ShipRegion, q.[Year], q.[Quarter] ORDER BY q.TotalQuarter DESC) AS Ranking
       FROM QuarterEmployee77CTE q
       JOIN Employees            e ON e.EmployeeID = q.EmployeeID
CROSS APPLY (SELECT SUM(q2.TotalQuarter) AS Sum4Quarters
               FROM QuarterEmployee77CTE q2
              WHERE q2.EmployeeID = q.EmployeeID
                AND q2.ShipRegion = q.ShipRegion
                AND q2.QuarterIdx >  q.QuarterIdx - 4
                AND q2.QuarterIdx <= q.QuarterIdx) w

------------------------------------------------------------------------------------------------------------------------------------------
-- 78
------------------------------------------------------------------------------------------------------------------------------------------

SELECT CustomerID,
       OrderID,
       CAST(OrderValue AS DECIMAL(10,2))                                                                                AS OrderValue,
       CAST(SUM(OrderValue) OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID ROWS UNBOUNDED PRECEDING) * 100.0
            / SUM(OrderValue) OVER (PARTITION BY CustomerID) AS DECIMAL(10,2))                                          AS PctAcum
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 79
------------------------------------------------------------------------------------------------------------------------------------------

SELECT OrderID,
       CustomerID,
       CAST(OrderDate AS DATE)                                                                            AS OrderDate,
       CAST(OrderValue AS DECIMAL(10,2))                                                                  AS OrderValue,
       CAST(SUM(OrderValue) OVER (ORDER BY OrderDate, OrderID ROWS UNBOUNDED PRECEDING) AS DECIMAL(10,2)) AS AcumSales,
       ROW_NUMBER() OVER (ORDER BY OrderDate DESC, OrderID DESC)                                          AS ReverseDateRank
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 80
------------------------------------------------------------------------------------------------------------------------------------------

    SELECT p.ProductName,
           o.OrderID,
           CAST(o.OrderDate AS DATE)          AS OrderDate,
           CAST(w.Sum90Days AS DECIMAL(10,2)) AS Sum90Days,
           CAST(w.Avg90Days AS DECIMAL(10,2)) AS Avg90Days
      FROM [Order Details] od
      JOIN Orders          o  ON o.OrderID = od.OrderID
      JOIN Products        p  ON p.ProductID = od.ProductID
CROSS APPLY (SELECT SUM(od2.UnitPrice * od2.Quantity * (1 - od2.Discount)) AS Sum90Days,
                    AVG(od2.UnitPrice * od2.Quantity * (1 - od2.Discount)) AS Avg90Days
               FROM [Order Details] od2
               JOIN Orders          o2  ON o2.OrderID = od2.OrderID
              WHERE od2.ProductID = od.ProductID
                AND o2.OrderDate > DATEADD(DAY, -90, o.OrderDate)
                AND o2.OrderDate <= o.OrderDate) w

------------------------------------------------------------------------------------------------------------------------------------------
-- 81
------------------------------------------------------------------------------------------------------------------------------------------

-- Como nao existe uma tabela de custos, vou adotar uma margem fixa de 30% sobre o valor vendido
  SELECT ISNULL(o.ShipRegion, 'Nao informado')                                                                                  AS ShipRegion,
         p.ProductName,
         o.OrderID,
         CAST(SUM(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount) * 0.30)) OVER (PARTITION BY p.ProductID, o.ShipRegion
                                                                                    ORDER BY o.OrderDate, o.OrderID
                                                                                    ROWS UNBOUNDED PRECEDING) AS DECIMAL(10,2)) AS AcumMargin
    FROM Orders          o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    JOIN Products        p  ON p.ProductID = od.ProductID
GROUP BY p.ProductID, p.ProductName, o.ShipRegion, o.OrderID, o.OrderDate

------------------------------------------------------------------------------------------------------------------------------------------
-- 82
------------------------------------------------------------------------------------------------------------------------------------------

SELECT c.CategoryName,
       p.ProductName,
       p.UnitsInStock,
       SUM(p.UnitsInStock) OVER (PARTITION BY p.CategoryID ORDER BY p.ProductName ROWS UNBOUNDED PRECEDING) AS AcumStock
  FROM Products   p
  JOIN Categories c ON c.CategoryID = p.CategoryID

------------------------------------------------------------------------------------------------------------------------------------------
-- 83
------------------------------------------------------------------------------------------------------------------------------------------

    SELECT ov.OrderID,
           ov.CustomerID,
           CAST(ov.OrderDate AS DATE)           AS OrderDate,
           CAST(w.MovingAvg15 AS DECIMAL(10,2)) AS MovingAvg15
      FROM #ORDER_VALUE ov
CROSS APPLY (SELECT AVG(ov2.OrderValue) AS MovingAvg15
               FROM #ORDER_VALUE ov2
              WHERE ov2.OrderDate > DATEADD(DAY, -15, ov.OrderDate)
                AND ov2.OrderDate <= ov.OrderDate) w

------------------------------------------------------------------------------------------------------------------------------------------
-- 84
------------------------------------------------------------------------------------------------------------------------------------------

-- Foi adotado o ano de 1997
;WITH ProductYear84CTE AS
(
  SELECT p.ProductName,
         SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
    FROM [Order Details] od
    JOIN Orders          o  ON o.OrderID = od.OrderID
    JOIN Products        p  ON p.ProductID = od.ProductID
   WHERE YEAR(o.OrderDate) = 1997
GROUP BY p.ProductName
)
SELECT ProductName,
       CAST(TotalSales AS DECIMAL(10,2))                                                     AS TotalSales,
       CAST(SUM(TotalSales) OVER (ORDER BY TotalSales DESC ROWS UNBOUNDED PRECEDING) * 100.0
            / SUM(TotalSales) OVER () AS DECIMAL(10,2))                                      AS PctAcum
  FROM ProductYear84CTE

------------------------------------------------------------------------------------------------------------------------------------------
-- 85
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT e.FirstName + ' ' + e.LastName                                                 AS FullName,
         YEAR(ov.OrderDate)                                                             AS [Year],
         CAST(SUM(ov.OrderValue) AS DECIMAL(10,2))                                      AS TotalSales,
         RANK() OVER (PARTITION BY YEAR(ov.OrderDate) ORDER BY SUM(ov.OrderValue) DESC) AS Ranking
    FROM #ORDER_VALUE ov
    JOIN Employees    e  ON e.EmployeeID = ov.EmployeeID
GROUP BY e.FirstName, e.LastName, YEAR(ov.OrderDate)

------------------------------------------------------------------------------------------------------------------------------------------
-- 86
------------------------------------------------------------------------------------------------------------------------------------------

;WITH Diff86CTE AS
(
SELECT CustomerID,
       OrderID,
       OrderDate,
       OrderValue,
       OrderValue - ISNULL(LAG(OrderValue) OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID), OrderValue) AS DiffPrev
  FROM #ORDER_VALUE
)
SELECT CustomerID,
       OrderID,
       CAST(OrderValue AS DECIMAL(10,2))                                                                                        AS OrderValue,
       CAST(SUM(DiffPrev) OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID ROWS UNBOUNDED PRECEDING) AS DECIMAL(10,2)) AS AcumDiff
  FROM Diff86CTE

------------------------------------------------------------------------------------------------------------------------------------------
-- 87
------------------------------------------------------------------------------------------------------------------------------------------

;WITH ProductCategory87CTE AS
(
  SELECT c.CategoryID,
         c.CategoryName,
         p.ProductName,
         AVG(od.UnitPrice * od.Quantity * (1 - od.Discount))                                               AS AvgSales,
         PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY AVG(od.UnitPrice * od.Quantity * (1 - od.Discount)))
             OVER (PARTITION BY c.CategoryID)                                                              AS P75
    FROM Products        p
    JOIN Categories      c  ON c.CategoryID = p.CategoryID
    JOIN [Order Details] od ON od.ProductID = p.ProductID
GROUP BY c.CategoryID, c.CategoryName, p.ProductName
)
SELECT CategoryName,
       ProductName,
       CAST(AvgSales AS DECIMAL(10,2)) AS AvgSales
  FROM ProductCategory87CTE
 WHERE AvgSales > P75

------------------------------------------------------------------------------------------------------------------------------------------
-- 88
------------------------------------------------------------------------------------------------------------------------------------------

-- Foi adotado o 4o Trimestre de 1997
SELECT CustomerID,
       OrderID,
       CAST(OrderDate AS DATE) AS FirstOrder
  FROM (SELECT CustomerID,
               OrderID,
               OrderDate,
               ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID) AS Ranking
          FROM Orders
         WHERE YEAR(OrderDate) = 1997
           AND DATEPART(QUARTER, OrderDate) = 4) q
 WHERE Ranking = 1

------------------------------------------------------------------------------------------------------------------------------------------
-- 89
------------------------------------------------------------------------------------------------------------------------------------------

;WITH MonthTotal89CTE AS
(
  SELECT EmployeeID,
         YEAR(OrderDate)  AS [Year],
         MONTH(OrderDate) AS [Month],
         SUM(OrderValue)  AS TotalMonth
    FROM #ORDER_VALUE
GROUP BY EmployeeID, YEAR(OrderDate), MONTH(OrderDate)
),
MonthRank89CTE AS
(
SELECT EmployeeID,
       [Year],
       [Month],
       RANK() OVER (PARTITION BY [Year], [Month] ORDER BY TotalMonth DESC) AS MonthRanking
  FROM MonthTotal89CTE
)
SELECT e.FirstName + ' ' + e.LastName                                                                             AS FullName,
       r.[Year],
       r.[Month],
       ov.OrderID,
       CAST(SUM(ov.OrderValue) OVER (PARTITION BY ov.EmployeeID, r.[Year], r.[Month]
                                    ORDER BY ov.OrderDate, ov.OrderID ROWS UNBOUNDED PRECEDING) AS DECIMAL(10,2)) AS AcumMonth,
       r.MonthRanking
  FROM #ORDER_VALUE   ov
  JOIN MonthRank89CTE r  ON r.EmployeeID = ov.EmployeeID AND r.[Year] = YEAR(ov.OrderDate) AND r.[Month] = MONTH(ov.OrderDate)
  JOIN Employees      e  ON e.EmployeeID  = ov.EmployeeID

------------------------------------------------------------------------------------------------------------------------------------------
-- 90
------------------------------------------------------------------------------------------------------------------------------------------

;WITH QuarterSales90CTE AS
(
  SELECT YEAR(OrderDate)              AS [Year],
         DATEPART(QUARTER, OrderDate) AS [Quarter],
         SUM(OrderValue)              AS TotalQuarter
    FROM #ORDER_VALUE
GROUP BY YEAR(OrderDate), DATEPART(QUARTER, OrderDate)
)
SELECT [Year],
       [Quarter],
       CAST(TotalQuarter AS DECIMAL(10,2))                                                     AS TotalQuarter,
       CAST((TotalQuarter - LAG(TotalQuarter) OVER (ORDER BY [Year], [Quarter])) * 100.0
            / NULLIF(LAG(TotalQuarter) OVER (ORDER BY [Year], [Quarter]), 0) AS DECIMAL(10,2)) AS PctGrowth
  FROM QuarterSales90CTE

------------------------------------------------------------------------------------------------------------------------------------------
-- 91
------------------------------------------------------------------------------------------------------------------------------------------

     SELECT ov.OrderID,
            ov.CustomerID,
            CAST(ov.OrderDate AS DATE)           AS OrderDate,
            CAST(ov.OrderValue AS DECIMAL(10,2)) AS OrderValue,
            w.RankIn3Months
       FROM #ORDER_VALUE ov
CROSS APPLY (SELECT COUNT(*) + 1 AS RankIn3Months
               FROM #ORDER_VALUE ov2
              WHERE ov2.OrderDate > DATEADD(MONTH, -3, ov.OrderDate)
                AND ov2.OrderDate <= ov.OrderDate
                AND (ov2.OrderValue > ov.OrderValue
                     OR (ov2.OrderValue = ov.OrderValue AND ov2.OrderID < ov.OrderID))) w

------------------------------------------------------------------------------------------------------------------------------------------
-- 92
------------------------------------------------------------------------------------------------------------------------------------------

;WITH ProductRegion92CTE AS
(
  SELECT ISNULL(o.ShipRegion, 'Nao informado')                                               AS ShipRegion,
         p.ProductName,
         SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))                                 AS TotalSales,
         RANK() OVER (PARTITION BY ISNULL(o.ShipRegion, 'Nao informado')
                          ORDER BY SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) DESC) AS Ranking
    FROM Orders          o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    JOIN Products        p  ON p.ProductID = od.ProductID
GROUP BY ISNULL(o.ShipRegion, 'Nao informado'), p.ProductName
)
  SELECT ShipRegion,
         CAST(AVG(TotalSales) AS DECIMAL(10,2)) AS AvgTop5
    FROM ProductRegion92CTE
   WHERE Ranking <= 5
GROUP BY ShipRegion

------------------------------------------------------------------------------------------------------------------------------------------
-- 93
------------------------------------------------------------------------------------------------------------------------------------------

SELECT e.FirstName + ' ' + e.LastName                                                                     AS FullName,
       YEAR(ov.OrderDate)                                                                                 AS [Year],
       ov.OrderID,
       CAST(SUM(ov.OrderValue) OVER (PARTITION BY ov.EmployeeID, YEAR(ov.OrderDate) 
                                      ORDER BY ov.OrderDate, ov.OrderID ROWS UNBOUNDED PRECEDING) * 100.0
            / SUM(ov.OrderValue) OVER (PARTITION BY ov.EmployeeID, YEAR(ov.OrderDate)) AS DECIMAL(10,2))  AS PctAcum
  FROM #ORDER_VALUE ov
  JOIN Employees    e  ON e.EmployeeID = ov.EmployeeID

------------------------------------------------------------------------------------------------------------------------------------------
-- 94
------------------------------------------------------------------------------------------------------------------------------------------

-- Divisao de faixas do preço (UnitPrice) em 'Ate 20', 'Entre 20 e 50' e 'Acima de 50'
;WITH PriceBand94CTE AS
(
  SELECT CASE WHEN p.UnitPrice < 20 THEN 'Ate 20'
              WHEN p.UnitPrice <= 50 THEN 'Entre 20 e 50'
              ELSE 'Acima de 50'
               END                                           AS PriceBand,
         p.ProductName,
         SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
    FROM Products        p
    JOIN [Order Details] od ON od.ProductID = p.ProductID
GROUP BY CASE WHEN p.UnitPrice < 20 THEN 'Ate 20'
              WHEN p.UnitPrice <= 50 THEN 'Entre 20 e 50'
              ELSE 'Acima de 50'
               END,
         p.ProductName
)
SELECT PriceBand,
       ProductName,
       CAST(TotalSales AS DECIMAL(10,2))                                                                                      AS TotalSales,
       CAST(SUM(TotalSales) OVER (PARTITION BY PriceBand ORDER BY TotalSales DESC ROWS UNBOUNDED PRECEDING) AS DECIMAL(10,2)) AS AcumSales
  FROM PriceBand94CTE

------------------------------------------------------------------------------------------------------------------------------------------
-- 95
------------------------------------------------------------------------------------------------------------------------------------------

SELECT OrderID,
       ISNULL(ShipRegion, 'Nao informado')                                                                                AS ShipRegion,
       CAST(OrderValue AS DECIMAL(10,2))                                                                                  AS OrderValue,
       CAST(AVG(OrderValue) OVER (PARTITION BY ShipRegion ORDER BY OrderDate, OrderID ROWS 2 PRECEDING) AS DECIMAL(10,2)) AS MovingAvg,
       RANK() OVER (PARTITION BY ShipRegion ORDER BY OrderValue DESC)                                                     AS Ranking
  FROM #ORDER_VALUE

------------------------------------------------------------------------------------------------------------------------------------------
-- 96
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT DISTINCT
         CASE DATEDIFF(DAY, 0, OrderDate) % 7 WHEN 0 THEN 'Segunda-feira'
                                              WHEN 1 THEN 'Terça-feira'
                                              WHEN 2 THEN 'Quarta-feira'
                                              WHEN 3 THEN 'Quinta-feira'
                                              WHEN 4 THEN 'Sexta-feira'
                                              WHEN 5 THEN 'Sábado'
                                              ELSE 'Domingo'
                                               END                                                  AS WeekDayName,
         CAST(AVG(OrderValue) OVER (PARTITION BY DATEDIFF(DAY, 0, OrderDate) % 7) AS DECIMAL(10,2)) AS AvgWeekDay,
         DATEDIFF(DAY, 0, OrderDate) % 7                                                            AS WeekDayOrder
    FROM #ORDER_VALUE
ORDER BY WeekDayOrder

------------------------------------------------------------------------------------------------------------------------------------------
-- 97
------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @Year97    INT,
        @Quarter97 INT

-- Ultimo trimestre completo: o anterior ao trimestre da data mais recente
SELECT @Year97    = YEAR(DATEADD(QUARTER, -1, MAX(OrderDate))),
       @Quarter97 = DATEPART(QUARTER, DATEADD(QUARTER, -1, MAX(OrderDate)))
  FROM #ORDER_VALUE

SELECT CustomerID,
       OrderID,
       CAST(OrderValue AS DECIMAL(10,2))                                                                                          AS OrderValue,
       CAST(SUM(OrderValue) OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID ROWS UNBOUNDED PRECEDING) AS DECIMAL(10,2)) AS AcumLastQuarter
  FROM #ORDER_VALUE
 WHERE YEAR(OrderDate) = @Year97
   AND DATEPART(QUARTER, OrderDate) = @Quarter97

------------------------------------------------------------------------------------------------------------------------------------------
-- 98
------------------------------------------------------------------------------------------------------------------------------------------

;WITH ProductCategory98CTE AS
(
  SELECT c.CategoryName,
         p.ProductName,
         SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
    FROM Products        p
    JOIN Categories      c  ON c.CategoryID = p.CategoryID
    JOIN [Order Details] od ON od.ProductID = p.ProductID
GROUP BY c.CategoryName, p.ProductName
)
SELECT CategoryName,
       ProductName,
       CAST(SUM(TotalSales) OVER (PARTITION BY CategoryName ORDER BY ProductName ROWS UNBOUNDED PRECEDING) AS DECIMAL(10,2)) AS AcumSales,
       CAST(AVG(TotalSales) OVER (PARTITION BY CategoryName) AS DECIMAL(10,2))                                               AS AvgCategory
  FROM ProductCategory98CTE

------------------------------------------------------------------------------------------------------------------------------------------
-- 99
------------------------------------------------------------------------------------------------------------------------------------------

;WITH QuarterEmployee99CTE AS
(
  SELECT EmployeeID,
         YEAR(OrderDate)              AS [Year],
         DATEPART(QUARTER, OrderDate) AS [Quarter],
         SUM(OrderValue)              AS TotalQuarter
    FROM #ORDER_VALUE
GROUP BY EmployeeID, YEAR(OrderDate), DATEPART(QUARTER, OrderDate)
)
SELECT e.FirstName + ' ' + e.LastName                                                                                            AS FullName,
       q.[Year],
       q.[Quarter],
       CAST(q.TotalQuarter AS DECIMAL(10,2))                                                                                     AS TotalQuarter,
       RANK() OVER (PARTITION BY q.[Year], q.[Quarter] ORDER BY q.TotalQuarter DESC)                                             AS Ranking,
       CAST(SUM(q.TotalQuarter) OVER (PARTITION BY q.EmployeeID, q.[Year] ORDER BY q.[Quarter] ROWS UNBOUNDED PRECEDING) * 100.0
            / SUM(q.TotalQuarter) OVER (PARTITION BY q.EmployeeID, q.[Year]) AS DECIMAL(10,2))                                   AS PctAcumYear
  FROM QuarterEmployee99CTE q
  JOIN Employees            e ON e.EmployeeID = q.EmployeeID

------------------------------------------------------------------------------------------------------------------------------------------
-- 100
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CategoryMonth100CTE AS
(
  SELECT c.CategoryName,
         YEAR(o.OrderDate)                                   AS [Year],
         MONTH(o.OrderDate)                                  AS [Month],
         SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalMonth
    FROM Orders          o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    JOIN Products        p  ON p.ProductID = od.ProductID
    JOIN Categories      c  ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryName, YEAR(o.OrderDate), MONTH(o.OrderDate)
)
SELECT CategoryName,
       [Year],
       [Month],
       CAST(TotalMonth AS DECIMAL(10,2))                                                                                         AS TotalMonth,
       CAST(SUM(TotalMonth) OVER (PARTITION BY CategoryName ORDER BY [Year], [Month] ROWS UNBOUNDED PRECEDING) AS DECIMAL(10,2)) AS AcumSales,
       CAST((TotalMonth - LAG(TotalMonth) OVER (PARTITION BY CategoryName ORDER BY [Year], [Month])) * 100.0
            / NULLIF(LAG(TotalMonth) OVER (PARTITION BY CategoryName ORDER BY [Year], [Month]), 0) AS DECIMAL(10,2))             AS PctGrowth
  FROM CategoryMonth100CTE