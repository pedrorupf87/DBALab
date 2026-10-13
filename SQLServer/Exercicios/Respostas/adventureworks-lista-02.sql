
USE AdventureWorks2022
GO

------------------------------------------------------------------------------------------------------------------------------------------
-- 101
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT edh.Department,
         edh.LastName,
		 eph.Rate,
		 CUME_DIST() OVER(PARTITION BY edh.Department ORDER BY eph.Rate)    AS CumeDist,
		 PERCENT_RANK() OVER(PARTITION BY edh.Department ORDER BY eph.Rate) AS PctRank
    FROM HumanResources.vEmployeeDepartmentHistory edh
	JOIN HumanResources.EmployeePayHistory         eph ON eph.BusinessEntityID = edh.BusinessEntityID
ORDER BY edh.Department, eph.Rate DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 102
------------------------------------------------------------------------------------------------------------------------------------------

-- Todos os produtos da subcategoria, cada um com o nome do mais barato (FIRST_VALUE)
SELECT [Name],
       ListPrice,
       FIRST_VALUE([Name]) OVER (ORDER BY ListPrice ASC) AS LeastExpensive
  FROM Production.[Product]
 WHERE ProductSubcategoryID = 37

------------------------------------------------------------------------------------------------------------------------------------------
-- 103
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT e.JobTitle,
         p.LastName,
		 e.VacationHours,
		 FIRST_VALUE(p.LastName) OVER (PARTITION BY e.JobTitle ORDER BY e.VacationHours ROWS UNBOUNDED PRECEDING) AS FewestVacationHours
    FROM HumanResources.Employee e
	JOIN Person.Person           p ON p.BusinessEntityID = e.BusinessEntityID
ORDER BY e.JobTitle

------------------------------------------------------------------------------------------------------------------------------------------
-- 104
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT BusinessEntityID,
         YEAR(QuotaDate)                                       AS SalesYear,
		 SalesQuota                                            AS CurrentQuota,
		 LAG(SalesQuota, 1, 0) OVER (ORDER BY YEAR(QuotaDate)) AS PreviousQuota
    FROM Sales.SalesPersonQuotaHistory
   WHERE BusinessEntityID = 275
     AND YEAR(QuotaDate) IN (2012, 2013)

------------------------------------------------------------------------------------------------------------------------------------------
-- 105
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT TerritoryName,
         BusinessEntityID,
		 SalesYTD,
		 LAG(SalesYTD, 1, 0) OVER (PARTITION BY TerritoryName ORDER BY BusinessEntityID DESC) AS PrevRepSales
    FROM Sales.vSalesPerson
   WHERE TerritoryName IN ('Canada', 'Northwest')

------------------------------------------------------------------------------------------------------------------------------------------
-- 106
------------------------------------------------------------------------------------------------------------------------------------------

-- Partição por departamento e ordenação pela taxa
  SELECT edh.Department,
         edh.LastName,
		 eph.Rate,
		 e.HireDate,
		 LAST_VALUE(e.HireDate) OVER (PARTITION BY edh.Department ORDER BY eph.Rate) AS LastHireDate
    FROM HumanResources.vEmployeeDepartmentHistory edh
	JOIN HumanResources.Employee                   e   ON e.BusinessEntityID = edh.BusinessEntityID
	JOIN HumanResources.EmployeePayHistory         eph ON eph.BusinessEntityID = edh.BusinessEntityID
   WHERE edh.Department IN ('Information Services', 'Document Control')
ORDER BY edh.Department, eph.Rate, e.HireDate

------------------------------------------------------------------------------------------------------------------------------------------
-- 107
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT BusinessEntityID,
         DATEPART(QUARTER, QuotaDate)                          AS [Quarter],
		 YEAR(QuotaDate)                                       AS SalesYear,
		 SalesQuota                                            AS QuotaThisQuarter,
		 SalesQuota - FIRST_VALUE(SalesQuota) OVER (PARTITION BY BusinessEntityID, YEAR(QuotaDate) ORDER BY DATEPART(QUARTER, QuotaDate)) 
									                           AS DifferenceFromFirstQuarter,
		 SalesQuota - LAST_VALUE(SalesQuota) OVER (PARTITION BY BusinessEntityID, YEAR(QuotaDate) ORDER BY DATEPART(QUARTER, QuotaDate)
			RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS DifferenceFromLastQuarter
    FROM Sales.SalesPersonQuotaHistory
   WHERE YEAR(QuotaDate) > 2005
     AND BusinessEntityID IN (274, 275)
ORDER BY BusinessEntityID, YEAR(QuotaDate), DATEPART(QUARTER, QuotaDate)

------------------------------------------------------------------------------------------------------------------------------------------
-- 108
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT QuotaDate                                                                      AS [Year],
         DATEPART(QUARTER, QuotaDate)                                                   AS [Quarter],
		 SalesQuota,
		 VARP(SalesQuota) OVER (ORDER BY YEAR(QuotaDate), DATEPART(QUARTER, QuotaDate)) AS Variance
    FROM Sales.SalesPersonQuotaHistory
   WHERE BusinessEntityID = 277
     AND YEAR(QuotaDate) = 2012
GROUP BY QuotaDate, DATEPART(QUARTER, QuotaDate), SalesQuota

------------------------------------------------------------------------------------------------------------------------------------------
-- 109
------------------------------------------------------------------------------------------------------------------------------------------

SELECT BusinessEntityID,
       YEAR(QuotaDate)                                        AS [Year],
       SalesQuota                                             AS CurrentQuota,
       LEAD(SalesQuota, 1, 0) OVER (ORDER BY YEAR(QuotaDate)) AS NextQuota
  FROM Sales.SalesPersonQuotaHistory
 WHERE BusinessEntityID = 277
   AND YEAR(QuotaDate) IN (2011, 2012)

------------------------------------------------------------------------------------------------------------------------------------------
-- 110
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT TerritoryName,
         BusinessEntityID,
		 SalesYTD,
		 LEAD(SalesYTD, 1, 0) OVER (PARTITION BY TerritoryName ORDER BY BusinessEntityID DESC) AS PrevRepSales
    FROM Sales.vSalesPerson
   WHERE TerritoryName IN ('Canada', 'Northwest')

------------------------------------------------------------------------------------------------------------------------------------------
-- 111
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT YEAR(QuotaDate)                                                  AS [Year],
         DATEPART(QUARTER, QuotaDate)                                     AS [Quarter],
		 SalesQuota,
		 LEAD(SalesQuota, 1, 0) OVER (ORDER BY YEAR(QuotaDate))           AS NextQuota,
		 SalesQuota - LEAD(SalesQuota, 1) OVER (ORDER BY YEAR(QuotaDate)) AS Diff
    FROM Sales.SalesPersonQuotaHistory
   WHERE BusinessEntityID = 277
     AND YEAR(QuotaDate) IN (2012, 2013)

------------------------------------------------------------------------------------------------------------------------------------------
-- 112
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT edh.Department,
         edh.LastName,
		 eph.Rate,
		 CUME_DIST() OVER(PARTITION BY edh.Department ORDER BY eph.Rate)    AS CumeDist,
		 PERCENT_RANK() OVER(PARTITION BY edh.Department ORDER BY eph.Rate) AS PctRank
    FROM HumanResources.vEmployeeDepartmentHistory edh
	JOIN HumanResources.EmployeePayHistory         eph ON eph.BusinessEntityID = edh.BusinessEntityID
   WHERE edh.Department IN ('Information Services', 'Document Control')
ORDER BY edh.Department, eph.Rate DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 113
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT SalesOrderID,
         OrderDate,
		 DATEADD(DAY, 2, OrderDate) AS PromisedShipDate
    FROM Sales.SalesOrderHeader
ORDER BY SalesOrderID

------------------------------------------------------------------------------------------------------------------------------------------
-- 114
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT p.FirstName,
         p.LastName,
		 DATEADD(DAY, 2, GETDATE()) AS NewDate
    FROM Person.Person     p
	JOIN Sales.SalesPerson sp ON sp.BusinessEntityID = p.BusinessEntityID
   WHERE sp.SalesQuota > 0
     AND sp.TerritoryID IS NOT NULL

------------------------------------------------------------------------------------------------------------------------------------------
-- 115
------------------------------------------------------------------------------------------------------------------------------------------

-- O tipo DATE não aceita o operador de subtração: a diferença em dias vem de DATEDIFF
SELECT MAX(CAST(OrderDate AS DATE))                AS LastDate,
       MIN(CAST(OrderDate AS DATE))                AS FirstDate,
       DATEDIFF(DAY, MIN(OrderDate), MAX(OrderDate)) AS Diff
  FROM Sales.SalesOrderHeader

------------------------------------------------------------------------------------------------------------------------------------------
-- 116
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT pin.ProductID,
         p.[Name],
		 pin.LocationID,
		 pin.Quantity,
		 DENSE_RANK() OVER (PARTITION BY pin.LocationID ORDER BY pin.Quantity DESC) AS [Rank]
    FROM Production.ProductInventory pin
	JOIN Production.[Product]        p   ON p.ProductID = pin.ProductID
   WHERE pin.LocationID IN (3, 4)

------------------------------------------------------------------------------------------------------------------------------------------
-- 117
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT TOP 10
         BusinessEntityID,
         Rate,
		 DENSE_RANK() OVER (ORDER BY Rate DESC) AS RankBySalary
    FROM HumanResources.EmployeePayHistory
ORDER BY Rate DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 118
------------------------------------------------------------------------------------------------------------------------------------------

SELECT p.FirstName,
       p.LastName,
       NTILE(4) OVER (ORDER BY SalesYTD DESC) AS Quartile,
       sp.SalesYTD,
       a.PostalCode
  FROM Person.Person     p
  JOIN Sales.SalesPerson sp ON sp.BusinessEntityID = p.BusinessEntityID
  JOIN Person.[Address]  a  ON a.AddressID = p.BusinessEntityID
 WHERE sp.SalesYTD > 0 
   AND sp.TerritoryID IS NOT NULL

------------------------------------------------------------------------------------------------------------------------------------------
-- 119
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT pin.ProductID,
         p.[Name],
		 pin.LocationID,
		 pin.Quantity,
		 RANK() OVER (PARTITION BY pin.LocationID ORDER BY pin.Quantity DESC) AS [Rank]
    FROM Production.ProductInventory pin
	JOIN Production.[Product]        p   ON p.ProductID = pin.ProductID
   WHERE pin.LocationID IN (3, 4)

------------------------------------------------------------------------------------------------------------------------------------------
-- 120
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT BusinessEntityID,
         Rate,
		 RANK() OVER (ORDER BY Rate DESC) AS RankBySalary
    FROM HumanResources.EmployeePayHistory
   WHERE BusinessEntityID BETWEEN 1 AND 10
ORDER BY BusinessEntityID, Rate DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 121
------------------------------------------------------------------------------------------------------------------------------------------

SELECT ROW_NUMBER() OVER (ORDER BY SalesYTD DESC) AS [Row],
       FirstName,
       LastName,
       SalesYTD
  FROM Sales.vSalesPerson
 WHERE SalesYTD > 0
   AND TerritoryName IS NOT NULL

------------------------------------------------------------------------------------------------------------------------------------------
-- 122
------------------------------------------------------------------------------------------------------------------------------------------

;WITH OrderedSalesCTE AS
(
	SELECT SalesOrderID,
	       OrderDate,
		   ROW_NUMBER() OVER (ORDER BY SalesOrderID) AS RowNumber
	  FROM Sales.SalesOrderHeader
)
SELECT SalesOrderID,
       OrderDate,
	   RowNumber
  FROM OrderedSalesCTE
 WHERE RowNumber BETWEEN 50 AND 60

------------------------------------------------------------------------------------------------------------------------------------------
-- 123
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT FirstName,
         LastName,
  	     TerritoryName,
  	     ROUND(SalesYTD, 2)                                                    AS SalesYTD,
  	     ROW_NUMBER() OVER (PARTITION BY TerritoryName ORDER BY SalesYTD DESC) AS [Row]
    FROM Sales.vSalesPerson
   WHERE SalesYTD > 0
     AND TerritoryName IS NOT NULL
ORDER BY TerritoryName

------------------------------------------------------------------------------------------------------------------------------------------
-- 124
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT BusinessEntityID,
         LastName,
		 TerritoryName,
		 CountryRegionName
    FROM Sales.vSalesPerson
   WHERE SalesYTD > 0
     AND TerritoryName IS NOT NULL
ORDER BY CASE WHEN CountryRegionName = 'United States' THEN TerritoryName
              ELSE CountryRegionName
          END

------------------------------------------------------------------------------------------------------------------------------------------
-- 125
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT e.JobTitle,
		 MAX(eph.Rate) AS MaximumRate
    FROM HumanResources.Employee           e
	JOIN HumanResources.EmployeePayHistory eph ON eph.BusinessEntityID = e.BusinessEntityID
GROUP BY e.JobTitle
  HAVING (MAX(CASE WHEN Gender = 'M' THEN eph.Rate ELSE NULL END) > 40.00
          OR
		  MAX(CASE WHEN Gender = 'F' THEN eph.Rate ELSE NULL END) > 42.00)
ORDER BY MaximumRate DESC

------------------------------------------------------------------------------------------------------------------------------------------
-- 126
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT BusinessEntityID,
         SalariedFlag
    FROM HumanResources.Employee
ORDER BY CASE WHEN SalariedFlag = 'True'  THEN BusinessEntityID END DESC,
         CASE WHEN SalariedFlag = 'False' THEN BusinessEntityID END

------------------------------------------------------------------------------------------------------------------------------------------
-- 127
------------------------------------------------------------------------------------------------------------------------------------------

-- O CASE é avaliado em ordem, então cada faixa só precisa do limite superior.
-- (Com "> 50" e "> 250", os preços exatamente iguais a 50 e a 250 caíam em 'Over $1000')
  SELECT ProductNumber,
         [Name],
		 ListPrice,
		 CASE WHEN ListPrice = 0    THEN 'Mfg item - not for resale'
		      WHEN ListPrice < 50   THEN 'Under $50'
			  WHEN ListPrice < 250  THEN 'Under $250'
			  WHEN ListPrice < 1000 THEN 'Under $1000'
			  ELSE 'Over $1000'
			   END AS PriceRange
    FROM Production.[Product]
ORDER BY ProductNumber ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 128
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT ProductNumber,
         CASE WHEN ProductLine = 'M' THEN 'Mountain'
		      WHEN ProductLine = 'R' THEN 'Road'
			  WHEN ProductLine = 'T' THEN 'Touring'
			  WHEN ProductLine = 'S' THEN 'Other sale items'
			  ELSE 'Not for sale'
		  END AS Category,
         [Name]
    FROM Production.[Product]
ORDER BY ProductNumber

------------------------------------------------------------------------------------------------------------------------------------------
-- 129
------------------------------------------------------------------------------------------------------------------------------------------

-- NULLIF devolve NULL quando os dois valores são iguais e, caso contrário, o primeiro valor
  SELECT ProductID,
         MakeFlag,
		 FinishedGoodsFlag,
		 NULLIF(MakeFlag, FinishedGoodsFlag) AS NullIfEqual
    FROM Production.[Product]
   WHERE ProductID < 10
ORDER BY ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 130
------------------------------------------------------------------------------------------------------------------------------------------

SELECT [Name],
       Class,
	   Color,
	   ProductNumber,
	   COALESCE(Class, Color, ProductNumber) AS FirstNotNull
  FROM Production.[Product]

------------------------------------------------------------------------------------------------------------------------------------------
-- 131
------------------------------------------------------------------------------------------------------------------------------------------

-- Mesma lógica do exercício 129, escrita com CASE: o ELSE devolve o primeiro valor (MakeFlag)
  SELECT ProductID,
         MakeFlag,
		 FinishedGoodsFlag,
		 CASE WHEN MakeFlag = FinishedGoodsFlag THEN NULL ELSE MakeFlag END AS NullIfEqual
    FROM Production.[Product]
   WHERE ProductID < 10
ORDER BY ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 132
------------------------------------------------------------------------------------------------------------------------------------------

   SELECT ProductID
     FROM Production.[Product]

INTERSECT

   SELECT ProductID
     FROM Production.WorkOrder

------------------------------------------------------------------------------------------------------------------------------------------
-- 133
------------------------------------------------------------------------------------------------------------------------------------------

SELECT ProductID
  FROM Production.[Product]

EXCEPT

SELECT ProductID
  FROM Production.WorkOrder

------------------------------------------------------------------------------------------------------------------------------------------
-- 134
------------------------------------------------------------------------------------------------------------------------------------------

SELECT ProductID   
  FROM Production.WorkOrder

EXCEPT

SELECT ProductID
  FROM Production.[Product]

------------------------------------------------------------------------------------------------------------------------------------------
-- 135
------------------------------------------------------------------------------------------------------------------------------------------

   SELECT BusinessEntityID
     FROM Person.BusinessEntity

INTERSECT

   SELECT BusinessEntityID
     FROM Person.Person
    WHERE Person.PersonType = 'IN'
 ORDER BY BusinessEntityID

------------------------------------------------------------------------------------------------------------------------------------------
-- 136
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT BusinessEntityID
    FROM Person.BusinessEntity

  EXCEPT

  SELECT BusinessEntityID
    FROM Person.Person
   WHERE Person.PersonType = 'IN'
ORDER BY BusinessEntityID

------------------------------------------------------------------------------------------------------------------------------------------
-- 137
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT ProductID, 
         [Name] 
    FROM Production.[Product] 
   WHERE ProductID NOT IN (3, 4)  
   
   UNION

  SELECT ProductModelID, 
         [Name]
    FROM Production.ProductModel   
ORDER BY [Name]

------------------------------------------------------------------------------------------------------------------------------------------
-- 138
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT p.FirstName,
         p.LastName,
		 e.VacationHours,
		 e.SickLeaveHours,
		 e.VacationHours + e.SickLeaveHours AS TotalHoursAway
    FROM Person.Person           p
	JOIN HumanResources.Employee e ON e.BusinessEntityID = p.BusinessEntityID
ORDER BY TotalHoursAway

------------------------------------------------------------------------------------------------------------------------------------------
-- 139
------------------------------------------------------------------------------------------------------------------------------------------

SELECT MAX(TaxRate) - MIN(TaxRate) AS TaxRateDifference
  FROM Sales.SalesTaxRate
 WHERE StateProvinceID IS NOT NULL

------------------------------------------------------------------------------------------------------------------------------------------
-- 140
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT sp.BusinessEntityID,
         p.FirstName,
         p.LastName,
		 ISNULL(sp.SalesQuota, 0)      AS SalesQuota,
		 ISNULL(sp.SalesQuota / 12, 0) AS SalesTargetPerMonth
    FROM Person.Person     p
	JOIN Sales.SalesPerson sp ON sp.BusinessEntityID = p.BusinessEntityID

------------------------------------------------------------------------------------------------------------------------------------------
-- 141
------------------------------------------------------------------------------------------------------------------------------------------

SELECT ProductID, 
       UnitPrice,
	   OrderQty,
	   CAST(UnitPrice AS INT) % OrderQty AS Module
  FROM Sales.SalesOrderDetail

------------------------------------------------------------------------------------------------------------------------------------------
-- 142
------------------------------------------------------------------------------------------------------------------------------------------

SELECT BusinessEntityID,
       LoginID,
	   JobTitle, 
	   VacationHours
  FROM HumanResources.Employee
 WHERE JobTitle = 'Marketing Assistant'
   AND VacationHours > 41

------------------------------------------------------------------------------------------------------------------------------------------
-- 143
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT e.FirstName,
         e.LastName,
		 eph.Rate
    FROM HumanResources.vEmployee          e
	JOIN HumanResources.EmployeePayHistory eph ON eph.BusinessEntityID = e.BusinessEntityID
   WHERE eph.Rate NOT BETWEEN 27 AND 30
ORDER BY eph.Rate

------------------------------------------------------------------------------------------------------------------------------------------
-- 144
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT BusinessEntityID,
         RateChangeDate
    FROM HumanResources.EmployeePayHistory
   WHERE RateChangeDate BETWEEN '20111212' AND '20120105'
ORDER BY BusinessEntityID ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 145
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT DepartmentID, 
         [Name]
    FROM HumanResources.Department
   WHERE EXISTS (SELECT NULL)
ORDER BY [Name] ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 146
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT p.FirstName,
         p.LastName
    FROM Person.Person           p
	JOIN HumanResources.Employee e ON e.BusinessEntityID = p.BusinessEntityID
   WHERE p.LastName = 'Johnson'
ORDER BY p.FirstName

------------------------------------------------------------------------------------------------------------------------------------------
-- 147
------------------------------------------------------------------------------------------------------------------------------------------

SELECT DISTINCT 
       s.[Name]
  FROM Sales.Store s
WHERE EXISTS (SELECT *  
                FROM Purchasing.Vendor v  
               WHERE s.[Name] = v.[Name])

------------------------------------------------------------------------------------------------------------------------------------------
-- 148
------------------------------------------------------------------------------------------------------------------------------------------

SELECT p.FirstName,
       p.LastName,
	   e.JobTitle
  FROM Person.Person           p
  JOIN HumanResources.Employee e ON e.BusinessEntityID = p.BusinessEntityID
 WHERE EXISTS (SELECT *  
                 FROM HumanResources.Department                d
                 JOIN HumanResources.EmployeeDepartmentHistory edh ON d.DepartmentID = edh.DepartmentID  
                WHERE e.BusinessEntityID = edh.BusinessEntityID
                  AND d.[Name] LIKE 'P%')

------------------------------------------------------------------------------------------------------------------------------------------
-- 149
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT p.FirstName,
         p.LastName,
  	     e.JobTitle
    FROM Person.Person           p
    JOIN HumanResources.Employee e ON e.BusinessEntityID = p.BusinessEntityID
   WHERE NOT EXISTS (SELECT *  
                      FROM HumanResources.Department                d
                      JOIN HumanResources.EmployeeDepartmentHistory edh ON d.DepartmentID = edh.DepartmentID  
                     WHERE e.BusinessEntityID = edh.BusinessEntityID
                       AND d.[Name] LIKE 'P%')
ORDER BY p.LastName, p.FirstName

------------------------------------------------------------------------------------------------------------------------------------------
-- 150
------------------------------------------------------------------------------------------------------------------------------------------

SELECT p.FirstName,
       p.LastName,
	   e.JobTitle
  FROM Person.Person           p
  JOIN HumanResources.Employee e ON p.BusinessEntityID = e.BusinessEntityID
 WHERE e.JobTitle IN ('Design Engineer', 'Tool Designer', 'Marketing Assistant')

------------------------------------------------------------------------------------------------------------------------------------------
-- 151
------------------------------------------------------------------------------------------------------------------------------------------

SELECT p.FirstName,
       p.LastName
  FROM Person.Person     p
  JOIN Sales.SalesPerson sp ON sp.BusinessEntityID = p.BusinessEntityID
 WHERE sp.SalesQuota > 250000

------------------------------------------------------------------------------------------------------------------------------------------
-- 152
------------------------------------------------------------------------------------------------------------------------------------------

SELECT p.FirstName,
       p.LastName
  FROM Person.Person     p
  JOIN Sales.SalesPerson sp ON sp.BusinessEntityID = p.BusinessEntityID
 WHERE sp.SalesQuota <= 250000

------------------------------------------------------------------------------------------------------------------------------------------
-- 153
------------------------------------------------------------------------------------------------------------------------------------------

SELECT *
  FROM Sales.SalesOrderHeaderSalesReason
 WHERE SalesReasonID IN (SELECT SalesReasonID FROM Sales.SalesReason)

------------------------------------------------------------------------------------------------------------------------------------------
-- 154
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT p.FirstName,
         p.LastName,
  	     PP.PhoneNumber
    FROM Person.Person      p
    JOIN Person.PersonPhone pp ON pp.BusinessEntityID = p.BusinessEntityID
   WHERE pp.PhoneNumber LIKE '415%'
ORDER BY p.LastName ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 155
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT p.FirstName,
         p.LastName,
  	     PP.PhoneNumber
    FROM Person.Person      p
    JOIN Person.PersonPhone pp ON pp.BusinessEntityID = p.BusinessEntityID
   WHERE p.FirstName = 'Gail'
     AND pp.PhoneNumber NOT LIKE '415%'
ORDER BY p.LastName ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 156
------------------------------------------------------------------------------------------------------------------------------------------

SELECT ProductID,
       [Name],
	   Color,
	   StandardCost
  FROM Production.[Product]
 WHERE ProductNumber LIKE 'BK-%'
   AND [Name] LIKE '%Silver%'
   AND StandardCost <= 400

------------------------------------------------------------------------------------------------------------------------------------------
-- 157
------------------------------------------------------------------------------------------------------------------------------------------

SELECT p.FirstName,
       p.LastName,
	   s.[Name]
  FROM HumanResources.EmployeeDepartmentHistory edh
  JOIN HumanResources.[Shift]                   s   ON s.ShiftID = edh.ShiftID
  JOIN HumanResources.Department                d   ON d.DepartmentID = edh.DepartmentID
  JOIN Person.Person                            p   ON p.BusinessEntityID = edh.BusinessEntityID
 WHERE s.[Name] IN ('Night', 'Evening')
   AND d.[Name] LIKE 'Quality Assurance%'

------------------------------------------------------------------------------------------------------------------------------------------
-- 158
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT FirstName,
         LastName
    FROM Person.Person
   WHERE FirstName LIKE '_an'
ORDER BY FirstName ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 159
------------------------------------------------------------------------------------------------------------------------------------------

SELECT SalesOrderID,
       OrderDate,
	   SWITCHOFFSET(orderdate AT TIME ZONE 'UTC', '+11:30') AS orderdate_timezoneade
  FROM Sales.SalesOrderHeader

------------------------------------------------------------------------------------------------------------------------------------------
-- 160
------------------------------------------------------------------------------------------------------------------------------------------

SELECT SalesOrderID,
       OrderDate,
	   SWITCHOFFSET(orderdate AT TIME ZONE 'UTC', '+11:30') AS orderdate_timezoneade,
	   SWITCHOFFSET(orderdate AT TIME ZONE 'UTC', '+00:00') AS orderdate_timezoneamchi
  FROM Sales.SalesOrderHeader

------------------------------------------------------------------------------------------------------------------------------------------
-- 161
------------------------------------------------------------------------------------------------------------------------------------------

-- No LIKE, "_" é curinga de um caractere. Para procurar o sublinhado literal é preciso escapá-lo
SELECT *
  FROM Production.ProductPhoto
 WHERE LargePhotoFileName LIKE '%green\_%' ESCAPE '\'

------------------------------------------------------------------------------------------------------------------------------------------
-- 162
------------------------------------------------------------------------------------------------------------------------------------------

SELECT a.AddressLine1,
       a.AddressLine2,
	   a.City,
	   a.PostalCode,
	   sp.CountryRegionCode
  FROM Person.[Address]     a
  JOIN Person.StateProvince sp ON sp.StateProvinceID = a.StateProvinceID
 WHERE a.City LIKE 'Pa%'
   AND sp.CountryRegionCode <> 'US'

------------------------------------------------------------------------------------------------------------------------------------------
-- 163
------------------------------------------------------------------------------------------------------------------------------------------

SELECT p.ProductID,
       p.[Name],
	   p.Color
  FROM Production.[Product]                                 p
  JOIN (VALUES ('Blade'), ('Crown Race'), ('AWC Logo Cap')) b([Name]) ON b.[Name] = p.[Name]

------------------------------------------------------------------------------------------------------------------------------------------
-- 164
------------------------------------------------------------------------------------------------------------------------------------------

;WITH SalesCTE (SalesPersonID, TotalSales, SalesYear) AS
(
      SELECT SalesPersonID,
	         SUM(TotalDue)             AS TotalSales,
			 DATEPART(YEAR, OrderDate) AS SalesYear
        FROM Sales.SalesOrderHeader
       WHERE SalesPersonID IS NOT NULL
    GROUP BY SalesPersonID, DATEPART(YEAR, OrderDate)
),
SalesQuotaCTE (BusinessEntityID, SalesQuota, SalesQuotaYear) AS
(
      SELECT BusinessEntityID,
	         SUM(SalesQuota)           AS SalesQuota,
			 DATEPART(YEAR, QuotaDate) AS SalesQuotaYear
        FROM Sales.SalesPersonQuotaHistory
    GROUP BY BusinessEntityID, DATEPART(YEAR, QuotaDate)
)
  SELECT SalesPersonID,
         SalesYear,
         CAST(TotalSales AS VARCHAR(20)) AS TotalSales,
         SalesQuotaYear,
         CAST(SalesQuota AS VARCHAR(20)) AS SalesQuota,
         CAST(TotalSales - SalesQuota AS VARCHAR(20)) AS Amt_Above_or_Below_Quota
    FROM SalesCTE
    JOIN SalesQuotaCTE ON SalesQuotaCTE.BusinessEntityID = SalesCTE.SalesPersonID AND SalesCTE.SalesYear = SalesQuotaCTE.SalesQuotaYear
ORDER BY SalesPersonID, SalesYear

------------------------------------------------------------------------------------------------------------------------------------------
-- 165
------------------------------------------------------------------------------------------------------------------------------------------

    SELECT e.BusinessEntityID,
	       d.[Name]            AS Department
      FROM HumanResources.Employee   e
CROSS JOIN HumanResources.Department d
  ORDER BY e.BusinessEntityID, d.[Name]

------------------------------------------------------------------------------------------------------------------------------------------
-- 166
------------------------------------------------------------------------------------------------------------------------------------------

SELECT sod.SalesOrderID,
       p.ProductID,
	   p.[Name]
  FROM Sales.SalesOrderDetail sod
  JOIN Production.[Product]   p   ON p.ProductID = sod.ProductID

------------------------------------------------------------------------------------------------------------------------------------------
-- 167
------------------------------------------------------------------------------------------------------------------------------------------

SELECT sod.SalesOrderID,
       p.ProductID,
	   p.[Name]
  FROM Sales.SalesOrderDetail sod
  JOIN Production.[Product]   p   ON p.ProductID = sod.ProductID
 WHERE sod.SalesOrderID > 60000

------------------------------------------------------------------------------------------------------------------------------------------
-- 168
------------------------------------------------------------------------------------------------------------------------------------------

         SELECT st.TerritoryID,
                st.CountryRegionCode,
         	    soh.SalesOrderID
           FROM Sales.SalesTerritory   st
LEFT OUTER JOIN Sales.SalesOrderHeader soh ON soh.TerritoryID = st.TerritoryID

------------------------------------------------------------------------------------------------------------------------------------------
-- 169
------------------------------------------------------------------------------------------------------------------------------------------

         SELECT st.TerritoryID,
                st.CountryRegionCode,
         	    soh.SalesOrderID
           FROM Sales.SalesTerritory   st
FULL OUTER JOIN Sales.SalesOrderHeader soh ON soh.TerritoryID = st.TerritoryID

------------------------------------------------------------------------------------------------------------------------------------------
-- 170
------------------------------------------------------------------------------------------------------------------------------------------

    SELECT st.TerritoryID,
	       soh.SalesOrderID
      FROM Sales.SalesTerritory   st
CROSS JOIN Sales.SalesOrderHeader soh
  ORDER BY soh.SalesOrderID

------------------------------------------------------------------------------------------------------------------------------------------
-- 171
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT BusinessEntityID,
         JobTitle,
  	     BirthDate
    FROM HumanResources.Employee
   WHERE JobTitle = 'Production Technician - WC40'
     AND BirthDate > '1988-09-01'
ORDER BY BirthDate ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 172
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT BusinessEntityID,
         PersonType,
  	     FirstName,
  	     MiddleName,
  	     LastName
    FROM Person.Person
   WHERE FirstName <> 'Adam'
ORDER BY FirstName ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 173
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT BusinessEntityID,
         PersonType,
  	     FirstName,
  	     MiddleName,
  	     LastName
    FROM Person.Person
   WHERE FirstName = 'Adam'
ORDER BY FirstName ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 174
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT BusinessEntityID,
         PersonType,
  	     FirstName,
  	     MiddleName,
  	     LastName
    FROM Person.Person
   WHERE MiddleName IS NOT NULL
ORDER BY FirstName ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 175
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT BusinessEntityID,
         PersonType,
  	     FirstName,
  	     MiddleName,
  	     LastName
    FROM Person.Person
   WHERE MiddleName IS NOT DISTINCT FROM NULL
ORDER BY FirstName ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 176
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT [Name], 
         [Weight], 
  	     Color
    FROM Production.[Product]
   WHERE [Weight] < 10
      OR Color IS NULL
ORDER BY [Name] ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 177
------------------------------------------------------------------------------------------------------------------------------------------

-- Os estilos de exibição vêm do terceiro argumento do CONVERT: 1 = valor monetário com vírgulas, 3 = data dd/mm/aa
SELECT BusinessEntityID,
       SalesYTD,
	   CONVERT(VARCHAR(12), SalesYTD, 1)   AS moneydisplaystyle1,
	   GETDATE()                           AS CurrentDate,
	   CONVERT(VARCHAR(12), GETDATE(), 3)  AS datedisplaystyle3
  FROM Sales.SalesPerson
 WHERE CAST(SalesYTD AS VARCHAR(20)) LIKE '1%'

------------------------------------------------------------------------------------------------------------------------------------------
-- 178
------------------------------------------------------------------------------------------------------------------------------------------

         SELECT d.[Name],
                CASE WHEN GROUPING(d.[Name]) = 0 AND GROUPING(e.JobTitle) = 0 THEN e.JobTitle
                     WHEN GROUPING(d.[Name]) = 0 AND GROUPING(e.JobTitle) = 1 THEN CONCAT('Total: ', d.[Name])
                     WHEN GROUPING(d.[Name]) = 1 AND GROUPING(e.JobTitle) = 1 THEN 'Company Total: '
                     ELSE 'Unknown'
                      END AS JobTitle,
         	   COUNT(e.BusinessEntityID) AS EmployeeCount
           FROM HumanResources.Employee                  e
           JOIN HumanResources.EmployeeDepartmentHistory edh ON e.BusinessEntityID = edh.BusinessEntityID  
           JOIN HumanResources.Department                d   ON d.DepartmentID = edh.DepartmentID       
          WHERE edh.EndDate IS NULL
            AND d.DepartmentID IN (12,14)
GROUP BY ROLLUP (d.[Name], e.JobTitle)

------------------------------------------------------------------------------------------------------------------------------------------
-- 179
------------------------------------------------------------------------------------------------------------------------------------------

         SELECT d.[Name], 
                e.JobTitle, GROUPING(d.[Name]) + GROUPING(e.JobTitle) AS GroupingLevel, 
         	    COUNT(e.BusinessEntityID)                             AS EmployeeCount  
           FROM HumanResources.Employee                  e
           JOIN HumanResources.EmployeeDepartmentHistory edh ON edh.BusinessEntityID = e.BusinessEntityID  
           JOIN HumanResources.Department                d   ON d.DepartmentID = edh.DepartmentID       
          WHERE edh.EndDate IS NULL  
            AND d.DepartmentID IN (12, 14)  
GROUP BY ROLLUP (d.[Name], e.JobTitle)
         HAVING GROUPING(d.[Name]) + GROUPING(E.JobTitle) = 1

------------------------------------------------------------------------------------------------------------------------------------------
-- 180
------------------------------------------------------------------------------------------------------------------------------------------

         SELECT d.[Name],
                e.JobTitle,
                GROUPING(d.[Name]) + GROUPING(e.JobTitle) AS GroupingLevel,
                COUNT(e.BusinessEntityID) AS EmployeeCount
           FROM HumanResources.Employee e
           JOIN HumanResources.EmployeeDepartmentHistory edh ON edh.BusinessEntityID = e.BusinessEntityID  
           JOIN HumanResources.Department d ON d.DepartmentID = edh.DepartmentID       
          WHERE edh.EndDate IS NULL  
            AND d.DepartmentID IN (12,14)  
GROUP BY ROLLUP (d.[Name], e.JobTitle)
         HAVING GROUPING(d.[Name]) + GROUPING(e.JobTitle) = 0

------------------------------------------------------------------------------------------------------------------------------------------
-- 181
------------------------------------------------------------------------------------------------------------------------------------------

SELECT QuotaDate                                                         AS [Year],
       DATEPART(QUARTER, QuotaDate)                                      AS [Quarter],
	   SalesQuota,											             
	   LAG(SalesQuota, 1,0) OVER (ORDER BY YEAR(QuotaDate))              AS PreviousQuota,
	   SalesQuota - LAG(SalesQuota, 1,0) OVER (ORDER BY YEAR(QuotaDate)) AS DiffQuota
  FROM Sales.SalesPersonQuotaHistory
 WHERE BusinessEntityID = 277
   AND YEAR(QuotaDate) IN (2012, 2013)

------------------------------------------------------------------------------------------------------------------------------------------
-- 182
------------------------------------------------------------------------------------------------------------------------------------------

SELECT YEAR(QuotaDate)                                                   AS [Year],
       DATEPART(QUARTER, QuotaDate)                                      AS [Quarter],
	   SalesQuota,											             
	   LAG(SalesQuota, 1,0) OVER (ORDER BY YEAR(QuotaDate))              AS PreviousQuota,
	   SalesQuota - LAG(SalesQuota, 1,0) OVER (ORDER BY YEAR(QuotaDate)) AS DiffQuota
  FROM Sales.SalesPersonQuotaHistory
 WHERE BusinessEntityID = 277
   AND YEAR(QuotaDate) IN (2012, 2013)

------------------------------------------------------------------------------------------------------------------------------------------
-- 183
------------------------------------------------------------------------------------------------------------------------------------------

SELECT SalesOrderID,
       MONTH(OrderDate)																						  AS MonthOrderOccurred,
       SalesPersonID,
	   CustomerID,
	   SubTotal,
	   SUM(subtotal) OVER (PARTITION BY CustomerID ORDER BY OrderDate, SalesOrderID ROWS UNBOUNDED PRECEDING) AS RunningTotal,
	   OrderDate																						      AS ActualOrderDate
  FROM Sales.SalesOrderHeader
 WHERE OrderDate >= '2011-12-01'
   AND SalesPersonID IS NOT NULL

------------------------------------------------------------------------------------------------------------------------------------------
-- 184
------------------------------------------------------------------------------------------------------------------------------------------

SELECT [Name],
       ProductNumber,
	   RIGHT(REPLICATE('0', 4) + ProductNumber, 12) AS FullProductNumber
  FROM Production.[Product]

------------------------------------------------------------------------------------------------------------------------------------------
-- 185
------------------------------------------------------------------------------------------------------------------------------------------

SELECT [Description],
       DiscountPct,
	   MinQty,
	   ISNULL(MaxQty, 0) AS MaxQty
  FROM Sales.SpecialOffer

------------------------------------------------------------------------------------------------------------------------------------------
-- 186
------------------------------------------------------------------------------------------------------------------------------------------

SELECT [Name],
       [Weight]
  FROM Production.[Product]
 WHERE [Weight] IS NULL

------------------------------------------------------------------------------------------------------------------------------------------
-- 187
------------------------------------------------------------------------------------------------------------------------------------------

SELECT [Name],
       Color,
	   ProductNumber,
	   COALESCE(Color, ProductNumber) AS FirstNotNull
  FROM Production.[Product]

------------------------------------------------------------------------------------------------------------------------------------------
-- 188 e 189 (Erro de exercicio duplicado na pagina)
------------------------------------------------------------------------------------------------------------------------------------------

SELECT wo.productid, 
       wo.startdate 
  FROM Production.WorkOrder wo  
WHERE NOT EXISTS (SELECT *   
                    FROM Production.WorkOrderRouting wor
                   WHERE (wo.ProductID = wor.ProductID AND wo.StartDate = wor.ActualStartDate))

------------------------------------------------------------------------------------------------------------------------------------------
-- 190
------------------------------------------------------------------------------------------------------------------------------------------

-- Comparação de texto com texto: comparar com número forçaria a conversão de cada caractere para INT
SELECT SalesOrderID,
       OrderDate,
	   CreditCardApprovalCode
  FROM Sales.SalesOrderHeader
 WHERE SUBSTRING(CreditCardApprovalCode, 1, 1) = '1'
   AND SUBSTRING(CreditCardApprovalCode, 3, 1) = '6'

------------------------------------------------------------------------------------------------------------------------------------------
-- 191
------------------------------------------------------------------------------------------------------------------------------------------

SELECT CONCAT('The order is due on ', CAST(DueDate AS VARCHAR(12)))
  FROM Sales.SalesOrderHeader
 WHERE SalesOrderID = 50001

------------------------------------------------------------------------------------------------------------------------------------------
-- 192
------------------------------------------------------------------------------------------------------------------------------------------

SELECT p.LastName + ', ' + SUBSTRING(FirstName, 1, 1) + '.' AS CustomName,
       e.JobTitle
  FROM HumanResources.Employee e
  JOIN Person.Person           p ON p.BusinessEntityID = e.BusinessEntityID
 WHERE e.JobTitle LIKE 'Vice%'

------------------------------------------------------------------------------------------------------------------------------------------
-- 193
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT [Name],
         ProductNumber,
  	     ListPrice
    FROM Production.[Product]
   WHERE ProductLine = 'R'
     AND DaysToManufacture < 4
ORDER BY [Name] ASC

------------------------------------------------------------------------------------------------------------------------------------------
-- 194
------------------------------------------------------------------------------------------------------------------------------------------

  SELECT p.[Name],
         (sod.OrderQty * sod.UnitPrice)                         AS NonDiscountSales,
		 (sod.OrderQty * sod.UnitPrice * sod.UnitPriceDiscount) AS Discount
    FROM Sales.SalesOrderDetail sod
    JOIN Production.[Product]   p   ON p.ProductID = sod.ProductID
ORDER BY p.[Name] DESC
