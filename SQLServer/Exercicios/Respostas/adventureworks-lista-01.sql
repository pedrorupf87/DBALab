
USE AdventureWorks2022
GO

------------------------------------------------------------------------------------------------------------------------------------------
-- 01
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT BusinessEntityID,
         NationalIDNumber,
         LoginID,
         JobTitle,
         BirthDate,
         MaritalStatus,
         Gender,
         HireDate,
         SalariedFlag,
         VacationHours,
         SickLeaveHours,
         CurrentFlag,
         rowguid,
         ModifiedDate,
         OrganizationNode
    FROM HumanResources.Employee
ORDER BY JobTitle ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 02
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT p.BusinessEntityID,
         p.PersonType,
         p.NameStyle,
         p.Title,
         p.FirstName,
         p.MiddleName,
         p.LastName,
         p.Suffix,
         p.EmailPromotion,
         p.AdditionalContactInfo,
         p.Demographics,
         p.rowguid,
         p.ModifiedDate
    FROM Person.Person p
ORDER BY LastName ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 03
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT FirstName,
         LastName,
         BusinessEntityID AS EmployeeID
    FROM Person.Person
ORDER BY LastName ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 04
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT ProductID,
         ProductNumber,
         [Name] AS ProductName
    FROM Production.[Product]
   WHERE SellStartDate IS NOT NULL
     AND ProductLine = 'T'
ORDER BY [Name]

------------------------------------------------------------------------------------------------------------------------------------------
-- 05
------------------------------------------------------------------------------------------------------------------------------------------

-- O enunciado pede ordem crescente de SubTotal
  SELECT SalesOrderID,
         CustomerID,
  	     OrderDate,
  	     SubTotal,
  	     ((TaxAmt / SubTotal) * 100) AS TaxPercent
    FROM Sales.SalesOrderHeader
ORDER BY SubTotal ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 06
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT DISTINCT
         JobTitle
    FROM HumanResources.Employee
ORDER BY JobTitle ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 07
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT CustomerID,
         SUM(Freight) AS TotalFreight
    FROM Sales.SalesOrderHeader
GROUP BY CustomerID
ORDER BY CustomerID ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 08
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT CustomerID,
         SalesPersonID,
		 AVG(SubTotal) AS AvgSubTotal,
         SUM(SubTotal) AS SumSubTotal
    FROM Sales.SalesOrderHeader
GROUP BY CustomerID, SalesPersonID
ORDER BY CustomerID DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 09
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT ProductID,
         SUM(Quantity) AS SumQuantity
    FROM Production.ProductInventory
   WHERE Shelf IN ('A', 'C', 'H')
GROUP BY ProductID
  HAVING SUM(Quantity) > 500
ORDER BY ProductID ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 10
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT SUM(Quantity) AS TotalQuantity
    FROM Production.ProductInventory
GROUP BY LocationID * 10

------------------------------------------------------------------------------------------------------------------------------------------
-- 11
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT p.BusinessEntityID,
         p.FirstName,
  	     p.LastName,
  	     ph.PhoneNumber
    FROM Person.Person p
    JOIN Person.PersonPhone ph ON ph.BusinessEntityID = p.BusinessEntityID
   WHERE p.LastName LIKE 'L%'
ORDER BY p.LastName, p.FirstName

------------------------------------------------------------------------------------------------------------------------------------------
-- 12
------------------------------------------------------------------------------------------------------------------------------------------

-- Sem filtro: o enunciado não exclui os pedidos sem vendedor (SalesPersonID nulo)
  SELECT SalesPersonID,
         CustomerID,
		 SUM(SubTotal) AS SumSubTotal
    FROM Sales.SalesOrderHeader
GROUP BY ROLLUP (SalesPersonID, CustomerID)

------------------------------------------------------------------------------------------------------------------------------------------
-- 13
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT LocationID,
         Shelf,
		 SUM(Quantity) AS TotalQuantity
    FROM Production.ProductInventory
GROUP BY CUBE (LocationID, Shelf)
ORDER BY TotalQuantity DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 14
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT LocationID,
         Shelf,
		 SUM(Quantity) AS TotalQuantity
    FROM Production.ProductInventory
GROUP BY GROUPING SETS (ROLLUP (LocationID, Shelf), CUBE (LocationID, Shelf))
ORDER BY TotalQuantity DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 15
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT LocationID,
         SUM(Quantity) AS TotalQuantity
    FROM Production.ProductInventory
GROUP BY GROUPING SETS (LocationID, ())
ORDER BY LocationID

------------------------------------------------------------------------------------------------------------------------------------------
-- 16
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT a.City,
         COUNT(bea.BusinessEntityID) AS NumberOfEmployees
    FROM Person.BusinessEntityAddress bea
	JOIN Person.[Address] a ON a.AddressID = bea.AddressID
GROUP BY a.City
ORDER BY a.City

------------------------------------------------------------------------------------------------------------------------------------------
-- 17
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT YEAR(OrderDate) AS [Year],
         SUM(TotalDue)   AS SumTotalDue
    FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
ORDER BY YEAR(OrderDate)

------------------------------------------------------------------------------------------------------------------------------------------
-- 18
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT YEAR(OrderDate) AS [Year],
         SUM(TotalDue)   AS SumTotalDue
    FROM Sales.SalesOrderHeader
   WHERE YEAR(OrderDate) <= 2016
GROUP BY YEAR(OrderDate)
ORDER BY YEAR(OrderDate)

------------------------------------------------------------------------------------------------------------------------------------------
-- 19
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT ContactTypeID,
         [Name]
    FROM Person.ContactType
   WHERE [Name] LIKE '%Manager%'
ORDER BY ContactTypeID DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 20
------------------------------------------------------------------------------------------------------------------------------------------

-- O tipo de contato é localizado pelo nome, e não por um ContactTypeID fixo
  SELECT p.BusinessEntityID,
         p.LastName,
		 p.FirstName
    FROM Person.BusinessEntityContact bec
	JOIN Person.ContactType ct ON ct.ContactTypeID = bec.ContactTypeID
	JOIN Person.Person p ON p.BusinessEntityID = bec.PersonID
   WHERE ct.[Name] = 'Purchasing Manager'
ORDER BY p.LastName, p.FirstName

------------------------------------------------------------------------------------------------------------------------------------------
-- 21
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT ROW_NUMBER() OVER (PARTITION BY a.PostalCode ORDER BY sp.SalesYTD DESC) AS RowNumber,
         p.LastName,
         sp.SalesYTD,
		 a.PostalCode
    FROM Sales.SalesPerson sp
	JOIN Person.Person p ON p.BusinessEntityID = sp.BusinessEntityID
	JOIN Person.BusinessEntityAddress bea ON bea.BusinessEntityID = p.BusinessEntityID
	JOIN Person.[Address] a ON a.AddressID = bea.AddressID
   WHERE sp.TerritoryID IS NOT NULL
     AND sp.SalesYTD <> 0
ORDER BY a.PostalCode ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 22
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT ct.ContactTypeID,
         ct.[Name]                   AS ContactTypeName,
		 COUNT(bec.BusinessEntityID) AS NumberContacts
    FROM Person.ContactType ct
	JOIN Person.BusinessEntityContact bec ON bec.ContactTypeID = ct.ContactTypeID
GROUP BY ct.ContactTypeID, ct.[Name]
  HAVING COUNT(bec.BusinessEntityID) >= 100
ORDER BY NumberContacts DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 23
------------------------------------------------------------------------------------------------------------------------------------------

-- CONCAT trata NULL como texto vazio: quem não tem MiddleName continua no resultado
  SELECT CAST(eph.RateChangeDate AS DATE)                          AS FromDate,
         CONCAT(p.LastName, ', ', p.FirstName, ' ', p.MiddleName)  AS FullName,
		 (eph.Rate * 40.0)                                         AS SalaryInWeek
    FROM Person.Person p
	JOIN HumanResources.EmployeePayHistory eph ON eph.BusinessEntityID = p.BusinessEntityID
ORDER BY FullName ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 24
------------------------------------------------------------------------------------------------------------------------------------------

-- Salário semanal MAIS RECENTE de cada funcionário: apenas a linha com a última RateChangeDate
  SELECT CAST(eph.RateChangeDate AS DATE)                          AS FromDate,
         CONCAT(p.LastName, ', ', p.FirstName, ' ', p.MiddleName)  AS FullName,
		 (eph.Rate * 40.0)                                         AS SalaryInWeek
    FROM Person.Person p
	JOIN HumanResources.EmployeePayHistory eph ON eph.BusinessEntityID = p.BusinessEntityID
   WHERE eph.RateChangeDate = (SELECT MAX(eph2.RateChangeDate)
                                 FROM HumanResources.EmployeePayHistory eph2
                                WHERE eph2.BusinessEntityID = eph.BusinessEntityID)
ORDER BY FullName ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 25
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT SalesOrderID,
         ProductID,
		 OrderQty,
		 SUM(OrderQty)                OVER (PARTITION BY SalesOrderID) AS "Total Quantity",
		 AVG(CAST(OrderQty AS FLOAT)) OVER (PARTITION BY SalesOrderID) AS "Avg Quantity",
		 COUNT(OrderQty)              OVER (PARTITION BY SalesOrderID) AS "No Of Quantity",
		 MAX(OrderQty)                OVER (PARTITION BY SalesOrderID) AS "Max Quantity",
		 MIN(OrderQty)                OVER (PARTITION BY SalesOrderID) AS "Min Quantity"
    FROM Sales.SalesOrderDetail
   WHERE SalesOrderID IN (43659, 43664)
GROUP BY SalesOrderID, ProductID, OrderQty

------------------------------------------------------------------------------------------------------------------------------------------
-- 26
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT SalesOrderID,
         ProductID,
		 OrderQty,
		 SUM(OrderQty)                OVER (PARTITION BY SalesOrderID) AS "Total Quantity",
		 AVG(CAST(OrderQty AS FLOAT)) OVER (PARTITION BY SalesOrderID) AS "Avg Quantity",
		 COUNT(OrderQty)              OVER (PARTITION BY SalesOrderID) AS "No Of Quantity",
		 MAX(OrderQty)                OVER (PARTITION BY SalesOrderID) AS "Max Quantity",
		 MIN(OrderQty)                OVER (PARTITION BY SalesOrderID) AS "Min Quantity"
    FROM Sales.SalesOrderDetail
   WHERE SalesOrderID IN (43659, 43664)
     AND ProductID LIKE '71%'
GROUP BY SalesOrderID, ProductID, OrderQty

------------------------------------------------------------------------------------------------------------------------------------------
-- 27
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT SalesOrderID,
         SUM(OrderQty * UnitPrice) AS OrderIdCost
    FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
  HAVING SUM(OrderQty * UnitPrice) > 100000
ORDER BY SalesOrderID

------------------------------------------------------------------------------------------------------------------------------------------
-- 28
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT ProductID,
         [Name] AS ProductName
    FROM Production.[Product]
   WHERE [Name] LIKE 'Lock Washer%'
ORDER BY ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 29
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT ProductID,
         [Name],
		 Color
    FROM Production.[Product]
ORDER BY ListPrice

------------------------------------------------------------------------------------------------------------------------------------------
-- 30
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT BusinessEntityID,
         JobTitle,
		 CAST(HireDate AS DATE) AS HireDate
    FROM HumanResources.Employee
ORDER BY YEAR(HireDate)

------------------------------------------------------------------------------------------------------------------------------------------
-- 31
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT LastName,
         FirstName
    FROM Person.Person
   WHERE LastName LIKE 'R%'
ORDER BY FirstName ASC, LastName DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 32
------------------------------------------------------------------------------------------------------------------------------------------

-- Decrescente quando SalariedFlag = 1 e crescente quando SalariedFlag = 0
  SELECT BusinessEntityID,
         SalariedFlag
    FROM HumanResources.Employee
ORDER BY CASE WHEN SalariedFlag = 1 THEN BusinessEntityID END DESC,
         CASE WHEN SalariedFlag = 0 THEN BusinessEntityID END ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 33
------------------------------------------------------------------------------------------------------------------------------------------

-- Uma única chave de ordenação: TerritoryName para os Estados Unidos, CountryRegionName para os demais
  SELECT BusinessEntityID,
         LastName,
		 TerritoryName,
		 CountryRegionName
    FROM Sales.vSalesPerson
   WHERE TerritoryName IS NOT NULL
ORDER BY CASE WHEN CountryRegionName = 'United States' THEN TerritoryName
              ELSE CountryRegionName
          END

------------------------------------------------------------------------------------------------------------------------------------------
-- 34
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT p.FirstName,
         p.LastName,
		 ROW_NUMBER() OVER (ORDER BY a.PostalCode) AS "Row Number",
		 RANK()       OVER (ORDER BY a.PostalCode) AS "Rank",
		 DENSE_RANK() OVER (ORDER BY a.PostalCode) AS "Dense Rank",
		 NTILE(4)     OVER (ORDER BY a.PostalCode) AS "Quartile",
		 sp.SalesYTD,
		 a.PostalCode
    FROM Person.Person     p
	JOIN Sales.SalesPerson sp ON sp.BusinessEntityID = p.BusinessEntityID
	JOIN Person.[Address]  a  ON a.AddressID = p.BusinessEntityID
   WHERE TerritoryID IS NOT NULL AND SalesYTD <> 0
ORDER BY a.PostalCode

------------------------------------------------------------------------------------------------------------------------------------------
-- 35
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT DepartmentID,
         [Name],
		 GroupName
    FROM HumanResources.Department
ORDER BY DepartmentID
  OFFSET 10 ROWS

------------------------------------------------------------------------------------------------------------------------------------------
-- 36
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT DepartmentID,
         [Name],
		 GroupName
    FROM HumanResources.Department
ORDER BY DepartmentID
  OFFSET 5 ROWS FETCH NEXT 5 ROWS ONLY

------------------------------------------------------------------------------------------------------------------------------------------
-- 37
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT [Name],
         Color,
		 ListPrice
    FROM Production.[Product]
   WHERE Color IN ('Red', 'Blue')
ORDER BY ListPrice

------------------------------------------------------------------------------------------------------------------------------------------
-- 38
------------------------------------------------------------------------------------------------------------------------------------------

         SELECT p.[Name],
		        sod.SalesOrderID
           FROM Production.[Product]   p
FULL OUTER JOIN Sales.SalesOrderDetail sod ON sod.ProductID = p.ProductID
       ORDER BY p.[Name]

------------------------------------------------------------------------------------------------------------------------------------------
-- 39
------------------------------------------------------------------------------------------------------------------------------------------

         SELECT p.[Name],
		        sod.SalesOrderID
           FROM Production.[Product]   p
LEFT OUTER JOIN Sales.SalesOrderDetail sod ON sod.ProductID = p.ProductID
       ORDER BY p.[Name]

------------------------------------------------------------------------------------------------------------------------------------------
-- 40
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT p.[Name],
         sod.SalesOrderID
    FROM Production.[Product]   p
    JOIN Sales.SalesOrderDetail sod ON sod.ProductID = p.ProductID
ORDER BY p.[Name]

------------------------------------------------------------------------------------------------------------------------------------------
-- 41
------------------------------------------------------------------------------------------------------------------------------------------

-- Todos os vendedores, com ou sem território: a tabela preservada é SalesPerson
         SELECT st.[Name],
                sp.BusinessEntityID
           FROM Sales.SalesPerson    sp
LEFT OUTER JOIN Sales.SalesTerritory st ON st.TerritoryID = sp.TerritoryID
       ORDER BY sp.BusinessEntityID

------------------------------------------------------------------------------------------------------------------------------------------
-- 42
------------------------------------------------------------------------------------------------------------------------------------------

-- O JOIN com Employee restringe o resultado aos funcionários (sem ele, retorna todas as pessoas com endereço)
  SELECT p.FirstName + ' ' + p.LastName AS FullName,
         a.City
    FROM Person.Person                p
	JOIN HumanResources.Employee      e   ON e.BusinessEntityID = p.BusinessEntityID
	JOIN Person.BusinessEntityAddress bea ON bea.BusinessEntityID = p.BusinessEntityID
	JOIN Person.[Address]             a   ON a.AddressID = bea.AddressID
ORDER BY p.LastName, p.FirstName

------------------------------------------------------------------------------------------------------------------------------------------
-- 43
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT x.BusinessEntityID,
         x.FirstName,
	     x.LastName
    FROM (SELECT BusinessEntityID,
                 PersonType,
                 FirstName,
	             LastName
            FROM Person.Person) x
   WHERE x.PersonType = 'IN'
     AND x.LastName = 'Adams'
ORDER BY x.FirstName

------------------------------------------------------------------------------------------------------------------------------------------
-- 44
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT x.BusinessEntityID,
         x.FirstName,
  	   x.LastName
    FROM (SELECT *
            FROM Person.Person) x
   WHERE x.BusinessEntityID <= 1500
     AND x.FirstName LIKE 'M%'
     AND x.LastName  LIKE 'Al%'
ORDER BY x.BusinessEntityID

------------------------------------------------------------------------------------------------------------------------------------------
-- 45
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT x.ProductID,
         x.[Name],
		 x.Color
    FROM (SELECT *
            FROM Production.[Product]) x
   WHERE x.[Name] IN ('Blade', 'Crown Race', 'AWC Logo Cap')
ORDER BY x.ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 46
------------------------------------------------------------------------------------------------------------------------------------------

;WITH QuantityOfSalesCTE AS
(
    SELECT SalesPersonID, 
	       SalesOrderID, 
		   YEAR(OrderDate) AS SalesYear
      FROM Sales.SalesOrderHeader
     WHERE SalesPersonID IS NOT NULL
)
  SELECT SalesPersonID, 
         COUNT(SalesOrderID) AS TotalSales, 
		 SalesYear
    FROM QuantityOfSalesCTE
GROUP BY SalesYear, SalesPersonID
ORDER BY SalesPersonID, SalesYear

------------------------------------------------------------------------------------------------------------------------------------------
-- 47
------------------------------------------------------------------------------------------------------------------------------------------

;WITH AvgSalesByYearCTE AS
(
	  SELECT SalesPersonID,
	         COUNT(SalesOrderID) AS NoOfOrders
	    FROM Sales.SalesOrderHeader
	   WHERE SalesPersonID IS NOT NULL
	GROUP BY SalesPersonID
)
SELECT AVG(CAST(NoOfOrders AS FLOAT)) AS "Average Sales Per Person"
  FROM AvgSalesByYearCTE

------------------------------------------------------------------------------------------------------------------------------------------
-- 48
------------------------------------------------------------------------------------------------------------------------------------------

-- No LIKE, "_" é curinga de um caractere. Para procurar o sublinhado literal é preciso escapá-lo
  SELECT *
    FROM Production.ProductPhoto
   WHERE LargePhotoFileName LIKE '%green\_%' ESCAPE '\'
ORDER BY ProductPhotoID

------------------------------------------------------------------------------------------------------------------------------------------
-- 49
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT a.AddressLine1,
         a.AddressLine2,
		 a.City,
		 a.PostalCode,
		 sp.CountryRegionCode
    FROM Person.[Address]     a
	JOIN Person.StateProvince sp ON sp.StateProvinceID = a.StateProvinceID
   WHERE sp.CountryRegionCode <> 'US'
     AND a.City LIKE 'Pa%'
ORDER BY a.AddressLine1

------------------------------------------------------------------------------------------------------------------------------------------
-- 50
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT TOP 20
         JobTitle,
         CAST(HireDate AS DATE) AS HireDate
    FROM HumanResources.Employee
ORDER BY HireDate DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 51
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT soh.*, sod.*
    FROM Sales.SalesOrderHeader soh
	JOIN Sales.SalesOrderDetail sod ON sod.SalesOrderID = soh.SalesOrderID
   WHERE soh.TotalDue > 100
     AND (sod.OrderQty > 5
          OR sod.UnitPriceDiscount < 1000)
ORDER BY soh.SalesOrderID

------------------------------------------------------------------------------------------------------------------------------------------
-- 52
------------------------------------------------------------------------------------------------------------------------------------------

-- O enunciado pede a palavra 'red' apenas na coluna Name
  SELECT [Name],
         Color
    FROM Production.[Product]
   WHERE [Name] LIKE '%RED%'
ORDER BY ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 53
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT [Name],
         ListPrice
    FROM Production.[Product]
   WHERE [Name] LIKE '%Mountain%'
     AND ListPrice = 80.99
ORDER BY ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 54
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT [Name],
         Color
    FROM Production.[Product]
   WHERE [Name] LIKE '%Mountain%'
      OR [Name] LIKE '%Road%'
ORDER BY ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 55
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT [Name],
         Color
    FROM Production.[Product]
   WHERE [Name] LIKE '%Mountain%'
     AND [Name] LIKE '%Black%'
ORDER BY ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 56
------------------------------------------------------------------------------------------------------------------------------------------

-- "Pelo menos uma palavra começando com chain": no início do nome ou depois de um espaço
  SELECT [Name],
         Color
    FROM Production.[Product]
   WHERE [Name] LIKE 'Chain%'
      OR [Name] LIKE '% Chain%'
ORDER BY ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 57
------------------------------------------------------------------------------------------------------------------------------------------

-- Palavra começando com chain ou full: no início do nome ou depois de um espaço
  SELECT [Name],
         Color
    FROM Production.[Product]
   WHERE [Name] LIKE 'Chain%'
      OR [Name] LIKE '% Chain%'
      OR [Name] LIKE 'Full%'
      OR [Name] LIKE '% Full%'
ORDER BY ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 58
------------------------------------------------------------------------------------------------------------------------------------------

-- Nome e sobrenome separados por espaço; o e-mail vem na linha seguinte
  SELECT CONCAT(p.FirstName, ' ', p.LastName, CHAR(13), CHAR(10), ea.EmailAddress) AS PersonEmailAddress
    FROM Person.Person       p
	JOIN Person.EmailAddress ea ON ea.BusinessEntityID = p.BusinessEntityID
ORDER BY p.BusinessEntityID

------------------------------------------------------------------------------------------------------------------------------------------
-- 59
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT [Name],
         CHARINDEX('yellow', [Name]) AS "String Position"
    FROM Production.[Product]
   WHERE [Name] LIKE '%yellow%'
ORDER BY ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 60
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT CONCAT([Name], ' ', 'Color:', ISNULL(Color, '-'), ' ', ProductNumber) AS Result,
         Color
    FROM Production.[Product]
ORDER BY ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 61
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT CONCAT([Name], ',', ProductNumber, ',',ISNULL(Color, ''), CHAR(13), CHAR(10)) AS DataBaseInfo
    FROM Production.[Product]
ORDER BY ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 62
------------------------------------------------------------------------------------------------------------------------------------------

SELECT LEFT([Name], 5) AS "Left"
  FROM Production.[Product]

------------------------------------------------------------------------------------------------------------------------------------------
-- 63
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT LEN(FirstName) AS [Length],
         FirstName,
         LastName
    FROM Sales.vIndividualCustomer
   WHERE CountryRegionName = 'Australia'
ORDER BY [Length], FirstName

------------------------------------------------------------------------------------------------------------------------------------------
-- 64
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT LEN(swc.FirstName) AS FNameLength,
         swc.FirstName,
		 swc.LastName
    FROM Sales.vStoreWithContacts  swc
	JOIN Sales.vStoreWithAddresses swa ON swa.BusinessEntityID = swc.BusinessEntityID
   WHERE swa.CountryRegionName = 'Australia'
ORDER BY FNameLength, swc.FirstName

------------------------------------------------------------------------------------------------------------------------------------------
-- 65
------------------------------------------------------------------------------------------------------------------------------------------

SELECT LOWER(SUBSTRING([Name], 1, 25))        AS [Lower],   
       UPPER(SUBSTRING([Name], 1, 25))        AS [Upper],   
       LOWER(UPPER(SUBSTRING([Name], 1, 25))) AS LowerUpper  
  FROM Production.[Product]  
 WHERE StandardCost BETWEEN 1000.00 AND 1220.00

------------------------------------------------------------------------------------------------------------------------------------------
-- 66
------------------------------------------------------------------------------------------------------------------------------------------

SELECT  '     five space then the text' AS "Original Text",
LTRIM('     five space then the text')  AS "Trimmed Text(space removed)"

------------------------------------------------------------------------------------------------------------------------------------------
-- 67
------------------------------------------------------------------------------------------------------------------------------------------

SELECT ProductNumber,
       LTRIM(ProductNumber, 'HN') AS TrimmedProductNumber
  FROM Production.[Product]
 WHERE ProductNumber LIKE 'HN%'

------------------------------------------------------------------------------------------------------------------------------------------
-- 68
------------------------------------------------------------------------------------------------------------------------------------------

SELECT [Name],
       STUFF(ProductLine, 1, 0, '0000') AS LineCode
  FROM Production.[Product]
 WHERE ProductLine IS NOT NULL
   AND ProductLine = 'T'

------------------------------------------------------------------------------------------------------------------------------------------
-- 69
------------------------------------------------------------------------------------------------------------------------------------------

SELECT DISTINCT
       FirstName,
       REVERSE(FirstName) AS [Reverse]
  FROM Person.Person

------------------------------------------------------------------------------------------------------------------------------------------
-- 70
------------------------------------------------------------------------------------------------------------------------------------------

SELECT [Name],
       ProductNumber,
	   RIGHT([Name], 8) AS ProductName
  FROM Production.[Product]

------------------------------------------------------------------------------------------------------------------------------------------
-- 71
------------------------------------------------------------------------------------------------------------------------------------------

SELECT CONCAT('text then five spaces     ','after space') as OriginalText
SELECT CONCAT(RTRIM('text then five spaces     '),'after space') as TrimmedText

------------------------------------------------------------------------------------------------------------------------------------------
-- 72
------------------------------------------------------------------------------------------------------------------------------------------

-- Qualquer nome terminado em S, M ou L, e não apenas os terminados em ", S", ", M" ou ", L"
SELECT ProductNumber,
       [Name]
  FROM Production.[Product]
 WHERE RIGHT([Name], 1) IN ('S', 'M', 'L')

------------------------------------------------------------------------------------------------------------------------------------------
-- 73
------------------------------------------------------------------------------------------------------------------------------------------

SELECT STRING_AGG(COALESCE(CAST(Firstname AS NVARCHAR(MAX)), 'N/A'), ', ') AS NamesInLine
  FROM Person.Person

------------------------------------------------------------------------------------------------------------------------------------------
-- 74
------------------------------------------------------------------------------------------------------------------------------------------

SELECT STRING_AGG(CAST(CONCAT(FirstName, ' ', LastName, ' (', ModifiedDate, ')') AS NVARCHAR(MAX)), ', ') AS NamesAndDateInLine
  FROM Person.Person

------------------------------------------------------------------------------------------------------------------------------------------
-- 75
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT a.City,
         STRING_AGG(COALESCE(CAST(ea.EmailAddress AS NVARCHAR(MAX)), 'N/A'), ';') AS Emails
    FROM Person.[Address]             a
    JOIN Person.BusinessEntityAddress bea ON bea.AddressID = a.AddressID
    JOIN Person.EmailAddress          ea  ON ea.BusinessEntityID = bea.BusinessEntityID
GROUP BY a.City
ORDER BY a.City

------------------------------------------------------------------------------------------------------------------------------------------
-- 76
------------------------------------------------------------------------------------------------------------------------------------------

SELECT JobTitle,
       REPLACE(JobTitle, 'Production Supervisor', 'Production Assistant') AS NewJobTitle
  FROM HumanResources.Employee
 WHERE JobTitle LIKE 'Production Supervisor%'

------------------------------------------------------------------------------------------------------------------------------------------
-- 77
------------------------------------------------------------------------------------------------------------------------------------------

SELECT p.FirstName,
       p.MiddleName,
	   p.LastName,
	   e.JobTitle
  FROM Person.Person           p
  JOIN HumanResources.Employee e ON e.BusinessEntityID = p.BusinessEntityID
 WHERE e.JobTitle LIKE 'Sales%'

------------------------------------------------------------------------------------------------------------------------------------------
-- 78
------------------------------------------------------------------------------------------------------------------------------------------

SELECT CONCAT(UPPER(LastName), ', ', FirstName) AS [Name]
  FROM Person.Person

------------------------------------------------------------------------------------------------------------------------------------------
-- 79
------------------------------------------------------------------------------------------------------------------------------------------

-- "Expressão pequena demais para exibir": SickLeaveHours convertido para CHAR(1) mostra '*' quando o valor tem mais de um dígito
SELECT p.FirstName,
       p.LastName,
	   ISNULL(p.Title, 'N/A')            AS Title,
	   CAST(e.SickLeaveHours AS CHAR(1)) AS SickLeaveHours
  FROM Person.Person           p
  JOIN HumanResources.Employee e ON e.BusinessEntityID = p.BusinessEntityID

------------------------------------------------------------------------------------------------------------------------------------------
-- 80
------------------------------------------------------------------------------------------------------------------------------------------

SELECT [Name],
       ListPrice
  FROM Production.[Product]
 WHERE ListPrice LIKE '33%'

------------------------------------------------------------------------------------------------------------------------------------------
-- 81
------------------------------------------------------------------------------------------------------------------------------------------

-- ROUND explícito: o enunciado pede o valor arredondado para o inteiro mais próximo
SELECT SalesYTD,
       CommissionPct,
	   CAST(ROUND(SalesYTD / CommissionPct, 0) AS INT) AS Computed
  FROM Sales.SalesPerson
 WHERE CommissionPct IS NOT NULL
   AND CommissionPct <> 0

------------------------------------------------------------------------------------------------------------------------------------------
-- 82
------------------------------------------------------------------------------------------------------------------------------------------

-- Conversão explícita pedida no enunciado: SalesYTD para INT e depois para CHAR(20)
SELECT p.FirstName,
       p.LastName,
	   sp.SalesYTD,
	   p.BusinessEntityID
  FROM Person.Person     p
  JOIN Sales.SalesPerson sp ON sp.BusinessEntityID = p.BusinessEntityID
 WHERE CAST(CAST(sp.SalesYTD AS INT) AS CHAR(20)) LIKE '2%'

------------------------------------------------------------------------------------------------------------------------------------------
-- 83
------------------------------------------------------------------------------------------------------------------------------------------

SELECT CAST([Name] AS CHAR(16)) AS [Name],
       ListPrice
  FROM Production.[Product]
 WHERE [Name] LIKE 'Long-Sleeve%'

------------------------------------------------------------------------------------------------------------------------------------------
-- 84
------------------------------------------------------------------------------------------------------------------------------------------

SELECT ProductID,
       UnitPrice,
	   UnitPriceDiscount,
	   CAST((UnitPrice * UnitPriceDiscount) AS INT) AS DiscountPrice
  FROM Sales.SalesOrderDetail
 WHERE SalesOrderID = 46672
   AND UnitPriceDiscount > 0.02

------------------------------------------------------------------------------------------------------------------------------------------
-- 85
------------------------------------------------------------------------------------------------------------------------------------------

SELECT FORMAT(AVG(CAST(VacationHours AS FLOAT)), 'N16') AS AvgVacationHours,
       SUM(SickLeaveHours)                              AS TotalSickLeaveHours
  FROM HumanResources.Employee
 WHERE JobTitle LIKE 'Vice%'


------------------------------------------------------------------------------------------------------------------------------------------
-- 86
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT TerritoryID,
         AVG(Bonus)    AS AvgBonus,
  	     SUM(SalesYTD) AS SumSalesYTD
    FROM Sales.SalesPerson
GROUP BY TerritoryID

------------------------------------------------------------------------------------------------------------------------------------------
-- 87
------------------------------------------------------------------------------------------------------------------------------------------

-- O enunciado pede a média considerando apenas valores únicos
SELECT AVG(DISTINCT ListPrice) AS ListPrice
  FROM Production.[Product]

------------------------------------------------------------------------------------------------------------------------------------------
-- 88
------------------------------------------------------------------------------------------------------------------------------------------

SELECT BusinessEntityID,
       TerritoryID,
	   YEAR(ModifiedDate) AS SalesYear,
	   SalesYTD,
	   AVG(SalesYTD) OVER(PARTITION BY TerritoryID ORDER BY YEAR(ModifiedDate)) AS MovingAvg,
	   SUM(SalesYTD) OVER(PARTITION BY TerritoryID ORDER BY YEAR(ModifiedDate)) AS CumulativeTotal
  FROM Sales.SalesPerson

------------------------------------------------------------------------------------------------------------------------------------------
-- 89
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT BusinessEntityID,
         TerritoryID,
  	     YEAR(ModifiedDate) AS SalesYear,
  	     SalesYTD,
  	     AVG(SalesYTD) OVER(ORDER BY YEAR(ModifiedDate)) AS MovingAvg,
  	     SUM(SalesYTD) OVER(ORDER BY YEAR(ModifiedDate)) AS CumulativeTotal
    FROM Sales.SalesPerson
ORDER BY SalesYear

------------------------------------------------------------------------------------------------------------------------------------------
-- 90
------------------------------------------------------------------------------------------------------------------------------------------

SELECT COUNT(DISTINCT JobTitle) AS NumberJobTitles
  FROM HumanResources.Employee

------------------------------------------------------------------------------------------------------------------------------------------
-- 91
------------------------------------------------------------------------------------------------------------------------------------------

SELECT COUNT(DISTINCT BusinessEntityID) AS NumberEmployees
  FROM HumanResources.Employee

------------------------------------------------------------------------------------------------------------------------------------------
-- 92
------------------------------------------------------------------------------------------------------------------------------------------

SELECT COUNT(DISTINCT BusinessEntityID) AS [Count],
       AVG(Bonus)                       AS AvgBouns
  FROM Sales.SalesPerson
 WHERE SalesQuota > 25000

------------------------------------------------------------------------------------------------------------------------------------------
-- 93
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT DISTINCT
         d.[Name],
         MIN(eph.Rate) OVER(PARTITION BY edh.DepartmentID)               AS MinSalary,
		 MAX(eph.Rate) OVER(PARTITION BY edh.DepartmentID)               AS MaxSalary,
		 AVG(eph.Rate) OVER(PARTITION BY edh.DepartmentID)               AS AvgSalary,
		 COUNT(edh.BusinessEntityID) OVER(PARTITION BY edh.DepartmentID) AS EmployeesPerDept
    FROM HumanResources.Department                d
	JOIN HumanResources.EmployeeDepartmentHistory edh ON edh.DepartmentID = d.DepartmentID
	JOIN HumanResources.EmployeePayHistory        eph ON eph.BusinessEntityID = edh.BusinessEntityID
   WHERE edh.EndDate IS NULL
ORDER BY d.[Name]

------------------------------------------------------------------------------------------------------------------------------------------
-- 94
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT JobTitle,
         COUNT(BusinessEntityID) AS NumOfEmployees
    FROM HumanResources.Employee
GROUP BY JobTitle
  HAVING COUNT(BusinessEntityID) > 15

------------------------------------------------------------------------------------------------------------------------------------------
-- 95
------------------------------------------------------------------------------------------------------------------------------------------

-- Produtos DIFERENTES em cada pedido
  SELECT COUNT(DISTINCT ProductID) AS ProductCount,
         SalesOrderID
    FROM Sales.SalesOrderDetail
   WHERE SalesOrderID IN (43855, 43661)
GROUP BY SalesOrderID

------------------------------------------------------------------------------------------------------------------------------------------
-- 96
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT QuotaDate AS [Year],
         DATEPART(QUARTER, QuotaDate) AS [Quarter],
		 SalesQuota,
		 VAR(SalesQuota) OVER(ORDER BY YEAR(QuotaDate), DATEPART(QUARTER, QuotaDate)) AS Variance
    FROM Sales.SalesPersonQuotaHistory
   WHERE YEAR(QuotaDate) = 2012
     AND BusinessEntityID = 277
ORDER BY DATEPART(QUARTER, QuotaDate)

------------------------------------------------------------------------------------------------------------------------------------------
-- 97
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT VARP(DISTINCT SalesQuota) AS DistinctValues,
         VARP(SalesQuota)          AS AllValues
    FROM Sales.SalesPersonQuotaHistory
  
------------------------------------------------------------------------------------------------------------------------------------------
-- 98
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT Color,
         SUM(ListPrice)    AS SumListPrice,
		 SUM(StandardCost) AS SumStandardCost
    FROM Production.[Product]
   WHERE [Name] LIKE 'Mountain%'
     AND ListPrice > 0
     AND Color IS NOT NULL
GROUP BY Color
ORDER BY Color

------------------------------------------------------------------------------------------------------------------------------------------
-- 99
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT SalesQuota,
         SUM(SalesYTD) AS TotalSalesYTD,
		 GROUPING(SalesQuota) AS [Grouping]
    FROM Sales.SalesPerson
GROUP BY ROLLUP(SalesQuota)
ORDER BY [Grouping] DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 100
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT Color,
         SUM(ListPrice)    AS TotalList,
		 SUM(StandardCost) AS TotalCost
    FROM Production.[Product]
GROUP BY Color
