
USE Northwind
GO

--------------------------------------------------------
-- LISTA DE EXERCICIOS - LIVRO: SQL PRACTICE PROBLEMS --
--------------------------------------------------------


-- O livro usa uma versao propria do Northwind, com pedidos entre 2014 e 2016
-- Estas respostas rodam no Northwind padrao (1996 a 1998)
-- Logo, pra facilitar as coisas, onde o livro pede 1996, uso 2014; onde pede 2015, uso 1997; e onde pede 2016, uso 1998


---------------------------
-- INTRODUCTORY PROBLEMS --
---------------------------


------------------------------------------------------------------------------------------------------------------------------------------
-- 01
------------------------------------------------------------------------------------------------------------------------------------------

SELECT *
  FROM Shippers

------------------------------------------------------------------------------------------------------------------------------------------
-- 02
------------------------------------------------------------------------------------------------------------------------------------------

SELECT CategoryName,
       [Description]
  FROM Categories

------------------------------------------------------------------------------------------------------------------------------------------
-- 03
------------------------------------------------------------------------------------------------------------------------------------------

SELECT FirstName,
       LastName,
       HireDate
  FROM Employees
 WHERE Title = 'Sales Representative'

------------------------------------------------------------------------------------------------------------------------------------------
-- 04
------------------------------------------------------------------------------------------------------------------------------------------

SELECT FirstName,
       LastName,
       HireDate
  FROM Employees
 WHERE Title = 'Sales Representative'
   AND Country = 'USA'

------------------------------------------------------------------------------------------------------------------------------------------
-- 05
------------------------------------------------------------------------------------------------------------------------------------------

SELECT OrderID,
       OrderDate
  FROM Orders
 WHERE EmployeeID = 5

------------------------------------------------------------------------------------------------------------------------------------------
-- 06
------------------------------------------------------------------------------------------------------------------------------------------

SELECT SupplierID,
       ContactName,
       ContactTitle
  FROM Suppliers
 WHERE CONtactTitle != 'Marketing Manager'

------------------------------------------------------------------------------------------------------------------------------------------
-- 07
------------------------------------------------------------------------------------------------------------------------------------------

SELECT ProductID,
       ProductName
  FROM Products
 WHERE ProductName LIKE '%queso%'

------------------------------------------------------------------------------------------------------------------------------------------
-- 08
------------------------------------------------------------------------------------------------------------------------------------------

SELECT OrderID,
       CustomerID,
       ShipCountry
  FROM Orders
 WHERE ShipCountry = 'Belgium'
    OR ShipCountry = 'France'

------------------------------------------------------------------------------------------------------------------------------------------
-- 09
------------------------------------------------------------------------------------------------------------------------------------------

SELECT OrderID,
       CustomerID,
       ShipCountry
  FROM Orders
 WHERE ShipCountry IN ('Brazil', 'Mexico', 'Argentina', 'Venezuela')

------------------------------------------------------------------------------------------------------------------------------------------
-- 10
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT FirstName,
         LastName,
         Title,
         BirthDate
    FROM Employees
ORDER BY BirthDate

------------------------------------------------------------------------------------------------------------------------------------------
-- 11
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT FirstName,
         LastName,
         Title,
         CONVERT(DATE, BirthDate) AS BirthDate
    FROM Employees
ORDER BY BirthDate

------------------------------------------------------------------------------------------------------------------------------------------
-- 12
------------------------------------------------------------------------------------------------------------------------------------------

SELECT FirstName,
       LastName,
       FirstName + ' ' + LastName AS FullName
  FROM Employees

------------------------------------------------------------------------------------------------------------------------------------------
-- 13
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT OrderID,
         ProductID,
         UnitPrice,
         Quantity,
         (UnitPrice * Quantity) AS TotalPrice
    FROM [Order Details]
ORDER BY OrderID, ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 14
------------------------------------------------------------------------------------------------------------------------------------------

SELECT COUNT(*) AS TotalCustomers
  FROM Customers

------------------------------------------------------------------------------------------------------------------------------------------
-- 15
------------------------------------------------------------------------------------------------------------------------------------------

SELECT CAST(min(OrderDate) AS DATE) AS FirstOrderDate
  FROM Orders

------------------------------------------------------------------------------------------------------------------------------------------
-- 16
------------------------------------------------------------------------------------------------------------------------------------------

SELECT DISTINCT
       Country
  FROM Customers

------------------------------------------------------------------------------------------------------------------------------------------
-- 17
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT ContactTitle,
         COUNT(*) AS Quantity
	FROM Customers
GROUP BY ContactTitle
ORDER BY Quantity DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 18
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT p.ProductID,
         p.ProductName,
		     s.CompanyName
    FROM Products  p
	  JOIN Suppliers s ON s.SupplierID = p.SupplierID
ORDER BY ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 19
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT o.OrderID,
         CAST(o.OrderDate AS date) AS OrderDate,
		     s.CompanyName
    FROM Orders   o
	  JOIN Shippers s ON s.ShipperID = o.ShipVia
   WHERE o.OrderID < 10300
ORDER BY o.OrderID


---------------------------
-- INTERMEDIATE PROBLEMS --
---------------------------


------------------------------------------------------------------------------------------------------------------------------------------
-- 20
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT c.CategoryName,
         COUNT(*) AS Quantity
    FROM Products   p
	  JOIN Categories c ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryName
ORDER BY Quantity DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 21
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT Country,
         City,
		     COUNT(*) AS Quantity
    FROM Customers
GROUP BY Country, City
ORDER BY Quantity DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 22
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT ProductID,
         ProductName,
		     UnitsInStock,
		     ReorderLevel
    FROM Products
   WHERE UnitsInStock < ReorderLevel
ORDER BY ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 23
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT ProductID,
         ProductName,
		     UnitsInStock,
		     UnitsOnOrder,
		     ReorderLevel,
		     Discontinued
    FROM Products
   WHERE (UnitsInStock + UnitsOnOrder) <= ReorderLevel
     AND Discontinued = 0
ORDER BY ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 24
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT CustomerID,
         CompanyName,
		     Region
    FROM Customers
ORDER BY CASE WHEN Region IS NULL THEN 1 ELSE 0 END, Region, CustomerID

------------------------------------------------------------------------------------------------------------------------------------------
-- 25
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT TOP 3
         ShipCountry,
         AVG(Freight) AS AverageFreight
    FROM Orders
GROUP BY ShipCountry
ORDER BY AverageFreight DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 26
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT TOP 3
         ShipCountry,
         AVG(Freight) AS AverageFreight
    FROM Orders
   WHERE CAST(OrderDate AS DATE) BETWEEN '1997-01-01' AND '1997-12-31'
GROUP BY ShipCountry
ORDER BY AverageFreight DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 27
------------------------------------------------------------------------------------------------------------------------------------------

SELECT OrderID,
       OrderDate
  FROM Orders
 WHERE OrderDate >= '19971231'
   AND OrderDate < '19980101'

------------------------------------------------------------------------------------------------------------------------------------------
-- 28
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT TOP 3
         ShipCountry,
         AVG(Freight) AS AverageFreight
    FROM Orders
   WHERE OrderDate >= DATEADD(yy, -1, (SELECT MAX(OrderDate)
                                         FROM Orders))
GROUP BY ShipCountry
ORDER BY AverageFreight DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 29
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT o.EmployeeID,
         e.LastName,
		     o.OrderID,
		     p.ProductName,
		     od.Quantity
    FROM Orders          o
	  JOIN [Order Details] od ON od.OrderID = o.OrderID
	  JOIN Employees       e  ON e.EmployeeID = o.EmployeeID
	  JOIN Products        p  ON p.ProductID = od.ProductID
ORDER BY o.OrderID, p.ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 30
------------------------------------------------------------------------------------------------------------------------------------------

   SELECT c.CustomerID AS Customer_CustomerID,
          o.CustomerID AS Order_CustomerID
     FROM Customers c
LEFT JOIN Orders    o ON o.CustomerID = c.CustomerID
    WHERE o.CustomerID is null

------------------------------------------------------------------------------------------------------------------------------------------
-- 31
------------------------------------------------------------------------------------------------------------------------------------------

   SELECT c.CustomerID AS Customer_CustomerID,
          o.CustomerID AS Order_CustomerID
     FROM Customers c
LEFT JOIN Orders    o ON o.CustomerID = c.CustomerID AND o.EmployeeID = 4
    WHERE o.CustomerID IS NULL


-----------------------
-- ADVANCED PROBLEMS --
-----------------------


------------------------------------------------------------------------------------------------------------------------------------------
-- 32
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT c.CustomerID,
         c.CompanyName,
		     o.OrderID,
		     SUM((od.Quantity * od.UnitPrice)) AS TotalPrice
    FROM Orders          o
	  JOIN Customers       c  ON c.CustomerID = o.CustomerID
	  JOIN [Order Details] od ON od.OrderID = o.OrderID
   WHERE YEAR(o.OrderDate) = 1998
GROUP BY c.CustomerID, c.CompanyName, o.OrderID
  HAVING SUM((od.Quantity * od.UnitPrice)) >= 10000
ORDER BY TotalPrice DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 33
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT c.CustomerID,
         c.CompanyName,
		     SUM((od.Quantity * od.UnitPrice)) AS TotalPrice
    FROM Orders          o
	  JOIN Customers       c  ON c.CustomerID = o.CustomerID
	  JOIN [Order Details] od ON od.OrderID = o.OrderID
   WHERE YEAR(o.OrderDate) = 1998  
GROUP BY c.CustomerID, c.CompanyName
  HAVING SUM((od.Quantity * od.UnitPrice)) >= 15000
ORDER BY TotalPrice DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 34
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT c.CustomerID,
         c.CompanyName,
		     SUM((od.Quantity * od.UnitPrice))                     AS TotalPrice,
		     SUM((od.Quantity * od.UnitPrice) * (1 - od.Discount)) AS TotalWithDiscount
    FROM Orders          o
	  JOIN Customers       c  ON c.CustomerID = o.CustomerID
	  JOIN [Order Details] od ON od.OrderID = o.OrderID
   WHERE YEAR(o.OrderDate) = 1998  
GROUP BY c.CustomerID, c.CompanyName
  HAVING SUM((od.Quantity * od.UnitPrice) * (1 - od.Discount)) >= 10000
ORDER BY TotalWithDiscount DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 35
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT EmployeeID,
         OrderID,
		     OrderDate
    FROM Orders
   WHERE OrderDate = EOMONTH(OrderDate)
ORDER BY EmployeeID, OrderID

------------------------------------------------------------------------------------------------------------------------------------------
-- 36
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT TOP 10
         OrderID,
         COUNT(*) AS TotalOrder
    FROM [Order Details]
GROUP BY OrderID
ORDER BY TotalOrder DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 37
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT TOP 2 percent
         OrderID
    FROM Orders
ORDER BY NEWID()

------------------------------------------------------------------------------------------------------------------------------------------
-- 38
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT o.OrderID
    FROM Orders          o
	  JOIN [Order Details] od ON od.OrderID = o.OrderID
   WHERE od.Quantity >= 60
GROUP BY o.OrderID, od.Quantity
  HAVING COUNT(o.OrderID) > 1
ORDER BY o.OrderID

------------------------------------------------------------------------------------------------------------------------------------------
-- 39
------------------------------------------------------------------------------------------------------------------------------------------

;WITH OrderIdCTE AS
(
  SELECT o.OrderID
    FROM Orders          o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
   WHERE od.Quantity >= 60
GROUP BY o.OrderID, od.Quantity
  HAVING COUNT(o.OrderID) > 1
)
SELECT od.OrderID,
       od.ProductID,
	     od.Quantity,
	     od.UnitPrice,
	     od.Discount
  FROM Orders          o
  JOIN [Order Details] od ON od.OrderID = o.OrderID
 WHERE od.OrderID IN (SELECT OrderID FROM OrderIdCTE)

------------------------------------------------------------------------------------------------------------------------------------------
-- 40
------------------------------------------------------------------------------------------------------------------------------------------

;WITH OrderIdCTE AS
(
  SELECT o.OrderID
    FROM Orders o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
   WHERE od.Quantity >= 60
GROUP BY o.OrderID, od.Quantity
  HAVING COUNT(o.OrderID) > 1
)
SELECT distinct 
       od.OrderID,
       od.ProductID,
	     od.Quantity,
	     od.UnitPrice,
	     od.Discount
  FROM Orders          o
  JOIN [Order Details] od ON od.OrderID = o.OrderID
 WHERE od.OrderID IN (SELECT OrderID FROM OrderIdCTE)

------------------------------------------------------------------------------------------------------------------------------------------
-- 41
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT OrderID,
         OrderDate,
		     RequiredDate,
		     ShippedDate
    FROM Orders
   WHERE RequiredDate <= ShippedDate

------------------------------------------------------------------------------------------------------------------------------------------
-- 42
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT o.EmployeeID,
         e.LastName,
		     COUNT(*) AS TotalLateOrders
    FROM Orders    o
	  JOIN Employees e ON e.EmployeeID = o.EmployeeID
   WHERE o.RequiredDate <= o.ShippedDate
GROUP BY o.EmployeeID,
         e.LastName
ORDER BY TotalLateOrders DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 43
------------------------------------------------------------------------------------------------------------------------------------------

;WITH LateOrdersCTE AS
(
  SELECT EmployeeID,
         COUNT(*) AS TotalLateOrders
    FROM Orders
   WHERE RequiredDate <= ShippedDate
GROUP BY EmployeeID
),
AllOrdersCTE AS
(
  SELECT EmployeeID,
         COUNT(*) AS TotalOrders
    FROM Orders
GROUP BY EmployeeID
)
SELECT e.EmployeeID,
       e.LAStName,
       ao.TotalOrders,
       lo.TotalLateOrders
  FROM Employees     e
  JOIN LateOrdersCTE lo ON lo.EmployeeID = e.EmployeeID
  JOIN AllOrdersCTE  ao ON ao.EmployeeID = e.EmployeeID

------------------------------------------------------------------------------------------------------------------------------------------
-- 44
------------------------------------------------------------------------------------------------------------------------------------------

;WITH LateOrdersCTE AS
(
  SELECT EmployeeID,
         COUNT(*) AS TotalLateOrders
    FROM Orders
   WHERE RequiredDate <= ShippedDate
GROUP BY EmployeeID
),
AllOrdersCTE AS
(
  SELECT EmployeeID,
         COUNT(*) AS TotalOrders
    FROM Orders
GROUP BY EmployeeID
)
   SELECT e.EmployeeID,
          e.LastName,
	      ao.TotalOrders,
	      lo.TotalLateOrders
     FROM Employees     e
     JOIN AllOrdersCTE  ao ON ao.EmployeeID = e.EmployeeID
LEFT JOIN LateOrdersCTE lo ON lo.EmployeeID = e.EmployeeID

------------------------------------------------------------------------------------------------------------------------------------------
-- 45
------------------------------------------------------------------------------------------------------------------------------------------

;WITH LateOrdersCTE AS
(
  SELECT EmployeeID,
         COUNT(*) AS TotalLateOrders
    FROM Orders
   WHERE RequiredDate <= ShippedDate
GROUP BY EmployeeID
),
AllOrdersCTE AS
(
  SELECT EmployeeID,
         COUNT(*) AS TotalOrders
    FROM Orders
GROUP BY EmployeeID
)
   SELECT e.EmployeeID,
          e.LastName,
	        ao.TotalOrders,
	        ISNULL(lo.TotalLateOrders, 0) AS TotalLateOrders
     FROM Employees     e
     JOIN AllOrdersCTE  ao ON ao.EmployeeID = e.EmployeeID
LEFT JOIN LateOrdersCTE lo ON lo.EmployeeID = e.EmployeeID

------------------------------------------------------------------------------------------------------------------------------------------
-- 46
------------------------------------------------------------------------------------------------------------------------------------------

;WITH LateOrdersCTE AS
(
  SELECT EmployeeID,
         COUNT(*) AS TotalLateOrders
    FROM Orders
   WHERE RequiredDate <= ShippedDate
GROUP BY EmployeeID
),
AllOrdersCTE AS
(
  SELECT EmployeeID,
         COUNT(*) AS TotalOrders
    FROM Orders
GROUP BY EmployeeID
)
   SELECT e.EmployeeID,
          e.LastName,
          ao.TotalOrders,
          ISNULL(lo.TotalLateOrders, 0)                                                  AS TotalLateOrders,
          (CAST(ISNULL(lo.TotalLateOrders, 0) AS FLOAT) / CAST(ao.TotalOrders AS FLOAT)) AS PercentOrders
     FROM Employees     e
     JOIN AllOrdersCTE  ao ON ao.EmployeeID = e.EmployeeID
LEFT JOIN LateOrdersCTE lo ON lo.EmployeeID = e.EmployeeID

------------------------------------------------------------------------------------------------------------------------------------------
-- 47
------------------------------------------------------------------------------------------------------------------------------------------

;WITH LateOrdersCTE AS
(
  SELECT EmployeeID,
         COUNT(*) AS TotalLateOrders
    FROM Orders
   WHERE RequiredDate <= ShippedDate
GROUP BY EmployeeID
),
AllOrdersCTE AS
(
  SELECT EmployeeID,
         COUNT(*) AS TotalOrders
    FROM Orders
GROUP BY EmployeeID
)
   SELECT e.EmployeeID,
          e.LastName,
          ao.TotalOrders,
          ISNULL(lo.TotalLateOrders, 0)                                                            AS TotalLateOrders,
          ROUND((CAST(ISNULL(lo.TotalLateOrders, 0) AS FLOAT) / CAST(ao.TotalOrders AS FLOAT)), 2) AS PercentOrders
     FROM Employees     e
     JOIN AllOrdersCTE  ao ON ao.EmployeeID = e.EmployeeID
LEFT JOIN LateOrdersCTE lo ON lo.EmployeeID = e.EmployeeID

------------------------------------------------------------------------------------------------------------------------------------------
-- 48
------------------------------------------------------------------------------------------------------------------------------------------

;WITH Orders1997CTE AS
(
	SELECT c.CustomerID,
	       c.CompanyName,
		     SUM(od.Quantity * od.UnitPrice) AS TotalOrder
	  FROM Customers       c
	  JOIN Orders          o  ON o.CustomerID = c.CustomerID
	  JOIN [Order Details] od ON od.OrderID = o.OrderID
	 WHERE YEAR(o.OrderDate) = 1997
  GROUP BY c.CustomerID, c.CompanyName
)
  SELECT CustomerID,
         CompanyName,
         TotalOrder,
  	     CASE WHEN TotalOrder >= 0     AND TotalOrder < 1000  THEN 'Low'
  	          WHEN TotalOrder >= 1000  AND TotalOrder < 5000  THEN 'Medium'
  		        WHEN TotalOrder >= 5000  AND TotalOrder < 10000 THEN 'High'
              WHEN TotalOrder >= 10000                        THEN 'Very High'
               END AS CustomerGroup
    FROM Orders1997CTE
ORDER BY CustomerID

------------------------------------------------------------------------------------------------------------------------------------------
-- 49
------------------------------------------------------------------------------------------------------------------------------------------

;WITH Orders1997CTE AS
(
  SELECT c.CustomerID,
         c.CompanyName,
         SUM(od.Quantity * od.UnitPrice) AS TotalOrder
    FROM Customers       c
    JOIN Orders          o  ON o.CustomerID = c.CustomerID
    JOIN [Order Details] od ON od.OrderID = o.OrderID
   WHERE YEAR(o.OrderDate) = 1997
GROUP BY c.CustomerID, c.CompanyName
)
  SELECT CustomerID,
	     CompanyName,
		 ISNULL(TotalOrder, 0) AS TotalOrder,
		 CASE WHEN TotalOrder >= 0     AND TotalOrder < 1000  THEN 'Low'
		      WHEN TotalOrder >= 1000  AND TotalOrder < 5000  THEN 'Medium'
		      WHEN TotalOrder >= 5000  AND TotalOrder < 10000 THEN 'High'
		      WHEN TotalOrder >= 10000                        THEN 'Very High'
		       END             AS CustomerGroup
    FROM Orders1997CTE
ORDER BY CustomerID

------------------------------------------------------------------------------------------------------------------------------------------
-- 50
------------------------------------------------------------------------------------------------------------------------------------------

;WITH Orders1997CTE AS
(
  SELECT c.CustomerID,
         c.CompanyName,
	       SUM(od.Quantity * od.UnitPrice) AS TotalOrder
    FROM Customers       c
    JOIN Orders          o  ON o.CustomerID = c.CustomerID
    JOIN [Order Details] od ON od.OrderID = o.OrderID
   WHERE YEAR(o.OrderDate) = 1997
GROUP BY c.CustomerID, c.CompanyName
),
QuantityGroupCTE AS
(
	SELECT CustomerID,
	       CompanyName,
		     TotalOrder,
	       CASE WHEN TotalOrder >= 0     AND TotalOrder < 1000  THEN 'Low'
		        WHEN TotalOrder >= 1000  AND TotalOrder < 5000  THEN 'Medium'
				    WHEN TotalOrder >= 5000  AND TotalOrder < 10000 THEN 'High'
				    WHEN TotalOrder >= 10000                        THEN 'Very High'
		         END AS CustomerGroup
	  FROM Orders1997CTE
)
  SELECT CustomerGroup,
         COUNT(*)                                                          AS TotalInGroup,
         CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM QuantityGroupCTE) AS PercentageInGroup
    FROM QuantityGroupCTE
GROUP BY CustomerGroup
ORDER BY TotalInGroup DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 51
------------------------------------------------------------------------------------------------------------------------------------------

-- O livro resolve este problema com a tabela CustomerGroupThresholds, que so existe no banco do livro
-- Vou criar essas faixas em uma tabela temporaria equivalente, e o grupo sai de um JOIN por intervalo
DROP TABLE IF EXISTS #CustomerGroupThresholds
CREATE TABLE #CustomerGroupThresholds
(
	CustomerGroupName VARCHAR(20),
	RangeBottom       DECIMAL(16,5),
	RangeTop          DECIMAL(16,5)
)

INSERT INTO #CustomerGroupThresholds
VALUES ('Low', 0, 999.99999),
       ('Medium', 1000, 4999.99999),
       ('High', 5000, 9999.99999),
       ('Very High', 10000, 9999999999.99999)

;WITH Orders1997CTE AS
(
  SELECT c.CustomerID,
	       c.CompanyName,
		     SUM(od.Quantity * od.UnitPrice) AS TotalOrder
    FROM Customers       c
    JOIN Orders          o  ON o.CustomerID = c.CustomerID
    JOIN [Order Details] od ON od.OrderID = o.OrderID
   WHERE YEAR(o.OrderDate) = 1997
GROUP BY c.CustomerID, c.CompanyName
)
  SELECT o.CustomerID,
         o.CompanyName,
         o.TotalOrder,
         t.CustomerGroupName
    FROM Orders1997CTE            o
    JOIN #CustomerGroupThresholds t ON o.TotalOrder between t.RangeBottom and t.RangeTop
ORDER BY o.CustomerID

DROP TABLE #CustomerGroupThresholds

------------------------------------------------------------------------------------------------------------------------------------------
-- 52
------------------------------------------------------------------------------------------------------------------------------------------

SELECT DISTINCT *
  FROM (SELECT Country
          FROM Customers

         UNION

        SELECT Country
          FROM Suppliers) x

------------------------------------------------------------------------------------------------------------------------------------------
-- 53
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CustomersCountryCTE AS
(
	SELECT DISTINCT 
	       Country AS CustomersCountry
	  FROM Customers 
),
SuppliersCountryCTE AS
(
	SELECT DISTINCT 
	       Country AS SuppliersCountry
	  FROM Suppliers 
)
	       SELECT s.SuppliersCountry,
		            c.CustomersCountry
	         FROM CustomersCountryCTE c
FULL OUTER JOIN SuppliersCountryCTE s ON s.SuppliersCountry = c.CustomersCountry

------------------------------------------------------------------------------------------------------------------------------------------
-- 54
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CustomersCountryCTE AS
(
  SELECT Country  AS CustomersCountry,
         COUNT(*) AS TotalCustomers
    FROM Customers
GROUP BY Country
),
SuppliersCountryCTE AS
(
  SELECT Country  AS SuppliersCountry,
         COUNT(*) AS TotalSuppliers
    FROM Suppliers
GROUP BY Country
)
	       SELECT ISNULL(s.SuppliersCountry, c.CustomersCountry) AS Country,
		            ISNULL(c.TotalCustomers, 0)                    AS TotalCustomers,
				        ISNULL(s.TotalSuppliers, 0)                    AS TotalSuppliers
	         FROM CustomersCountryCTE c
FULL OUTER JOIN SuppliersCountryCTE s ON s.SuppliersCountry = c.CustomersCountry

------------------------------------------------------------------------------------------------------------------------------------------
-- 55
------------------------------------------------------------------------------------------------------------------------------------------

;WITH CountryOrdersCTE AS
(
	SELECT ShipCountry,
	       CustomerID,
		     OrderID,
		     CAST(OrderDate AS DATE)                                                    AS OrderDate,
		     ROW_NUMBER() OVER (PARTITION BY ShipCountry ORDER BY ShipCountry, OrderID) AS RowNumber
	  FROM Orders
)
  SELECT ShipCountry,
         CustomerID,
         OrderID,
         OrderDate
    FROM CountryOrdersCTE
   WHERE RowNumber = 1
ORDER BY ShipCountry

------------------------------------------------------------------------------------------------------------------------------------------
-- 56
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT i.CustomerID,
         i.OrderID                               AS InitialOrderID,
	       CAST(i.OrderDate AS DATE)               AS InitialOrderDate,
	       n.OrderID                               AS NextOrderID,
	       CAST(n.OrderDate AS DATE)               AS NextOrderDate,
	       DATEDIFF(day, i.OrderDate, n.OrderDate) AS DaysBetweenOrders
    FROM Orders i
    JOIN Orders n ON i.CustomerID = n.CustomerID
     AND i.OrderID < n.OrderID
   WHERE DATEDIFF(day, i.OrderDate, n.OrderDate) <= 5
ORDER BY i.CustomerID, i.OrderID

------------------------------------------------------------------------------------------------------------------------------------------
-- 56
------------------------------------------------------------------------------------------------------------------------------------------

;WITH NextOrderDateCTE AS
(
	SELECT CustomerID,
	       CAST(OrderDate AS DATE)                                                                        AS OrderDate,
		     CAST(LEAD(OrderDate, 1) OVER (PARTITION BY CustomerID ORDER BY CustomerID, OrderDate) AS DATE) AS NextOrderDate
	  FROM Orders
)
SELECT CustomerID,
       OrderDate,
	     NextOrderDate,
	     DATEDIFF(DAY, OrderDate, NextOrderDate) AS DaysBetweenOrders
  FROM NextOrderDateCTE
 WHERE DATEDIFF(DAY, OrderDate, NextOrderDate) <= 5
