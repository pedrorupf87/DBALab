
USE Northwind
GO

------------------------------------------------------------------------------------------------------------------------------------------
-- 01
------------------------------------------------------------------------------------------------------------------------------------------

;WITH TotalSales01CTE AS
(
	    SELECT o.CustomerID,
	           COUNT(DISTINCT o.OrderID)       AS Quantity,
	  	      SUM(od.Quantity * od.UnitPrice) AS TotalSales
	      FROM Orders           o
	      JOIN [Order Details] od ON od.OrderID = o.OrderID
	  GROUP BY o.CustomerID
)
  SELECT *
    FROM TotalSales01CTE
   WHERE Quantity > 10
ORDER BY Quantity DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 02
------------------------------------------------------------------------------------------------------------------------------------------

;WITH TotalOrders02CTE AS
(
	  SELECT OrderID,
	         SUM(Quantity * UnitPrice) AS TotalOrder
	    FROM [Order Details]
	GROUP BY OrderID
)
  SELECT TOP 5
         OrderID,
  	    TotalOrder
    FROM TotalOrders02CTE
ORDER BY TotalOrder DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 03
------------------------------------------------------------------------------------------------------------------------------------------

;WITH RankingCategories03CTE AS
(
	  SELECT c.CategoryID,
	         c.CategoryName,
	  	    SUM(od.Quantity * od.UnitPrice) AS Total
	    FROM Categories       c
	    JOIN Products         p ON p.CategoryID = c.CategoryID
	    JOIN [Order Details] od ON od.ProductID = p.ProductID
	GROUP BY c.CategoryID, c.CategoryName	
)
  SELECT TOP 3
         CategoryID,
  	    CategoryName,
  	    Total
    FROM RankingCategories03CTE
ORDER BY Total DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 04
------------------------------------------------------------------------------------------------------------------------------------------

;WITH AvgSalesCategory04CTE AS
(
	  SELECT c.CategoryID,
	         c.CategoryName,
              p.ProductName,
	  	    AVG(od.Quantity * od.UnitPrice) AS AvgSalesCategory
	    FROM Categories      c
	    JOIN Products        p  ON p.CategoryID = c.CategoryID
	    JOIN [Order Details] od ON od.ProductID = p.ProductID
	GROUP BY c.CategoryID, c.CategoryName, p.ProductName
)
  SELECT CategoryName,
         ProductName,
         ROUND(AvgSalesCategory, 2) AS AvgSalesCategory
    FROM AvgSalesCategory04CTE
ORDER BY CategoryName

------------------------------------------------------------------------------------------------------------------------------------------
-- 05
------------------------------------------------------------------------------------------------------------------------------------------

;WITH EmployeeSales05CTE AS
(
	SELECT e.FirstName + ' ' + e.LastName  AS FullName,
	       SUM(od.Quantity * od.UnitPrice) AS TotalSales
	  FROM Orders          o
	  JOIN [Order Details] od ON od.OrderID = o.OrderID
	  JOIN Employees       e  ON e.EmployeeID = o.EmployeeID
	GROUP BY e.FirstName, e.LastName
),
AvgSales05CTE AS
(
	SELECT AVG(TotalSales) AS AvgSales
	  FROM EmployeeSales05CTE
)
    SELECT FullName,
           CAST(TotalSales AS DECIMAL(10,2)) AS TotalSales,
           CAST(AvgSales AS DECIMAL(10,2))   AS AvgSales
      FROM EmployeeSales05CTE
CROSS JOIN AvgSales05CTE
     WHERE TotalSales > AvgSales

------------------------------------------------------------------------------------------------------------------------------------------
-- 06
------------------------------------------------------------------------------------------------------------------------------------------

;WITH SalesCountry06CTE AS
(
	  SELECT p.ProductName,
	         COUNT(DISTINCT o.ShipCountry) AS QuantityOfCountries
	    FROM Orders          o
	    JOIN [Order Details] od ON od.OrderID = o.OrderID
	    JOIN Products        p  ON p.ProductID = od.ProductID
	GROUP BY p.ProductName
)
SELECT ProductName,
	  QuantityOfCountries
  FROM SalesCountry06CTE
 WHERE QuantityOfCountries >= 3

------------------------------------------------------------------------------------------------------------------------------------------
-- 07
------------------------------------------------------------------------------------------------------------------------------------------

;WITH AvgFreight07CTE AS
(
	SELECT AVG(Freight) AS AvgFreight
	  FROM Orders
),
CustomerFreight07CTE AS
(
	SELECT OrderID,
	       CustomerID,
	       Freight
	  FROM Orders
)
  SELECT OrderID,
         CustomerID,
         CAST(Freight AS DECIMAL(10,2)) AS Freight
    FROM AvgFreight07CTE,
         CustomerFreight07CTE
   WHERE Freight > AvgFreight
ORDER BY CustomerID

------------------------------------------------------------------------------------------------------------------------------------------
-- 08
------------------------------------------------------------------------------------------------------------------------------------------

;WITH TotalSales08CTE AS
(
	  SELECT e.FirstName + ' ' + e.LastName  AS FullName,
              SUM(od.Quantity * od.UnitPrice) AS TotalSales
	    FROM Orders          o
	    JOIN [Order Details] od ON od.OrderID = o.OrderID
	    JOIN Employees       e  ON e.EmployeeID = o.EmployeeID
	GROUP BY e.FirstName, e.LastName
)
SELECT FullName,
       CAST(SUM(TotalSales) OVER (ORDER BY FullName) AS DECIMAL(10,2)) AS TotalAcumulated
  FROM TotalSales08CTE

------------------------------------------------------------------------------------------------------------------------------------------
-- 09
------------------------------------------------------------------------------------------------------------------------------------------

;WITH SupplierSales09CTE AS
(
	  SELECT s.SupplierID,
	         s.CompanyName,
              CAST(SUM(od.Quantity * od.UnitPrice) AS DECIMAL(10,2)) AS TotalSupplier
	    FROM Suppliers       s
	    JOIN Products        p  ON p.SupplierID = s.SupplierID
	    JOIN [Order Details] od ON od.ProductID = p.ProductID
	GROUP BY s.SupplierID, s.CompanyName
)
SELECT *
  FROM SupplierSales09CTE
 WHERE TotalSupplier > 15000

------------------------------------------------------------------------------------------------------------------------------------------
-- 10
------------------------------------------------------------------------------------------------------------------------------------------

;WITH MostProductsSold10CTE AS
(
	  SELECT p.ProductName,
	         SUM(od.Quantity) AS Quantity
	    FROM [Order Details] od
	    JOIN Products        p  ON p.ProductID = od.ProductID
	GROUP BY p.ProductName
)
  SELECT TOP 10 *
    FROM MostProductsSold10CTE
ORDER BY Quantity DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 11
------------------------------------------------------------------------------------------------------------------------------------------

-- O Northwind nao tem subcategorias. Entao estou fazendo a hierarquia simulada com categoria (nivel 1) e produto (nivel 2)
;WITH CategoriesHierarqhy11CTE AS
(
       SELECT CategoryID,
              CAST(NULL AS INT)                   AS ProductID,
              CAST(CategoryName AS NVARCHAR(MAX)) AS [Location],
              1                                   AS [Level]
         FROM Categories

    UNION ALL

       SELECT h.CategoryID,
              p.ProductID,
              CAST(h.[Location] + N' -> ' + p.ProductName AS NVARCHAR(MAX)),
              h.[Level] + 1
         FROM CategoriesHierarqhy11CTE h
         JOIN Products                 p ON p.CategoryID = h.CategoryID
        WHERE h.[Level] = 1
)
  SELECT CategoryID,
         ProductID,
         [Location],
         [Level]
    FROM CategoriesHierarqhy11CTE
ORDER BY [Location]

------------------------------------------------------------------------------------------------------------------------------------------
-- 12
------------------------------------------------------------------------------------------------------------------------------------------

-- A Hierarquia de vendas esta na forma de região (nivel 1), territoio (nivel 2) e funcionario (nivel 3)
;WITH RegionsHierarqhy12CTE AS
(
       SELECT r.RegionID,
              CAST(NULL AS NVARCHAR(20))                        AS TerritoryID,
              CAST(RTRIM(r.RegionDescription) AS NVARCHAR(MAX)) AS [Location],
              1                                                 AS [Level]
         FROM Region r

    UNION ALL

       SELECT h.RegionID,
              CAST(t.TerritoryID AS NVARCHAR(20)),
              CAST(h.[Location] + N' -> ' + RTRIM(t.TerritoryDescription) AS NVARCHAR(MAX)),
              h.[Level] + 1
         FROM RegionsHierarqhy12CTE h
         JOIN Territories           t ON t.RegionID = h.RegionID
        WHERE h.[Level] = 1

    UNION ALL

       SELECT h.RegionID,
              h.TerritoryID,
              CAST(h.[Location] + N' -> ' + e.FirstName + N' ' + e.LastName AS NVARCHAR(MAX)),
              h.[Level] + 1
         FROM RegionsHierarqhy12CTE h
         JOIN EmployeeTerritories   et ON et.TerritoryID = h.TerritoryID
         JOIN Employees             e  ON e.EmployeeID   = et.EmployeeID
        WHERE h.[Level] = 2
)
  SELECT r.RegionID,
         RTRIM(r.RegionDescription)                     AS RegionName,
         MAX(h.[Level])                                 AS NumberOfLevels,
         SUM(CASE WHEN h.[Level] = 2 THEN 1 ELSE 0 END) AS Territories,
         SUM(CASE WHEN h.[Level] = 3 THEN 1 ELSE 0 END) AS EmployeeTerritories
    FROM RegionsHierarqhy12CTE h
    JOIN Region                r ON r.RegionID = h.RegionID
GROUP BY r.RegionID, r.RegionDescription
ORDER BY r.RegionID

------------------------------------------------------------------------------------------------------------------------------------------
-- 13
------------------------------------------------------------------------------------------------------------------------------------------

-- A hierarquia simulada e categoria (nivel 1), fornecedor com produto na categoria (nivel 2) e produto (nivel 3)
;WITH CategorySuppliers13CTE AS
(
    SELECT DISTINCT
           CategoryID,
           SupplierID
      FROM Products
),
SuppliersHierarqhy13CTE AS
(
       SELECT c.CategoryID,
              CAST(NULL AS INT)                     AS SupplierID,
              CAST(c.CategoryName AS NVARCHAR(MAX)) AS [Location],
              1                                     AS [Level]
         FROM Categories c

    UNION ALL

       SELECT h.CategoryID,
              s.SupplierID,
              CAST(h.[Location] + N' -> ' + s.CompanyName AS NVARCHAR(MAX)),
              h.[Level] + 1
         FROM SuppliersHierarqhy13CTE h
         JOIN CategorySuppliers13CTE  cs ON cs.CategoryID = h.CategoryID
         JOIN Suppliers               s  ON s.SupplierID  = cs.SupplierID
        WHERE h.[Level] = 1

    UNION ALL

       SELECT h.CategoryID,
              h.SupplierID,
              CAST(h.[Location] + N' -> ' + p.ProductName AS NVARCHAR(MAX)),
              h.[Level] + 1
         FROM SuppliersHierarqhy13CTE h
         JOIN Products                p ON p.CategoryID = h.CategoryID AND p.SupplierID = h.SupplierID
        WHERE h.[Level] = 2
)
  SELECT CategoryID,
         SupplierID,
         [Location],
         [Level]
    FROM SuppliersHierarqhy13CTE
ORDER BY [Location]

------------------------------------------------------------------------------------------------------------------------------------------
-- 14
------------------------------------------------------------------------------------------------------------------------------------------

;WITH SalesByYear14CTE AS
(
      SELECT YEAR(OrderDate)                 AS [Year],
             SUM(od.Quantity * od.UnitPrice) AS TotalSales
        FROM Orders          o
        JOIN [Order Details] od ON o.OrderID = od.OrderID
       WHERE YEAR(OrderDate) >= 1996
    GROUP BY YEAR(OrderDate)
),
Acumulated AS
(
       SELECT [Year],
              TotalSales,
              TotalSales AS Acumulated
         FROM SalesByYear14CTE
        WHERE [Year] = 1996
    
    UNION ALL
    
       SELECT s.[Year],
              s.TotalSales,
              a.Acumulated + s.TotalSales AS Acumulated
         FROM SalesByYear14CTE s
         JOIN Acumulated       a ON s.[Year] = a.[Year] + 1
)
  SELECT [Year],
         CAST(TotalSales AS DECIMAL(10,2)) AS TotalSales,
         CAST(Acumulated AS DECIMAL(10,2)) AS Acumulated
    FROM Acumulated
ORDER BY [Year]

------------------------------------------------------------------------------------------------------------------------------------------
-- 15
------------------------------------------------------------------------------------------------------------------------------------------

;WITH TerritorySales15CTE AS
(
      SELECT t.TerritoryID,
             t.RegionID,
             SUM(od.Quantity) AS TotalProducts
        FROM Territories         t
        JOIN EmployeeTerritories et ON et.TerritoryID = t.TerritoryID
        JOIN Orders              o  ON o.EmployeeID = et.EmployeeID
        JOIN [Order Details]     od ON od.OrderID = o.OrderID
    GROUP BY t.TerritoryID, t.RegionID
),
RegionProducts15CTE AS
(
       SELECT r.RegionID,
              CAST(NULL AS NVARCHAR(20))                        AS TerritoryID,
              CAST(RTRIM(r.RegionDescription) AS NVARCHAR(MAX)) AS [Location],
              1                                                 AS [Level]
         FROM Region r

    UNION ALL

       SELECT pr.RegionID,
              CAST(t.TerritoryID AS NVARCHAR(20)),
              CAST(pr.[Location] + N' -> ' + RTRIM(t.TerritoryDescription) AS NVARCHAR(MAX)),
              pr.[Level] + 1
         FROM RegionProducts15CTE pr
         JOIN Territories         t  ON t.RegionID = pr.RegionID
        WHERE pr.[Level] = 1
)
  SELECT pr.[Location],
         pr.[Level],
         CASE WHEN pr.[Level] = 1 THEN (SELECT SUM(ts.TotalProducts) FROM TerritorySales15CTE ts WHERE ts.RegionID = pr.RegionID)
              ELSE (SELECT ts.TotalProducts FROM TerritorySales15CTE ts WHERE ts.TerritoryID = pr.TerritoryID)
          END AS TotalProducts
    FROM RegionProducts15CTE pr
ORDER BY pr.[Location]

------------------------------------------------------------------------------------------------------------------------------------------
-- 16
------------------------------------------------------------------------------------------------------------------------------------------

-- Os pedidos do produto sao numerados e percorridos um a um pela recursao
;WITH PedidosProduto AS
(
    SELECT o.CustomerID,
           ROW_NUMBER() OVER (ORDER BY o.OrderID) AS RowNum
      FROM Orders          o
      JOIN [Order Details] od ON od.OrderID = o.OrderID
     WHERE od.ProductID = 1 -- Produto específico (exemplo)
),
ClientesProduto AS
(
       SELECT CustomerID,
              RowNum
         FROM PedidosProduto
        WHERE RowNum = 1

    UNION ALL

       SELECT pp.CustomerID,
              pp.RowNum
         FROM PedidosProduto  pp
         JOIN ClientesProduto cp ON pp.RowNum = cp.RowNum + 1
)
  SELECT DISTINCT
         c.CustomerID,
         c.CompanyName
    FROM ClientesProduto cp
    JOIN Customers       c  ON c.CustomerID = cp.CustomerID
ORDER BY c.CustomerID

------------------------------------------------------------------------------------------------------------------------------------------
-- 17
------------------------------------------------------------------------------------------------------------------------------------------

-- O total do funcionario e o maior acumulado, e foi usado MAXRECURSION acima de 100 porque ha funcionario com mais de 100 pedidos
;WITH OrderQuantity17CTE AS
(
      SELECT o.EmployeeID,
             SUM(od.Quantity)                                                 AS Quantity,
             ROW_NUMBER() OVER (PARTITION BY o.EmployeeID ORDER BY o.OrderID) AS RowNum
        FROM Orders          o
        JOIN [Order Details] od ON od.OrderID = o.OrderID
    GROUP BY o.EmployeeID, o.OrderID
),
ProductsByEmployee17CTE AS
(
       SELECT EmployeeID,
              RowNum,
              Quantity AS Acumulated
         FROM OrderQuantity17CTE
        WHERE RowNum = 1

    UNION ALL

       SELECT oq.EmployeeID,
              oq.RowNum,
              pe.Acumulated + oq.Quantity
         FROM OrderQuantity17CTE      oq
         JOIN ProductsByEmployee17CTE pe ON oq.EmployeeID = pe.EmployeeID AND oq.RowNum = pe.RowNum + 1
)
  SELECT EmployeeID,
         MAX(Acumulated) AS Quantity
    FROM ProductsByEmployee17CTE
GROUP BY EmployeeID
ORDER BY EmployeeID DESC
  OPTION (MAXRECURSION 1000)

------------------------------------------------------------------------------------------------------------------------------------------
-- 18
------------------------------------------------------------------------------------------------------------------------------------------

-- Como o Northwind nao tem subcategorias, adotei a hierarquia categoria (nivel 1) e produto (nivel 2)
;WITH ProductHierarchy18CTE AS
(
       SELECT c.CategoryID,
              CAST(NULL AS INT)                     AS ProductID,
              CAST(c.CategoryName AS NVARCHAR(MAX)) AS [Location],
              1                                     AS [Level]
         FROM Categories c

    UNION ALL

       SELECT h.CategoryID,
              p.ProductID,
              CAST(h.[Location] + N' -> ' + p.ProductName AS NVARCHAR(MAX)),
              h.[Level] + 1
         FROM ProductHierarchy18CTE h
         JOIN Products              p ON p.CategoryID = h.CategoryID
        WHERE h.[Level] = 1
)
  SELECT CategoryID,
         ProductID,
         [Location],
         [Level]
    FROM ProductHierarchy18CTE
ORDER BY [Location]

------------------------------------------------------------------------------------------------------------------------------------------
-- 19
------------------------------------------------------------------------------------------------------------------------------------------

;WITH SupplierSales19CTE AS
(
      SELECT s.Country,
             s.SupplierID,
             s.CompanyName,
             SUM(od.Quantity * od.UnitPrice)                                   AS TotalSales,
             ROW_NUMBER() OVER (PARTITION BY s.Country ORDER BY s.CompanyName) AS RowNum
        FROM Suppliers       s
        JOIN Products        p  ON p.SupplierID = s.SupplierID
        JOIN [Order Details] od ON od.ProductID = p.ProductID
    GROUP BY s.Country, s.SupplierID, s.CompanyName
),
AcumCountry19CTE AS
(
       SELECT Country,
              SupplierID,
              CompanyName,
              RowNum,
              TotalSales,
              TotalSales AS Acumulated
         FROM SupplierSales19CTE
        WHERE RowNum = 1

    UNION ALL

       SELECT s.Country,
              s.SupplierID,
              s.CompanyName,
              s.RowNum,
              s.TotalSales,
              a.Acumulated + s.TotalSales
         FROM SupplierSales19CTE s
         JOIN AcumCountry19CTE   a ON a.Country = s.Country AND s.RowNum = a.RowNum + 1
)
  SELECT Country,
         SupplierID,
         CompanyName,
         CAST(TotalSales AS DECIMAL(10,2)) AS TotalSales,
         CAST(Acumulated AS DECIMAL(10,2)) AS Acumulated
    FROM AcumCountry19CTE
ORDER BY Country, RowNum

------------------------------------------------------------------------------------------------------------------------------------------
-- 20
------------------------------------------------------------------------------------------------------------------------------------------

-- Percorre os pedidos do maior ao menor valor, usando MAXRECURSION elevado porque ha mais de 100 pedidos
;WITH OrderValue20CTE AS
(
      SELECT o.OrderID,
             SUM(od.Quantity * od.UnitPrice)                                              AS TotalOrder,
             ROW_NUMBER() OVER (ORDER BY SUM(od.Quantity * od.UnitPrice) DESC, o.OrderID) AS RowNum
        FROM Orders          o
        JOIN [Order Details] od ON od.OrderID = o.OrderID
    GROUP BY o.OrderID
),
SalesHierarchy20CTE AS
(
       SELECT OrderID,
              RowNum,
              TotalOrder,
              TotalOrder AS Acumulated
         FROM OrderValue20CTE
        WHERE RowNum = 1

    UNION ALL

       SELECT o.OrderID,
              o.RowNum,
              o.TotalOrder,
              h.Acumulated + o.TotalOrder
         FROM OrderValue20CTE      o
         JOIN SalesHierarchy20CTE  h ON o.RowNum = h.RowNum + 1
)
  SELECT RowNum,
         OrderID,
         CAST(TotalOrder AS DECIMAL(10,2)) AS TotalOrder,
         CAST(Acumulated AS DECIMAL(10,2)) AS Acumulated
    FROM SalesHierarchy20CTE
ORDER BY RowNum
  OPTION (MAXRECURSION 1000)

------------------------------------------------------------------------------------------------------------------------------------------
-- 21
------------------------------------------------------------------------------------------------------------------------------------------

;WITH EmployeeSales21CTE AS
(
      SELECT e.FirstName + ' ' + e.LastName  AS FullName,
             SUM(od.Quantity * od.UnitPrice) AS TotalSales
        FROM Orders          o
        JOIN [Order Details] od ON od.OrderID = o.OrderID
        JOIN Employees       e  ON e.EmployeeID = o.EmployeeID
    GROUP BY e.FirstName, e.LastName
)
SELECT FullName,
       CAST(TotalSales AS DECIMAL(10,2))                                   AS TotalSales,
       CAST(TotalSales * 100.0 / SUM(TotalSales) OVER () AS DECIMAL(10,2)) AS PctParticipation
  FROM EmployeeSales21CTE

------------------------------------------------------------------------------------------------------------------------------------------
-- 22
------------------------------------------------------------------------------------------------------------------------------------------

;WITH ProductMonth22CTE AS
(
      SELECT od.ProductID,
             DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1) AS SalesMonth,
             SUM(od.Quantity * od.UnitPrice)                         AS TotalMonth
        FROM Orders          o
        JOIN [Order Details] od ON od.OrderID = o.OrderID
    GROUP BY od.ProductID, DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1)
),
Calendar22CTE AS
(
    SELECT DISTINCT
           DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS SalesMonth
      FROM Orders
)
    SELECT p.ProductName,
           YEAR(c.SalesMonth)                                                           AS [Year],
           MONTH(c.SalesMonth)                                                          AS [Month],
           CAST(ISNULL(pm.TotalMonth, 0) AS DECIMAL(10,2))                              AS TotalMonth,
           CAST(ISNULL(pm.TotalMonth, 0) - LAG(ISNULL(pm.TotalMonth, 0))
                OVER (PARTITION BY p.ProductID ORDER BY c.SalesMonth) AS DECIMAL(10,2)) AS MonthVariation
      FROM Products          p
CROSS JOIN Calendar22CTE     c
 LEFT JOIN ProductMonth22CTE pm ON pm.ProductID = p.ProductID AND pm.SalesMonth = c.SalesMonth

------------------------------------------------------------------------------------------------------------------------------------------
-- 23
------------------------------------------------------------------------------------------------------------------------------------------

;WITH AvgCategoryPrice23CTE AS
(
      SELECT CategoryID,
             AVG(UnitPrice) AS AvgPrice
        FROM Products
    GROUP BY CategoryID
)
SELECT p.ProductName,
       c.CategoryName,
       CAST(p.UnitPrice AS DECIMAL(10,2)) AS UnitPrice,
       CAST(a.AvgPrice AS DECIMAL(10,2))  AS AvgPrice
  FROM Products              p
  JOIN Categories            c ON c.CategoryID = p.CategoryID
  JOIN AvgCategoryPrice23CTE a ON a.CategoryID = p.CategoryID
 WHERE p.UnitPrice < a.AvgPrice

------------------------------------------------------------------------------------------------------------------------------------------
-- 24
------------------------------------------------------------------------------------------------------------------------------------------

;WITH DaysBetween24CTE AS
(
    SELECT CustomerID,
           DATEDIFF(DAY, LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID), OrderDate) AS DaysSinceLastOrder
      FROM Orders
)
  SELECT CustomerID,
         CAST(AVG(CAST(DaysSinceLastOrder AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS AvgDaysBetweenOrders
    FROM DaysBetween24CTE
   WHERE DaysSinceLastOrder IS NOT NULL
GROUP BY CustomerID

------------------------------------------------------------------------------------------------------------------------------------------
-- 25
------------------------------------------------------------------------------------------------------------------------------------------

;WITH Consecutive25CTE AS
(
    SELECT CustomerID,
           OrderID,
           OrderDate,
           LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID) AS LastOrderDate
      FROM Orders
)
SELECT CustomerID,
       OrderID,
       CAST(LastOrderDate AS DATE)             AS LastOrderDate,
       CAST(OrderDate AS DATE)                 AS OrderDate,
       DATEDIFF(DAY, LastOrderDate, OrderDate) AS DaysBetween
  FROM Consecutive25CTE
 WHERE DATEDIFF(DAY, LastOrderDate, OrderDate) > 30

------------------------------------------------------------------------------------------------------------------------------------------
-- 26
------------------------------------------------------------------------------------------------------------------------------------------

;WITH ProductSales26CTE AS
(
      SELECT p.ProductName,
             SUM(od.Quantity * od.UnitPrice) AS TotalSales
        FROM Products        p
        JOIN [Order Details] od ON od.ProductID = p.ProductID
    GROUP BY p.ProductName
)
SELECT ProductName,
       CAST(TotalSales AS DECIMAL(10,2)) AS TotalSales
  FROM ProductSales26CTE
 WHERE TotalSales > 10000

------------------------------------------------------------------------------------------------------------------------------------------
-- 27
------------------------------------------------------------------------------------------------------------------------------------------

;WITH MonthSales27CTE AS
(
      SELECT YEAR(o.OrderDate)               AS [Year],
             MONTH(o.OrderDate)              AS [Month],
             SUM(od.Quantity * od.UnitPrice) AS TotalMonth
        FROM Orders          o
        JOIN [Order Details] od ON od.OrderID = o.OrderID
    GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate)
)
SELECT [Year],
       [Month],
       CAST(TotalMonth AS DECIMAL(10,2))                                                   AS TotalMonth,
       CAST((TotalMonth - LAG(TotalMonth) OVER (ORDER BY [Year], [Month])) * 100.0
            / NULLIF(LAG(TotalMonth) OVER (ORDER BY [Year], [Month]), 0) AS DECIMAL(10,2)) AS PctGrowth
  FROM MonthSales27CTE

------------------------------------------------------------------------------------------------------------------------------------------
-- 28
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CategoryItems28CTE AS
(
      SELECT c.CategoryName,
             od.OrderID,
             SUM(od.Quantity) AS QtyItems
        FROM Categories      c
        JOIN Products        p  ON p.CategoryID = c.CategoryID
        JOIN [Order Details] od ON od.ProductID = p.ProductID
    GROUP BY c.CategoryName, od.OrderID
)
  SELECT CategoryName,
         CAST(AVG(CAST(QtyItems AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS AvgItemsPerOrder
    FROM CategoryItems28CTE
GROUP BY CategoryName

------------------------------------------------------------------------------------------------------------------------------------------
-- 29
------------------------------------------------------------------------------------------------------------------------------------------

;WITH EmployeeRegion29CTE AS
(
      SELECT e.FirstName + ' ' + e.LastName       AS FullName,
             ISNULL(o.ShipRegion, 'Not Informed') AS ShipRegion,
             SUM(od.Quantity * od.UnitPrice)      AS TotalSales
        FROM Orders          o
        JOIN [Order Details] od ON od.OrderID = o.OrderID
        JOIN Employees       e  ON e.EmployeeID = o.EmployeeID
    GROUP BY e.FirstName, e.LastName, ISNULL(o.ShipRegion, 'Not Informed')
),
AvgRegion29CTE AS
(
      SELECT ShipRegion,
             AVG(TotalSales) AS AvgSales
        FROM EmployeeRegion29CTE
    GROUP BY ShipRegion
)
SELECT e.FullName,
       e.ShipRegion,
       CAST(e.TotalSales AS DECIMAL(10,2)) AS TotalSales,
       CAST(a.AvgSales AS DECIMAL(10,2))   AS AvgSales
  FROM EmployeeRegion29CTE e
  JOIN AvgRegion29CTE      a ON a.ShipRegion = e.ShipRegion
 WHERE e.TotalSales > a.AvgSales

------------------------------------------------------------------------------------------------------------------------------------------
-- 30
------------------------------------------------------------------------------------------------------------------------------------------

;WITH QuarterCategory30CTE AS
(
      SELECT c.CategoryName,
             YEAR(o.OrderDate)               AS [Year],
             DATEPART(QUARTER, o.OrderDate)  AS [Quarter],
             SUM(od.Quantity * od.UnitPrice) AS TotalSales
        FROM Orders          o
        JOIN [Order Details] od ON od.OrderID = o.OrderID
        JOIN Products        p  ON p.ProductID = od.ProductID
        JOIN Categories      c  ON c.CategoryID = p.CategoryID
    GROUP BY c.CategoryName, YEAR(o.OrderDate), DATEPART(QUARTER, o.OrderDate)
)
  SELECT CategoryName,
         [Year],
         [Quarter],
         CAST(TotalSales AS DECIMAL(10,2)) AS TotalSales
    FROM QuarterCategory30CTE
ORDER BY CategoryName, [Year], [Quarter]

------------------------------------------------------------------------------------------------------------------------------------------
-- 31
------------------------------------------------------------------------------------------------------------------------------------------

;WITH EmployeeYear31CTE AS
(
      SELECT e.EmployeeID,
             e.FirstName + ' ' + e.LastName  AS FullName,
             YEAR(o.OrderDate)               AS [Year],
             SUM(od.Quantity * od.UnitPrice) AS TotalSales
        FROM Orders          o
        JOIN [Order Details] od ON od.OrderID = o.OrderID
        JOIN Employees       e  ON e.EmployeeID = o.EmployeeID
    GROUP BY e.EmployeeID, e.FirstName, e.LastName, YEAR(o.OrderDate)
),
Growth31CTE AS
(
    SELECT EmployeeID,
           FullName,
           [Year],
           TotalSales,
           (TotalSales - LAG(TotalSales) OVER (PARTITION BY EmployeeID ORDER BY [Year])) * 100.0
               / NULLIF(LAG(TotalSales) OVER (PARTITION BY EmployeeID ORDER BY [Year]), 0) AS PctGrowth
      FROM EmployeeYear31CTE
)
SELECT FullName,
       [Year],
       CAST(TotalSales AS DECIMAL(10,2)) AS TotalSales,
       CAST(PctGrowth AS DECIMAL(10,2))  AS PctGrowth
  FROM Growth31CTE
 WHERE PctGrowth = (SELECT MAX(PctGrowth) FROM Growth31CTE)

------------------------------------------------------------------------------------------------------------------------------------------
-- 32
------------------------------------------------------------------------------------------------------------------------------------------

;WITH ProductSales32CTE AS
(
      SELECT p.ProductName,
             SUM(od.Quantity * od.UnitPrice) AS TotalSales
        FROM Products        p
        JOIN [Order Details] od ON od.ProductID = p.ProductID
    GROUP BY p.ProductName
),
AvgSales32CTE AS
(
    SELECT AVG(TotalSales) AS AvgSales
      FROM ProductSales32CTE
)
    SELECT p.ProductName,
           CAST(p.TotalSales AS DECIMAL(10,2)) AS TotalSales,
           CAST(a.AvgSales AS DECIMAL(10,2))   AS AvgSales
      FROM ProductSales32CTE p
CROSS JOIN AvgSales32CTE     a
     WHERE p.TotalSales > a.AvgSales

------------------------------------------------------------------------------------------------------------------------------------------
-- 33
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CountrySales33CTE AS
(
      SELECT o.ShipCountry,
             SUM(od.Quantity * od.UnitPrice) AS TotalSales
        FROM Orders          o
        JOIN [Order Details] od ON od.OrderID = o.OrderID
    GROUP BY o.ShipCountry
),
Share33CTE AS
(
    SELECT ShipCountry,
           TotalSales,
           TotalSales * 100.0 / SUM(TotalSales) OVER () AS PctShare
      FROM CountrySales33CTE
)
  SELECT TOP 5
         ShipCountry,
         CAST(TotalSales AS DECIMAL(10,2)) AS TotalSales,
         CAST(PctShare AS DECIMAL(10,2))   AS PctShare
    FROM Share33CTE
ORDER BY TotalSales DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 34
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CustomerOrders34CTE AS
(
      SELECT CustomerID,
             COUNT(*) AS QtyOrders
        FROM Orders
    GROUP BY CustomerID
),
AvgOrders34CTE AS
(
    SELECT AVG(CAST(QtyOrders AS DECIMAL(10,2))) AS AvgOrders
      FROM CustomerOrders34CTE
)
    SELECT c.CustomerID,
           c.QtyOrders,
           a.AvgOrders
      FROM CustomerOrders34CTE c
CROSS JOIN AvgOrders34CTE      a
     WHERE c.QtyOrders > a.AvgOrders

------------------------------------------------------------------------------------------------------------------------------------------
-- 35
------------------------------------------------------------------------------------------------------------------------------------------

;WITH SupplierProduct35CTE AS
(
      SELECT s.SupplierID,
             s.CompanyName,
             p.ProductName,
             SUM(od.Quantity)                                                       AS Quantity,
             RANK() OVER (PARTITION BY s.SupplierID ORDER BY SUM(od.Quantity) DESC) AS Ranking
        FROM Suppliers       s
        JOIN Products        p  ON p.SupplierID = s.SupplierID
        JOIN [Order Details] od ON od.ProductID = p.ProductID
    GROUP BY s.SupplierID, s.CompanyName, p.ProductName
),
SupplierShare35CTE AS
(
      SELECT s.SupplierID,
             SUM(od.Quantity * od.UnitPrice) AS TotalSales
        FROM Suppliers       s
        JOIN Products        p  ON p.SupplierID = s.SupplierID
        JOIN [Order Details] od ON od.ProductID = p.ProductID
    GROUP BY s.SupplierID
)
SELECT sp.CompanyName,
       sp.ProductName,
       sp.Quantity,
       CAST(ss.TotalSales * 100.0 / SUM(ss.TotalSales) OVER () AS DECIMAL(10,2)) AS PctShare
  FROM SupplierProduct35CTE sp
  JOIN SupplierShare35CTE   ss ON ss.SupplierID = sp.SupplierID
 WHERE sp.Ranking = 1

------------------------------------------------------------------------------------------------------------------------------------------
-- 36
------------------------------------------------------------------------------------------------------------------------------------------

;WITH OrdersMonth36CTE AS
(
      SELECT YEAR(OrderDate)  AS [Year],
             MONTH(OrderDate) AS [Month],
             COUNT(*)         AS QtyOrders
        FROM Orders
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
),
Variation36CTE AS
(
    SELECT [Year],
           [Month],
           QtyOrders,
           QtyOrders - LAG(QtyOrders) OVER (ORDER BY [Year], [Month]) AS MonthVariation
      FROM OrdersMonth36CTE
)
SELECT [Year],
       [Month],
       QtyOrders,
       ISNULL(MonthVariation, 0) AS MonthVariation
  FROM Variation36CTE

------------------------------------------------------------------------------------------------------------------------------------------
-- 37
------------------------------------------------------------------------------------------------------------------------------------------

;WITH EmployeeAcum37CTE AS
(
      SELECT e.EmployeeID,
             e.FirstName + ' ' + e.LastName                                                                  AS FullName,
             YEAR(o.OrderDate)                                                                               AS [Year],
             SUM(od.Quantity * od.UnitPrice)                                                                 AS TotalSales,
             SUM(SUM(od.Quantity * od.UnitPrice)) OVER (PARTITION BY e.EmployeeID
                                                        ORDER BY YEAR(o.OrderDate) ROWS UNBOUNDED PRECEDING) AS Acumulated
        FROM Orders          o
        JOIN [Order Details] od ON od.OrderID = o.OrderID
        JOIN Employees       e  ON e.EmployeeID = o.EmployeeID
    GROUP BY e.EmployeeID, e.FirstName, e.LastName, YEAR(o.OrderDate)
),
Growth37CTE AS
(
    SELECT EmployeeID,
           FullName,
           [Year],
           TotalSales,
           Acumulated,
           (TotalSales - LAG(TotalSales) OVER (PARTITION BY EmployeeID ORDER BY [Year])) * 100.0
               / NULLIF(LAG(TotalSales) OVER (PARTITION BY EmployeeID ORDER BY [Year]), 0) AS PctGrowth
      FROM EmployeeAcum37CTE
)
  SELECT FullName,
         [Year],
         CAST(TotalSales AS DECIMAL(10,2)) AS TotalSales,
         CAST(Acumulated AS DECIMAL(10,2)) AS Acumulated,
         CAST(PctGrowth AS DECIMAL(10,2))  AS PctGrowth,
         Ranking
    FROM (SELECT FullName,
                 [Year],
                 TotalSales,
                 Acumulated,
                 PctGrowth,
                 RANK() OVER (PARTITION BY [Year] ORDER BY PctGrowth DESC) AS Ranking
            FROM Growth37CTE
           WHERE PctGrowth IS NOT NULL) g
   WHERE Ranking <= 3
ORDER BY [Year], Ranking

------------------------------------------------------------------------------------------------------------------------------------------
-- 38
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CategorySales38CTE AS
(
      SELECT c.CategoryName,
             SUM(od.Quantity * od.UnitPrice) AS TotalSales
        FROM Categories      c
        JOIN Products        p  ON p.CategoryID = c.CategoryID
        JOIN [Order Details] od ON od.ProductID = p.ProductID
    GROUP BY c.CategoryName
),
RankShare38CTE AS
(
    SELECT CategoryName,
           TotalSales,
           RANK() OVER (ORDER BY TotalSales DESC)       AS Ranking,
           TotalSales * 100.0 / SUM(TotalSales) OVER () AS PctShare
      FROM CategorySales38CTE
)
SELECT CategoryName,
       CAST(TotalSales AS DECIMAL(10,2)) AS TotalSales,
       Ranking,
       CAST(PctShare AS DECIMAL(10,2))   AS PctShare
  FROM RankShare38CTE
 WHERE Ranking <= 3

------------------------------------------------------------------------------------------------------------------------------------------
-- 39
------------------------------------------------------------------------------------------------------------------------------------------

;WITH AvgFreight39CTE AS
(
    SELECT AVG(Freight) AS AvgFreight
      FROM Orders
),
OrderFreight39CTE AS
(
    SELECT OrderID,
           CustomerID,
           Freight
      FROM Orders
)
    SELECT o.OrderID,
           o.CustomerID,
           CAST(o.Freight AS DECIMAL(10,2))    AS Freight,
           CAST(a.AvgFreight AS DECIMAL(10,2)) AS AvgFreight
      FROM OrderFreight39CTE o
CROSS JOIN AvgFreight39CTE   a
     WHERE o.Freight > a.AvgFreight

------------------------------------------------------------------------------------------------------------------------------------------
-- 40
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CustomerSales40CTE AS
(
      SELECT o.CustomerID,
             SUM(od.Quantity * od.UnitPrice) AS TotalSales
        FROM Orders          o
        JOIN [Order Details] od ON od.OrderID = o.OrderID
    GROUP BY o.CustomerID
),
AcumCustomer40CTE AS
(
    SELECT CustomerID,
           TotalSales,
           SUM(TotalSales) OVER (ORDER BY TotalSales DESC) AS Acumulated,
           RANK() OVER (ORDER BY TotalSales DESC)          AS Ranking
      FROM CustomerSales40CTE
)
  SELECT TOP 10
         CustomerID,
         CAST(TotalSales AS DECIMAL(10,2)) AS TotalSales,
         CAST(Acumulated AS DECIMAL(10,2)) AS Acumulated,
         Ranking
    FROM AcumCustomer40CTE
ORDER BY Ranking

------------------------------------------------------------------------------------------------------------------------------------------
-- 41
------------------------------------------------------------------------------------------------------------------------------------------

;WITH FreightRegion41CTE AS
(
      SELECT ISNULL(ShipRegion, 'Not Informed') AS ShipRegion,
             SUM(Freight)                       AS TotalFreight
        FROM Orders
    GROUP BY ISNULL(ShipRegion, 'Not Informed')
)
  SELECT ShipRegion,
         CAST(TotalFreight AS DECIMAL(10,2)) AS TotalFreight
    FROM FreightRegion41CTE
ORDER BY TotalFreight DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 42
------------------------------------------------------------------------------------------------------------------------------------------

;WITH SoldProducts42CTE AS
(
    SELECT DISTINCT ProductID
      FROM [Order Details]
)
   SELECT p.ProductID,
          p.ProductName
     FROM Products          p
LEFT JOIN SoldProducts42CTE s ON s.ProductID = p.ProductID
    WHERE s.ProductID IS NULL

------------------------------------------------------------------------------------------------------------------------------------------
-- 43
------------------------------------------------------------------------------------------------------------------------------------------

;WITH ProductMonth43CTE AS
(
      SELECT p.ProductID,
             p.ProductName,
             DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1) AS SalesMonth,
             SUM(od.Quantity * od.UnitPrice)                         AS TotalMonth
        FROM Products        p
        JOIN [Order Details] od ON od.ProductID = p.ProductID
        JOIN Orders          o  ON o.OrderID = od.OrderID
    GROUP BY p.ProductID, p.ProductName, DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1)
)
     SELECT m.ProductName,
            m.SalesMonth,
            CAST(m.TotalMonth AS DECIMAL(10,2))     AS TotalMonth,
            CAST(w.Sum3Months / 3 AS DECIMAL(10,2)) AS MovingAvg
       FROM ProductMonth43CTE m
CROSS APPLY (SELECT SUM(m2.TotalMonth) AS Sum3Months
               FROM ProductMonth43CTE m2
              WHERE m2.ProductID  = m.ProductID
                AND m2.SalesMonth >  DATEADD(MONTH, -3, m.SalesMonth)
                AND m2.SalesMonth <= m.SalesMonth) w

------------------------------------------------------------------------------------------------------------------------------------------
-- 44
------------------------------------------------------------------------------------------------------------------------------------------

;WITH MonthSales44CTE AS
(
      SELECT YEAR(o.OrderDate)               AS [Year],
             MONTH(o.OrderDate)              AS [Month],
             SUM(od.Quantity * od.UnitPrice) AS TotalMonth
        FROM Orders          o
        JOIN [Order Details] od ON od.OrderID = o.OrderID
    GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate)
),
AvgMonth44CTE AS
(
    SELECT AVG(TotalMonth) AS AvgMonth
      FROM MonthSales44CTE
)
    SELECT m.[Year],
           m.[Month],
           CAST(m.TotalMonth AS DECIMAL(10,2)) AS TotalMonth,
           CAST(a.AvgMonth AS DECIMAL(10,2))   AS AvgMonth
      FROM MonthSales44CTE m
CROSS JOIN AvgMonth44CTE a
     WHERE m.TotalMonth < a.AvgMonth

------------------------------------------------------------------------------------------------------------------------------------------
-- 45
------------------------------------------------------------------------------------------------------------------------------------------

;WITH Delivery45CTE AS
(
    SELECT DISTINCT
           s.SupplierID,
           s.CompanyName,
           o.OrderID,
           DATEDIFF(DAY, o.OrderDate, o.ShippedDate) AS DeliveryDays
      FROM Orders          o
      JOIN [Order Details] od ON od.OrderID = o.OrderID
      JOIN Products        p  ON p.ProductID = od.ProductID
      JOIN Suppliers       s  ON s.SupplierID = p.SupplierID
     WHERE o.ShippedDate IS NOT NULL
)
  SELECT CompanyName,
         CAST(AVG(CAST(DeliveryDays AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS AvgDeliveryDays
    FROM Delivery45CTE
GROUP BY CompanyName

------------------------------------------------------------------------------------------------------------------------------------------
-- 46
------------------------------------------------------------------------------------------------------------------------------------------

-- Estou adotando aqui o ultimo ano do recorte, isto e, os 12 meses anteriores ao maior OrderDate presente
;WITH RefDate46CTE AS
(
    SELECT MAX(OrderDate) AS RefDate
      FROM Orders
),
LastOrder46CTE AS
(
      SELECT CustomerID,
             MAX(OrderDate) AS LastOrderDate
        FROM Orders
    GROUP BY CustomerID
)
    SELECT c.CustomerID,
           c.CompanyName,
           CAST(l.LastOrderDate AS DATE) AS LastOrderDate
      FROM Customers       c
 LEFT JOIN LastOrder46CTE  l ON l.CustomerID = c.CustomerID
CROSS JOIN RefDate46CTE    r
     WHERE l.LastOrderDate < DATEADD(YEAR, -1, r.RefDate)
        OR l.LastOrderDate IS NULL

------------------------------------------------------------------------------------------------------------------------------------------
-- 47
------------------------------------------------------------------------------------------------------------------------------------------

;WITH PriceVariation47CTE AS
(
      SELECT p.ProductName,
             MIN(od.UnitPrice) AS MinPrice,
             MAX(od.UnitPrice) AS MaxPrice
        FROM Products        p
        JOIN [Order Details] od ON od.ProductID = p.ProductID
    GROUP BY p.ProductName
)
  SELECT ProductName,
         CAST(MinPrice AS DECIMAL(10,2))            AS MinPrice,
         CAST(MaxPrice AS DECIMAL(10,2))            AS MaxPrice,
         CAST(MaxPrice - MinPrice AS DECIMAL(10,2)) AS PriceVariation
    FROM PriceVariation47CTE
ORDER BY PriceVariation DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 48
------------------------------------------------------------------------------------------------------------------------------------------

;WITH RegionOrders48CTE AS
(
      SELECT ISNULL(ShipRegion, 'Not Informed')                          AS ShipRegion,
             COUNT(*)                                                    AS QtyOrders,
             SUM(CASE WHEN ShippedDate > RequiredDate THEN 1 ELSE 0 END) AS QtyLate
        FROM Orders
    GROUP BY ISNULL(ShipRegion, 'Not Informed')
)
SELECT ShipRegion,
       QtyOrders,
       QtyLate,
       CAST(QtyLate * 100.0 / NULLIF(QtyOrders, 0) AS DECIMAL(10,2)) AS PctLate
  FROM RegionOrders48CTE

------------------------------------------------------------------------------------------------------------------------------------------
-- 49
------------------------------------------------------------------------------------------------------------------------------------------

;WITH OrderItems49CTE AS
(
      SELECT OrderID,
             COUNT(DISTINCT ProductID) AS QtyProducts
        FROM [Order Details]
    GROUP BY OrderID
)
SELECT OrderID,
       QtyProducts
  FROM OrderItems49CTE
 WHERE QtyProducts = (SELECT MAX(QtyProducts) FROM OrderItems49CTE)

------------------------------------------------------------------------------------------------------------------------------------------
-- 50
------------------------------------------------------------------------------------------------------------------------------------------

;WITH EmployeeYear50CTE AS
(
      SELECT e.FirstName + ' ' + e.LastName  AS FullName,
             YEAR(o.OrderDate)               AS [Year],
             SUM(od.Quantity * od.UnitPrice) AS TotalYear
        FROM Orders          o
        JOIN [Order Details] od ON od.OrderID = o.OrderID
        JOIN Employees       e  ON e.EmployeeID = o.EmployeeID
    GROUP BY e.FirstName, e.LastName, YEAR(o.OrderDate)
)
SELECT FullName,
       [Year],
       CAST(TotalYear AS DECIMAL(10,2))                                                   AS TotalYear,
       CAST(SUM(TotalYear) OVER (PARTITION BY FullName ORDER BY [Year]) AS DECIMAL(10,2)) AS Acumulated
  FROM EmployeeYear50CTE

------------------------------------------------------------------------------------------------------------------------------------------
-- 51
------------------------------------------------------------------------------------------------------------------------------------------

;WITH ProductCategory51CTE AS
(
      SELECT c.CategoryName,
             p.ProductName,
             SUM(od.Quantity)                                                       AS Quantity,
             RANK() OVER (PARTITION BY c.CategoryID ORDER BY SUM(od.Quantity) DESC) AS Ranking
        FROM Categories      c
        JOIN Products        p  ON p.CategoryID = c.CategoryID
        JOIN [Order Details] od ON od.ProductID = p.ProductID
    GROUP BY c.CategoryID, c.CategoryName, p.ProductName
)
  SELECT CategoryName,
         ProductName,
         Quantity,
         Ranking
    FROM ProductCategory51CTE
   WHERE Ranking <= 5
ORDER BY CategoryName, Ranking

------------------------------------------------------------------------------------------------------------------------------------------
-- 52
------------------------------------------------------------------------------------------------------------------------------------------

-- Estou adotando aqui os ultimos 06 meses anteriores ao maior OrderDate presente
;WITH RefDate52CTE AS
(
    SELECT MAX(OrderDate) AS RefDate
      FROM Orders
),
CustomerSales52CTE AS
(
      SELECT o.CustomerID,
             SUM(od.Quantity * od.UnitPrice) AS TotalSales
        FROM Orders          o
        JOIN [Order Details] od ON od.OrderID = o.OrderID
  CROSS JOIN RefDate52CTE    r
       WHERE o.OrderDate > DATEADD(MONTH, -6, r.RefDate)
    GROUP BY o.CustomerID
)
SELECT CustomerID,
       CAST(TotalSales AS DECIMAL(10,2)) AS TotalSales
  FROM CustomerSales52CTE

------------------------------------------------------------------------------------------------------------------------------------------
-- 53
------------------------------------------------------------------------------------------------------------------------------------------

;WITH NeverSold53CTE AS
(
    SELECT p.SupplierID
      FROM Products p
     WHERE NOT EXISTS (SELECT 1
                         FROM [Order Details] od
                        WHERE od.ProductID = p.ProductID)
)
SELECT DISTINCT
       s.SupplierID,
       s.CompanyName
  FROM Suppliers       s
  JOIN NeverSold53CTE  n ON n.SupplierID = s.SupplierID

------------------------------------------------------------------------------------------------------------------------------------------
-- 54
------------------------------------------------------------------------------------------------------------------------------------------

-- Estou adotando aqui os ultimos 03 anos anteriores ao maior OrderDate presente
;WITH RefDate54CTE AS
(
    SELECT MAX(OrderDate) AS RefDate
      FROM Orders
),
OrdersMonth54CTE AS
(
      SELECT YEAR(o.OrderDate)  AS [Year],
             MONTH(o.OrderDate) AS [Month],
             COUNT(*)           AS QtyOrders
        FROM Orders       o
  CROSS JOIN RefDate54CTE r
       WHERE o.OrderDate > DATEADD(YEAR, -3, r.RefDate)
    GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate)
)
  SELECT [Year],
         [Month],
         QtyOrders
    FROM OrdersMonth54CTE
ORDER BY [Year], [Month]

------------------------------------------------------------------------------------------------------------------------------------------
-- 55
------------------------------------------------------------------------------------------------------------------------------------------

;WITH AvgFreight55CTE AS
(
    SELECT AVG(Freight) AS AvgFreight
      FROM Orders
),
CustomersAbove55CTE AS
(
    SELECT DISTINCT 
           o.CustomerID
      FROM Orders          o
CROSS JOIN AvgFreight55CTE a
     WHERE o.Freight > a.AvgFreight
)
   SELECT c.CustomerID,
          c.CompanyName
     FROM Customers           c
LEFT JOIN CustomersAbove55CTE a ON a.CustomerID = c.CustomerID
    WHERE a.CustomerID IS NULL
      AND EXISTS (SELECT 1 FROM Orders o WHERE o.CustomerID = c.CustomerID)

------------------------------------------------------------------------------------------------------------------------------------------
-- 56
------------------------------------------------------------------------------------------------------------------------------------------

;WITH EmployeeQuarter56CTE AS
(
      SELECT e.FirstName + ' ' + e.LastName  AS FullName,
             YEAR(o.OrderDate)               AS [Year],
             DATEPART(QUARTER, o.OrderDate)  AS [Quarter],
             SUM(od.Quantity * od.UnitPrice) AS TotalSales
        FROM Orders          o
        JOIN [Order Details] od ON od.OrderID = o.OrderID
        JOIN Employees       e  ON e.EmployeeID = o.EmployeeID
    GROUP BY e.FirstName, e.LastName, YEAR(o.OrderDate), DATEPART(QUARTER, o.OrderDate)
)
  SELECT FullName,
         [Year],
         [Quarter],
         CAST(TotalSales AS DECIMAL(10,2)) AS TotalSales
    FROM EmployeeQuarter56CTE
ORDER BY FullName, [Year], [Quarter]

------------------------------------------------------------------------------------------------------------------------------------------
-- 57
------------------------------------------------------------------------------------------------------------------------------------------

-- Adotado neste contexto um valor acumulado adotado de 5000
;WITH ProductSales57CTE AS
(
      SELECT p.ProductName,
             SUM(od.Quantity * od.UnitPrice) AS TotalSales
        FROM Products        p
        JOIN [Order Details] od ON od.ProductID = p.ProductID
    GROUP BY p.ProductName
)
SELECT ProductName,
       CAST(TotalSales AS DECIMAL(10,2)) AS TotalSales
  FROM ProductSales57CTE
 WHERE TotalSales < 5000

------------------------------------------------------------------------------------------------------------------------------------------
-- 58
------------------------------------------------------------------------------------------------------------------------------------------

;WITH DistinctProducts58CTE AS
(
      SELECT c.CategoryName,
             COUNT(DISTINCT od.ProductID) AS QtyProducts
        FROM Categories      c
        JOIN Products        p  ON p.CategoryID = c.CategoryID
        JOIN [Order Details] od ON od.ProductID = p.ProductID
    GROUP BY c.CategoryName
)
SELECT CategoryName,
       QtyProducts
  FROM DistinctProducts58CTE

------------------------------------------------------------------------------------------------------------------------------------------
-- 59
------------------------------------------------------------------------------------------------------------------------------------------

;WITH Gap59CTE AS
(
    SELECT CustomerID,
           OrderID,
           OrderDate,
           LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID) AS LastOrderDate
      FROM Orders
)
SELECT CustomerID,
       OrderID,
       CAST(LastOrderDate AS DATE)               AS LastOrderDate,
       CAST(OrderDate AS DATE)                   AS OrderDate,
       DATEDIFF(DAY, LastOrderDate, OrderDate)   AS DaysBetween
  FROM Gap59CTE
 WHERE OrderDate > DATEADD(MONTH, 6, LastOrderDate)

------------------------------------------------------------------------------------------------------------------------------------------
-- 60
------------------------------------------------------------------------------------------------------------------------------------------

;WITH SupplierProduct60CTE AS
(
      SELECT s.CompanyName,
             p.ProductName,
             SUM(od.Quantity)                                                       AS Quantity,
             RANK() OVER (PARTITION BY s.SupplierID ORDER BY SUM(od.Quantity) DESC) AS Ranking
        FROM Suppliers       s
        JOIN Products        p  ON p.SupplierID = s.SupplierID
        JOIN [Order Details] od ON od.ProductID = p.ProductID
    GROUP BY s.SupplierID, s.CompanyName, p.ProductName
)
  SELECT CompanyName,
         ProductName,
         Quantity,
         Ranking
    FROM SupplierProduct60CTE
   WHERE Ranking <= 3
ORDER BY CompanyName, Ranking