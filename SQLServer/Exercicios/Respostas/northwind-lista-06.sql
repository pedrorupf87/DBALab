
USE NORTHWIND
GO

------------------------------------------------------------------------------------------------------------------------------------------
-- 01
------------------------------------------------------------------------------------------------------------------------------------------

-- Valor de vendas = itens dos pedidos (Order Details). Freight é apenas o frete.
-- COUNT(DISTINCT): depois do JOIN há uma linha por item, não por pedido

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
	    FROM Categories       c
	    JOIN Products         p ON p.CategoryID = c.CategoryID
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

-- A média de comparação é a média dos TOTAIS por funcionário, e não a média de uma linha de item

;WITH EmployeeSales05CTE AS
(
	SELECT e.FirstName + ' ' + e.LastName  AS FullName,
	       SUM(od.Quantity * od.UnitPrice) AS TotalSales
	  FROM Orders           o
	  JOIN [Order Details] od ON od.OrderID = o.OrderID
	  JOIN Employees        e ON e.EmployeeID = o.EmployeeID
	GROUP BY e.FirstName, e.LastName
),
	AvgSales05CTE AS
(
	SELECT AVG(TotalSales) AS AvgSales
	  FROM EmployeeSales05CTE
)
    SELECT FullName,
           TotalSales,
           AvgSales
      FROM EmployeeSales05CTE
CROSS JOIN AvgSales05CTE
     WHERE TotalSales > AvgSales

------------------------------------------------------------------------------------------------------------------------------------------
-- 06
------------------------------------------------------------------------------------------------------------------------------------------

-- Países diferentes em que cada produto foi vendido: COUNT(DISTINCT ShipCountry) por produto

;WITH SalesCountry06CTE AS
(
	SELECT p.ProductName,
	       COUNT(DISTINCT o.ShipCountry) AS QuantityOfCountries
	  FROM Orders           o
	  JOIN [Order Details] od ON od.OrderID = o.OrderID
	  JOIN Products         p ON p.ProductID = od.ProductID
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
         Freight
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
	  FROM Orders           o
	  JOIN [Order Details] od ON od.OrderID = o.OrderID
	  JOIN Employees        e ON e.EmployeeID = o.EmployeeID
	GROUP BY e.FirstName, e.LastName
)
SELECT FullName,
       SUM(TotalSales) OVER (ORDER BY FullName) AS TotalAcumulated
  FROM TotalSales08CTE

------------------------------------------------------------------------------------------------------------------------------------------
-- 09
------------------------------------------------------------------------------------------------------------------------------------------

-- O total é por FORNECEDOR (soma das vendas de todos os seus produtos)

;WITH SupplierSales09CTE AS
(
	  SELECT s.SupplierID,
	         s.CompanyName,
	  	     SUM(od.Quantity * od.UnitPrice) AS TotalSupplier
	    FROM Suppliers        s
	    JOIN Products         p ON p.SupplierID = s.SupplierID
	    JOIN [Order Details] od ON od.ProductID = p.ProductID
	GROUP BY s.SupplierID, s.CompanyName
)
SELECT *
  FROM SupplierSales09CTE
 WHERE TotalSupplier > 15000

------------------------------------------------------------------------------------------------------------------------------------------
-- 10
------------------------------------------------------------------------------------------------------------------------------------------

-- "Em termos de quantidade total" = soma das unidades vendidas, e não o número de linhas

;WITH MostProductsSold10CTE AS
(
	  SELECT p.ProductName,
	         SUM(od.Quantity) AS Quantity
	    FROM [Order Details] od
	    JOIN Products         p ON p.ProductID = od.ProductID
	GROUP BY p.ProductName
)
  SELECT TOP 10 *
    FROM MostProductsSold10CTE
ORDER BY Quantity DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 11
------------------------------------------------------------------------------------------------------------------------------------------

-- O Northwind não tem subcategorias: a hierarquia é simulada com categoria (nível 1) -> produto (nível 2).
-- Toda CTE recursiva precisa de uma âncora que retorne linhas e de uma condição de parada no membro recursivo

;WITH CategoriesHierarqhy11CTE AS
(
    -- Âncora: categorias (nível 1)
    SELECT CategoryID,
           CAST(NULL AS INT)                   AS ProductID,
           CAST(CategoryName AS NVARCHAR(MAX)) AS [Location],
           1                                   AS [Level]
      FROM Categories

    UNION ALL

    -- Recursão: produtos de cada categoria (nível 2). O filtro de nível é a condição de parada
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

-- Hierarquia de vendas do Northwind: região (nível 1) -> território (nível 2) -> funcionário (nível 3).
-- A consulta final conta os níveis e os nós de cada região

;WITH RegionsHierarqhy12CTE AS
(
    -- Âncora: regiões (nível 1)
    SELECT r.RegionID,
           CAST(NULL AS NVARCHAR(20))                        AS TerritoryID,
           CAST(RTRIM(r.RegionDescription) AS NVARCHAR(MAX)) AS [Location],
           1                                                 AS [Level]
      FROM Region r

    UNION ALL

    -- Recursão: territórios de cada região (nível 2)
    SELECT h.RegionID,
           CAST(t.TerritoryID AS NVARCHAR(20)),
           CAST(h.[Location] + N' -> ' + RTRIM(t.TerritoryDescription) AS NVARCHAR(MAX)),
           h.[Level] + 1
      FROM RegionsHierarqhy12CTE h
      JOIN Territories           t ON t.RegionID = h.RegionID
     WHERE h.[Level] = 1

    UNION ALL

    -- Recursão: funcionários de cada território (nível 3). Não há nível 4, então a recursão termina aqui
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
         RTRIM(r.RegionDescription)                     AS NomeRegiao,
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

-- Hierarquia simulada: categoria (nível 1) -> fornecedor com produto na categoria (nível 2) -> produto (nível 3).
-- O par categoria/fornecedor é resolvido antes, porque o membro recursivo não aceita DISTINCT nem subconsulta

;WITH CategorySuppliers13CTE AS
(
    SELECT DISTINCT
           CategoryID,
           SupplierID
      FROM Products
),
SuppliersHierarqhy13CTE AS
(
    -- Âncora: categorias (nível 1)
    SELECT c.CategoryID,
           CAST(NULL AS INT)                     AS SupplierID,
           CAST(c.CategoryName AS NVARCHAR(MAX)) AS [Location],
           1                                     AS [Level]
      FROM Categories c

    UNION ALL

    -- Recursão: fornecedores de cada categoria (nível 2)
    SELECT h.CategoryID,
           s.SupplierID,
           CAST(h.[Location] + N' -> ' + s.CompanyName AS NVARCHAR(MAX)),
           h.[Level] + 1
      FROM SuppliersHierarqhy13CTE h
      JOIN CategorySuppliers13CTE  cs ON cs.CategoryID = h.CategoryID
      JOIN Suppliers               s  ON s.SupplierID  = cs.SupplierID
     WHERE h.[Level] = 1

    UNION ALL

    -- Recursão: produtos do fornecedor dentro da categoria (nível 3). Não há nível 4, então a recursão termina aqui
    SELECT h.CategoryID,
           h.SupplierID,
           CAST(h.[Location] + N' -> ' + p.ProductName AS NVARCHAR(MAX)),
           h.[Level] + 1
      FROM SuppliersHierarqhy13CTE h
      JOIN Products                p ON p.CategoryID = h.CategoryID
                                    AND p.SupplierID = h.SupplierID
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

;WITH SalesByYear14CTE AS (
      SELECT YEAR(OrderDate)                 AS [Year],
             SUM(od.Quantity * od.UnitPrice) AS TotalSales
        FROM Orders           o
        JOIN [Order Details] od ON o.OrderID = od.OrderID
       WHERE YEAR(OrderDate) >= 1996
    GROUP BY YEAR(OrderDate)
)
, Acumulated AS (
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
      JOIN Acumulated a ON s.[Year] = a.[Year] + 1
)
  SELECT [Year],
         TotalSales,
         Acumulated
    FROM Acumulated
ORDER BY [Year]

------------------------------------------------------------------------------------------------------------------------------------------
-- 15
------------------------------------------------------------------------------------------------------------------------------------------

-- Região (nível 1) -> território, tratado como sub-região (nível 2).
-- A venda é atribuída a todos os territórios do funcionário que atendeu o pedido; como um funcionário
-- cobre vários territórios, a mesma venda aparece em mais de um território

;WITH TerritorySales15CTE AS
(
      SELECT t.TerritoryID,
             t.RegionID,
             SUM(od.Quantity) AS TotalProducts
        FROM Territories         t
        JOIN EmployeeTerritories et ON et.TerritoryID = t.TerritoryID
        JOIN Orders              o  ON o.EmployeeID   = et.EmployeeID
        JOIN [Order Details]     od ON od.OrderID     = o.OrderID
    GROUP BY t.TerritoryID, t.RegionID
),
RegionProducts15CTE AS
(
    -- Âncora: regiões (nível 1)
    SELECT r.RegionID,
           CAST(NULL AS NVARCHAR(20))                        AS TerritoryID,
           CAST(RTRIM(r.RegionDescription) AS NVARCHAR(MAX)) AS [Location],
           1                                                 AS [Level]
      FROM Region r

    UNION ALL

    -- Recursão: territórios de cada região (nível 2). O filtro de nível é a condição de parada
    SELECT pr.RegionID,
           CAST(t.TerritoryID AS NVARCHAR(20)),
           CAST(pr.[Location] + N' -> ' + RTRIM(t.TerritoryDescription) AS NVARCHAR(MAX)),
           pr.[Level] + 1
      FROM RegionProducts15CTE pr
      JOIN Territories         t ON t.RegionID = pr.RegionID
     WHERE pr.[Level] = 1
)
  SELECT pr.[Location],
         pr.[Level],
         CASE WHEN pr.[Level] = 1 THEN ( SELECT SUM(ts.TotalProducts) FROM TerritorySales15CTE ts WHERE ts.RegionID = pr.RegionID )
              ELSE ( SELECT ts.TotalProducts FROM TerritorySales15CTE ts WHERE ts.TerritoryID = pr.TerritoryID )
          END AS TotalProducts
    FROM RegionProducts15CTE pr
ORDER BY pr.[Location]

------------------------------------------------------------------------------------------------------------------------------------------
-- 16
------------------------------------------------------------------------------------------------------------------------------------------

-- Os pedidos do produto são numerados e percorridos um a um pela recursão.
-- A recursão para sozinha quando não existe o pedido seguinte (RowNum + 1)

;WITH PedidosProduto AS
(
    SELECT o.CustomerID,
           ROW_NUMBER() OVER (ORDER BY o.OrderID) AS RowNum
      FROM Orders           o
      JOIN [Order Details] od ON od.OrderID = o.OrderID
     WHERE od.ProductID = 1 -- Produto específico (exemplo)
),
ClientesProduto AS
(
    -- Âncora: primeiro pedido do produto
    SELECT CustomerID,
           RowNum
      FROM PedidosProduto
     WHERE RowNum = 1

    UNION ALL

    -- Recursão: pedido seguinte
    SELECT pp.CustomerID,
           pp.RowNum
      FROM PedidosProduto  pp
      JOIN ClientesProduto cp ON pp.RowNum = cp.RowNum + 1
)
  SELECT DISTINCT
         c.CustomerID,
         c.CompanyName
    FROM ClientesProduto cp
    JOIN Customers       c ON c.CustomerID = cp.CustomerID
ORDER BY c.CustomerID
OPTION (MAXRECURSION 1000)

------------------------------------------------------------------------------------------------------------------------------------------
-- 17
------------------------------------------------------------------------------------------------------------------------------------------

-- Os pedidos de cada funcionário são numerados e a recursão acumula a quantidade pedido a pedido.
-- O total do funcionário é o maior acumulado. MAXRECURSION acima de 100 porque há funcionário com mais de 100 pedidos

;WITH OrderQuantity17CTE AS
(
      SELECT o.EmployeeID,
             SUM(od.Quantity)                                               AS Quantity,
             ROW_NUMBER() OVER (PARTITION BY o.EmployeeID ORDER BY o.OrderID) AS RowNum
        FROM Orders           o
        JOIN [Order Details] od ON od.OrderID = o.OrderID
    GROUP BY o.EmployeeID, o.OrderID
),
ProductsByEmployee17CTE AS
(
    -- Âncora: primeiro pedido de cada funcionário
    SELECT EmployeeID,
           RowNum,
           Quantity AS Acumulated
      FROM OrderQuantity17CTE
     WHERE RowNum = 1

    UNION ALL

    -- Recursão: soma o pedido seguinte do mesmo funcionário
    SELECT oq.EmployeeID,
           oq.RowNum,
           pe.Acumulated + oq.Quantity
      FROM OrderQuantity17CTE      oq
      JOIN ProductsByEmployee17CTE pe ON oq.EmployeeID = pe.EmployeeID
                                     AND oq.RowNum     = pe.RowNum + 1
)
  SELECT EmployeeID,
         MAX(Acumulated) AS Quantity
    FROM ProductsByEmployee17CTE
GROUP BY EmployeeID
ORDER BY EmployeeID DESC
OPTION (MAXRECURSION 1000)

-- PENDENTE: exercícios 18 a 60 ainda não resolvidos

