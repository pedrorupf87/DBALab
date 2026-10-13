
USE NORTHWIND
GO

------------------------------------------------------------------------------------------------------------------------------------------
-- 01
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_LOG_01
CREATE TABLE #TEMP_LOG_01
(
	ErrorLog  VARCHAR(255),
	ErrorDate DATETIME
)

DROP TABLE IF EXISTS #RESULT_TEMP_01
CREATE TABLE #RESULT_TEMP_01
(
    OrderID INT,
    CustomerID VARCHAR(5),
    OrderDate DATETIME
)

BEGIN TRAN

BEGIN TRY
	DECLARE @SQL01 NVARCHAR(MAX)
	SET @SQL01 = N'
	    SELECT OrderID, 
		       CustomerID,
			   OrderDate
		  FROM Orders
		 WHERE CustomerID = @CustomerId01
		   AND OrderDate BETWEEN @BeginDate01 AND @EndDate01'

	INSERT INTO #RESULT_TEMP_01 ( OrderID, CustomerID, OrderDate )
	EXEC sp_executesql @SQL01, 
	                   N'@CustomerId01 VARCHAR(5), @BeginDate01 DATETIME, @EndDate01 DATETIME',
					   @CustomerId01 = 'ALFKI', @BeginDate01 = '19970101', @EndDate01 = '19971231'

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN

	INSERT INTO #TEMP_LOG_01
	VALUES ( ERROR_MESSAGE(), GETDATE() )
END CATCH

SELECT * FROM #RESULT_TEMP_01

DROP TABLE #RESULT_TEMP_01
SELECT * FROM #TEMP_LOG_01
DROP TABLE #TEMP_LOG_01

------------------------------------------------------------------------------------------------------------------------------------------
-- 02
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_LOG_02
CREATE TABLE #TEMP_LOG_02
(
	ErrorLog  VARCHAR(255),
	ErrorDate DATETIME
)

DROP TABLE IF EXISTS #RESULT_TEMP_02
CREATE TABLE #RESULT_TEMP_02
(
    CustomerID  CHAR(5),
	CompanyName VARCHAR(50),
	City        VARCHAR(15),
	Country     VARCHAR(15)
)

BEGIN TRAN

BEGIN TRY
	DECLARE @SQL02 NVARCHAR(MAX)
	SET @SQL02 = N'
	    INSERT INTO #RESULT_TEMP_02
		VALUES ( @CustomerId02, @CompanyName02, @City02, @Country02 )'

	EXEC sp_executesql @SQL02, 
	                   N'@CustomerId02 CHAR(5), @CompanyName02 VARCHAR(50), @City02 VARCHAR(15), @Country02 VARCHAR(15)',
					   @CustomerId02 = 'TESTE', @CompanyName02 = 'PAPEL DE PÃO S/A', @City02 = 'VARGINHA', @Country02 = 'Brazil'

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN

	INSERT INTO #TEMP_LOG_02
	VALUES ( ERROR_MESSAGE(), GETDATE() )
END CATCH

SELECT * FROM #RESULT_TEMP_02

DROP TABLE #RESULT_TEMP_02
SELECT * FROM #TEMP_LOG_02
DROP TABLE #TEMP_LOG_02

------------------------------------------------------------------------------------------------------------------------------------------
-- 03
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_LOG_03
CREATE TABLE #TEMP_LOG_03
(
	ErrorLog  VARCHAR(255),
	ErrorDate DATETIME
)

DROP TABLE IF EXISTS #RESULT_TEMP_03
CREATE TABLE #RESULT_TEMP_03
(
    CategoryName VARCHAR(50),
	TotalSales   MONEY
)

BEGIN TRAN

BEGIN TRY
	DECLARE @SQL03 NVARCHAR(MAX)
	SET @SQL03 = N'
	      SELECT c.CategoryName, 
                 SUM( od.Quantity * od.UnitPrice ) AS TotalSales
            FROM [Order Details] od
            JOIN Products         p ON p.ProductID  = od.ProductID
            JOIN Categories       c ON c.CategoryID = p.CategoryID
        GROUP BY CategoryName'

	INSERT INTO #RESULT_TEMP_03 ( CategoryName, TotalSales )
	EXEC sp_executesql @SQL03

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN

	INSERT INTO #TEMP_LOG_03
	VALUES ( ERROR_MESSAGE(), GETDATE() )
END CATCH

SELECT * FROM #RESULT_TEMP_03

DROP TABLE #RESULT_TEMP_03
SELECT * FROM #TEMP_LOG_03
DROP TABLE #TEMP_LOG_03

------------------------------------------------------------------------------------------------------------------------------------------
-- 04
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_LOG_04
CREATE TABLE #TEMP_LOG_04
(
	ErrorLog  VARCHAR(255),
	ErrorDate DATETIME
)

DROP TABLE IF EXISTS #RESULT_TEMP_04
CREATE TABLE #RESULT_TEMP_04
(
    ProductId    INT,
	ProductName  VARCHAR(50),
	CategoryId   INT,
	UnitsInStock SMALLINT
)

-- ## PARA NAO ALTERAR A BASE, O ESTOQUE E ATUALIZADO EM UMA COPIA TEMPORARIA DE PRODUCTS

INSERT INTO #RESULT_TEMP_04 ( ProductId, ProductName, CategoryId, UnitsInStock )
SELECT ProductID,
       ProductName,
       CategoryID,
       UnitsInStock
  FROM Products

BEGIN TRAN

BEGIN TRY
	DECLARE @SQL04 NVARCHAR(MAX)
	SET @SQL04 = N'
	    UPDATE #RESULT_TEMP_04
		   SET UnitsInStock = UnitsInStock + @Quantity04
		 WHERE CategoryId   = @CategoryId04'

	EXEC sp_executesql @SQL04,
	                   N'@Quantity04 SMALLINT, @CategoryId04 INT',
					   @Quantity04 = 10, @CategoryId04 = 2

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN

	INSERT INTO #TEMP_LOG_04
	VALUES ( ERROR_MESSAGE(), GETDATE() )
END CATCH

SELECT r.ProductId,
       r.ProductName,
       p.UnitsInStock AS OldUnitsInStock,
       r.UnitsInStock AS NewUnitsInStock
  FROM #RESULT_TEMP_04 r
  JOIN Products        p ON p.ProductID = r.ProductId
 WHERE r.CategoryId = 2

DROP TABLE #RESULT_TEMP_04
SELECT * FROM #TEMP_LOG_04
DROP TABLE #TEMP_LOG_04

------------------------------------------------------------------------------------------------------------------------------------------
-- 05
------------------------------------------------------------------------------------------------------------------------------------------

-- ## PARA NAO ALTERAR A BASE, IREI INSERIR OS REGISTROS EM UMA TEMPORARIA, PARA DEPOIS APRESENTAR

DROP TABLE IF EXISTS #TEMP_LOG_05
CREATE TABLE #TEMP_LOG_05
(
	ErrorLog  VARCHAR(255),
	ErrorDate DATETIME
)

DROP TABLE IF EXISTS #RESULT_TEMP_05
CREATE TABLE #RESULT_TEMP_05
(
    OrderId    INT,
	CustomerId CHAR(5),
	Freight    MONEY
)

BEGIN TRAN

BEGIN TRY
	DECLARE @SQL05 NVARCHAR(MAX)
	SET @SQL05 = N'
	    SELECT OrderID,
               CustomerID,
	           Freight
          FROM Orders
         WHERE OrderDate < @EndDate05'

	INSERT INTO #RESULT_TEMP_05
	EXEC sp_executesql @SQL05,
	                   N'@EndDate05 DATETIME',
					   @EndDate05 = '19970630'

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	
	INSERT INTO #TEMP_LOG_05
	VALUES ( ERROR_MESSAGE(), GETDATE() )
END CATCH


SELECT * FROM #RESULT_TEMP_05

DROP TABLE #RESULT_TEMP_05
SELECT * FROM #TEMP_LOG_05
DROP TABLE #TEMP_LOG_05

------------------------------------------------------------------------------------------------------------------------------------------
-- 06
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_LOG_06
CREATE TABLE #TEMP_LOG_06
(
	ErrorLog  VARCHAR(255),
	ErrorDate DATETIME
)

DROP TABLE IF EXISTS #RESULT_TEMP_06
CREATE TABLE #RESULT_TEMP_06
(
    ProductId   INT,
	ProductName VARCHAR(50),
	UnitPrice   MONEY
)

BEGIN TRAN

BEGIN TRY
	DECLARE @SQL06 NVARCHAR(MAX)
	SET @SQL06 = N'
	      INSERT INTO #RESULT_TEMP_06 ( ProductId, ProductName, UnitPrice )
		  SELECT TOP 8 
                 ProductID,
                 ProductName,
          	     UnitPrice
            FROM Products
        ORDER BY UnitPrice DESC;
		
		UPDATE #RESULT_TEMP_06
		   SET UnitPrice = UnitPrice * ( 1 - @Percent06 / 100 );'
	
	EXEC sp_executesql @SQL06,
					   N'@Percent06 FLOAT',
					   @Percent06 = 30

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN

	INSERT INTO #TEMP_LOG_06
	VALUES ( ERROR_MESSAGE(), GETDATE() )
END CATCH

  SELECT TOP 8 
         ProductID,
         ProductName,
  	     ROUND(UnitPrice, 2) AS UnitPrice
    FROM Products
ORDER BY UnitPrice DESC

SELECT ProductID,
       ProductName,
  	   ROUND(UnitPrice, 2) AS UnitPrice
  FROM #RESULT_TEMP_06

DROP TABLE #RESULT_TEMP_06
SELECT * FROM #TEMP_LOG_06
DROP TABLE #TEMP_LOG_06

------------------------------------------------------------------------------------------------------------------------------------------
-- 07
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_LOG_07
CREATE TABLE #TEMP_LOG_07
(
	ErrorLog  VARCHAR(255),
	ErrorDate DATETIME
)

-- ## O NORTHWIND NAO TEM ARMAZENS: A TRANSFERENCIA E SIMULADA ENTRE DOIS PRODUTOS
-- ## PARA NAO ALTERAR A BASE, E FEITA EM UMA COPIA TEMPORARIA DE PRODUCTS, COM O MESMO CHECK DE ESTOQUE DA TABELA REAL

DROP TABLE IF EXISTS #RESULT_TEMP_07
CREATE TABLE #RESULT_TEMP_07
(
    ProductId    INT,
	ProductName  VARCHAR(50),
	UnitsInStock SMALLINT CHECK ( UnitsInStock >= 0 )
)

INSERT INTO #RESULT_TEMP_07 ( ProductId, ProductName, UnitsInStock )
SELECT ProductID,
       ProductName,
       UnitsInStock
  FROM Products
 WHERE ProductID IN ( 1, 2 )

BEGIN TRAN

BEGIN TRY
    DECLARE @SQL07 NVARCHAR(MAX)
    SET @SQL07 = N'
        UPDATE #RESULT_TEMP_07
           SET UnitsInStock = UnitsInStock - @Quantity07
         WHERE ProductId    = @SourceProductId07

        UPDATE #RESULT_TEMP_07
           SET UnitsInStock = UnitsInStock + @Quantity07
         WHERE ProductId    = @DestinationProductId07'

    -- Com @Quantity07 acima do estoque de origem (39), o CHECK falha e a transação inteira é revertida
    EXEC sp_executesql @SQL07,
                       N'@Quantity07 INT, @SourceProductId07 INT, @DestinationProductId07 INT',
                       @Quantity07 = 10, @SourceProductId07 = 1, @DestinationProductId07 = 2

    COMMIT TRAN
END TRY
BEGIN CATCH
    ROLLBACK TRAN

    INSERT INTO #TEMP_LOG_07
    VALUES ( ERROR_MESSAGE(), GETDATE() )
END CATCH

SELECT * FROM #RESULT_TEMP_07

DROP TABLE #RESULT_TEMP_07
SELECT * FROM #TEMP_LOG_07
DROP TABLE #TEMP_LOG_07

------------------------------------------------------------------------------------------------------------------------------------------
-- 08
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_LOG_08
CREATE TABLE #TEMP_LOG_08
(
	ErrorLog  VARCHAR(255),
	ErrorDate DATETIME
)

BEGIN TRAN

BEGIN TRY
	DECLARE @SQL08     NVARCHAR(MAX),
	        @Columns08 NVARCHAR(MAX)

	-- Colunas especificadas pelo usuário
	SET @Columns08 = N'ProductId INT, ProductName VARCHAR(50), UnitPrice MONEY'

	-- Uma #temp criada dentro do sp_executesql só existe durante essa execução.
	-- Por isso a criação, a carga e a consulta ficam no mesmo comando dinâmico
	SET @SQL08 = N'
	    CREATE TABLE #TEMP_PRODUCTS ( ' + @Columns08 + N' )

		INSERT INTO #TEMP_PRODUCTS
		  SELECT TOP 5
		         ProductID,
		         ProductName,
		         UnitPrice
		    FROM Products
		ORDER BY ProductID

		SELECT * FROM #TEMP_PRODUCTS'

	EXEC sp_executesql @SQL08

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN

    INSERT INTO #TEMP_LOG_08
    VALUES ( ERROR_MESSAGE(), GETDATE() )
END CATCH

SELECT * FROM #TEMP_LOG_08
DROP TABLE #TEMP_LOG_08

------------------------------------------------------------------------------------------------------------------------------------------
-- 09
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_LOG_09
CREATE TABLE #TEMP_LOG_09
(
	ErrorLog  VARCHAR(255),
	ErrorDate DATETIME
)

DROP TABLE IF EXISTS #RESULT_TEMP_09
CREATE TABLE #RESULT_TEMP_09
(
	CustomerId CHAR(5),
	TotalSales MONEY
)

BEGIN TRAN

BEGIN TRY
	DECLARE @SQL09 NVARCHAR(MAX)
	SET @SQL09 = N'
          SELECT o.CustomerID, 
                 SUM( od.Quantity * od.UnitPrice ) AS TotalSales
            FROM [Order Details] od
            JOIN Orders           o ON o.OrderID = od.OrderID
           WHERE o.OrderDate BETWEEN @BeginDate09 AND @EndDate09
        GROUP BY CustomerID'

	INSERT INTO #RESULT_TEMP_09
	EXEC sp_executesql @SQL09,
	                   N'@BeginDate09 DATETIME, @EndDate09 DATETIME',
					   @BeginDate09 = '19970101', @EndDate09 = '19970630'

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN

    INSERT INTO #TEMP_LOG_09
    VALUES ( ERROR_MESSAGE(), GETDATE() )
END CATCH

SELECT * FROM #RESULT_TEMP_09

DROP TABLE #RESULT_TEMP_09
SELECT * FROM #TEMP_LOG_09
DROP TABLE #TEMP_LOG_09

------------------------------------------------------------------------------------------------------------------------------------------
-- 10
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_LOG_10
CREATE TABLE #TEMP_LOG_10
(
	ErrorLog  VARCHAR(255),
	ErrorDate DATETIME
)

DROP TABLE IF EXISTS #RESULT_TEMP_10
CREATE TABLE #RESULT_TEMP_10
(
	OrderId   INT,
	ProductId INT,
	UnitPrice MONEY,
	Quantity  SMALLINT,
	Discount  REAL
)

BEGIN TRAN

BEGIN TRY
	DECLARE @SQL10 NVARCHAR(MAX)
	SET @SQL10 = N'
	      INSERT INTO #RESULT_TEMP_10
          SELECT TOP 1
                 OrderID, 
	             ProductID,
	             UnitPrice,
	             Quantity,
	             Discount
            FROM [Order Details]
        ORDER BY OrderID DESC'

	EXEC sp_executesql @SQL10

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN

	INSERT INTO #TEMP_LOG_10
	VALUES ( ERROR_MESSAGE(), GETDATE() )
END CATCH


SELECT * FROM #RESULT_TEMP_10

DROP TABLE #RESULT_TEMP_10
SELECT * FROM #TEMP_LOG_10
DROP TABLE #TEMP_LOG_10

------------------------------------------------------------------------------------------------------------------------------------------
-- 11
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_LOG_11
CREATE TABLE #TEMP_LOG_11
(
	ErrorLog  VARCHAR(255),
	ErrorDate DATETIME
)

-- ## PARA NAO ALTERAR A BASE, O INDICE E CRIADO EM UMA COPIA TEMPORARIA DE ORDER DETAILS

DROP TABLE IF EXISTS #RESULT_TEMP_11
SELECT OrderID,
       ProductID,
       UnitPrice,
       Quantity,
       Discount
  INTO #RESULT_TEMP_11
  FROM [Order Details]

BEGIN TRAN

BEGIN TRY
	DECLARE @SQL11        NVARCHAR(MAX),
	        @ColumnName11 SYSNAME

	-- Coluna fornecida pelo usuário
	SET @ColumnName11 = N'ProductID'

	-- Validação: a coluna precisa existir na tabela
	IF COL_LENGTH('tempdb..#RESULT_TEMP_11', @ColumnName11) IS NULL
		THROW 50001, 'A coluna informada não existe na tabela.', 1

	-- QUOTENAME protege o nome da coluna contra injeção de SQL.
	-- O índice é NONCLUSTERED: [Order Details] já tem índice clustered (a PK) e só pode existir um por tabela
	SET @SQL11 = N'CREATE NONCLUSTERED INDEX ' + QUOTENAME(N'IDX_OrderDetails_' + @ColumnName11)
	           + N' ON #RESULT_TEMP_11 (' + QUOTENAME(@ColumnName11) + N')'

	EXEC sp_executesql @SQL11

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN

	INSERT INTO #TEMP_LOG_11
	VALUES ( ERROR_MESSAGE(), GETDATE() )
END CATCH

DROP TABLE #RESULT_TEMP_11
SELECT * FROM #TEMP_LOG_11
DROP TABLE #TEMP_LOG_11

------------------------------------------------------------------------------------------------------------------------------------------
-- 12
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_LOG_12
CREATE TABLE #TEMP_LOG_12
(
	ErrorLog  VARCHAR(255),
	ErrorDate DATETIME
)

BEGIN TRAN

BEGIN TRY
    DECLARE @SQL12       NVARCHAR(MAX),
	        @Columns12   NVARCHAR(MAX),
			@TableName12 SYSNAME,
			@Country12   NVARCHAR(15)

	-- Nomes de tabela e de coluna não podem ser parâmetros do sp_executesql: entram por concatenação
	-- e precisam estar atribuídos ANTES de montar o comando. O valor do filtro entra como parâmetro
	SET @Columns12   = N'CustomerID, CompanyName, City, Country'
	SET @TableName12 = N'Customers'
	SET @Country12   = N'Brazil'

    SET @SQL12 = N'SELECT ' + @Columns12 + N' FROM ' + QUOTENAME(@TableName12) + N' WHERE Country = @Country'

    EXEC sp_executesql @SQL12,
                       N'@Country NVARCHAR(15)',
                       @Country = @Country12

	COMMIT TRAN
END TRY
BEGIN CATCH
    ROLLBACK TRAN

	INSERT INTO #TEMP_LOG_12
	VALUES ( ERROR_MESSAGE(), GETDATE() )
END CATCH

SELECT * FROM #TEMP_LOG_12
DROP TABLE #TEMP_LOG_12

------------------------------------------------------------------------------------------------------------------------------------------
-- 13
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_LOG_13
CREATE TABLE #TEMP_LOG_13
(
	ErrorLog  VARCHAR(255),
	ErrorDate DATETIME
)

DROP TABLE IF EXISTS #RESULT_TEMP_13
CREATE TABLE #RESULT_TEMP_13
(
	ProductId            INT,
	ProductName          VARCHAR(50),
	PriceWithoutDiscount MONEY,
	PriceWithDiscount    MONEY
)

BEGIN TRAN

BEGIN TRY
	DECLARE @SQL13 NVARCHAR(MAX)
	SET @SQL13 = N'
	    INSERT INTO #RESULT_TEMP_13
		SELECT ProductID,
               ProductName,
	           UnitPrice                               AS PriceWithoutDiscount,
			   (( 1 - @Percent13 / 100 ) * UnitPrice ) AS PriceWithDiscount
          FROM Products
		 WHERE CategoryID = @CategoryId13'

	EXEC sp_executesql @SQL13,
	                   N'@Percent13 FLOAT, @CategoryId13 INT',
					   @Percent13 = 30, @CategoryId13 = 2

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN

	INSERT INTO #TEMP_LOG_13
	VALUES ( ERROR_MESSAGE(), GETDATE() )
END CATCH

SELECT * FROM #RESULT_TEMP_13

DROP TABLE #RESULT_TEMP_13
SELECT * FROM #TEMP_LOG_13
DROP TABLE #TEMP_LOG_13

------------------------------------------------------------------------------------------------------------------------------------------
-- 14
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_LOG_14
CREATE TABLE #TEMP_LOG_14
(
	ErrorLog  VARCHAR(255),
	ErrorDate DATETIME
)

DROP TABLE IF EXISTS #RESULT_TEMP_14
CREATE TABLE #RESULT_TEMP_14
(
	CustomerId CHAR(5),
	TotalSales MONEY
)

BEGIN TRAN

BEGIN TRY
	DECLARE @SQL14 NVARCHAR(MAX)
	SET @SQL14 = N'
          INSERT INTO #RESULT_TEMP_14
		  SELECT o.CustomerID, 
                 SUM( od.Quantity * od.UnitPrice ) AS TotalSales
            FROM [Order Details] od
            JOIN Orders           o ON o.OrderID = od.OrderID
           WHERE o.OrderDate BETWEEN @BeginDate14 AND @EndDate14
        GROUP BY CustomerID'
	
	EXEC sp_executesql @SQL14,
	                   N'@BeginDate14 DATETIME, @EndDate14 DATETIME',
					   @BeginDate14 = '19960101', @EndDate14 = '19961231'

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN

    INSERT INTO #TEMP_LOG_14
    VALUES ( ERROR_MESSAGE(), GETDATE() )
END CATCH

SELECT * FROM #RESULT_TEMP_14

DROP TABLE #RESULT_TEMP_14
SELECT * FROM #TEMP_LOG_14
DROP TABLE #TEMP_LOG_14

------------------------------------------------------------------------------------------------------------------------------------------
-- 15
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_LOG_15
CREATE TABLE #TEMP_LOG_15
(
	ErrorLog  VARCHAR(255),
	ErrorDate DATETIME
)

-- ## PARA NAO ALTERAR A BASE, A EXCLUSAO E FEITA EM UMA COPIA TEMPORARIA DE ORDERS

DROP TABLE IF EXISTS #RESULT_TEMP_15
SELECT OrderID,
       CustomerID,
       OrderDate
  INTO #RESULT_TEMP_15
  FROM Orders

BEGIN TRAN

BEGIN TRY
    DECLARE @SQL15       NVARCHAR(MAX),
	        @TableName15 SYSNAME,
			@Condition15 NVARCHAR(MAX)

	-- Tabela e critério atribuídos ANTES de montar o comando; a data do critério entra como parâmetro
	SET @TableName15 = N'#RESULT_TEMP_15'
	SET @Condition15 = N'OrderDate < @EndDate15'

    SET @SQL15 = N'DELETE FROM ' + QUOTENAME(@TableName15) + N' WHERE ' + @Condition15

    EXEC sp_executesql @SQL15,
					   N'@EndDate15 DATETIME',
					   @EndDate15 = '19970101'

    COMMIT TRAN
END TRY
BEGIN CATCH
    ROLLBACK TRAN

    INSERT INTO #TEMP_LOG_15
    VALUES ( ERROR_MESSAGE(), GETDATE() )
END CATCH

SELECT ( SELECT COUNT(*) FROM Orders )           AS TotalOrders,
       ( SELECT COUNT(*) FROM #RESULT_TEMP_15 )  AS RemainingOrders

DROP TABLE #RESULT_TEMP_15
SELECT * FROM #TEMP_LOG_15
DROP TABLE #TEMP_LOG_15

------------------------------------------------------------------------------------------------------------------------------------------
-- 16
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_LOG_16
CREATE TABLE #TEMP_LOG_16
(
	ErrorLog  VARCHAR(255),
	ErrorDate DATETIME
)

BEGIN TRAN

BEGIN TRY
    DECLARE @SQL16        NVARCHAR(MAX),
	        @ColumnName16 NVARCHAR(MAX),
			@TableName16  SYSNAME,
			@Condition16  NVARCHAR(MAX)

	-- As variáveis são atribuídas ANTES de montar o comando: concatenar com NULL resulta em NULL
	SET @ColumnName16 = N'OrderID, CustomerID, OrderDate, Freight'
	SET @TableName16  = N'Orders'
	SET @Condition16  = N'ShippedDate IS NOT NULL'

    SET @SQL16 = N'SELECT ' + @ColumnName16 + N' FROM ' + QUOTENAME(@TableName16)

	IF ( @Condition16 IS NOT NULL )
		BEGIN
			SET @SQL16 = @SQL16 + N' WHERE ' + @Condition16
		END

    EXEC sp_executesql @SQL16

    COMMIT TRAN
END TRY
BEGIN CATCH
    ROLLBACK TRAN

    INSERT INTO #TEMP_LOG_16
    VALUES ( ERROR_MESSAGE(), GETDATE() )
END CATCH

SELECT * FROM #TEMP_LOG_16
DROP TABLE #TEMP_LOG_16

------------------------------------------------------------------------------------------------------------------------------------------
-- 17
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_LOG_17
CREATE TABLE #TEMP_LOG_17
(
	ErrorLog  VARCHAR(255),
	ErrorDate DATETIME
)

-- ## PARA NAO ALTERAR A BASE, A COLUNA E ADICIONADA EM UMA COPIA TEMPORARIA DE PRODUCTS

DROP TABLE IF EXISTS #RESULT_TEMP_17
SELECT ProductID,
       ProductName
  INTO #RESULT_TEMP_17
  FROM Products

BEGIN TRAN

BEGIN TRY
    DECLARE @SQL17        NVARCHAR(MAX),
	        @TableName17  SYSNAME,
			@ColumnName17 SYSNAME,
			@DataType17   NVARCHAR(50)

	-- Tabela, coluna e tipo atribuídos ANTES de montar o comando
	SET @TableName17  = N'#RESULT_TEMP_17'
	SET @ColumnName17 = N'NewColumn'
	SET @DataType17   = N'NVARCHAR(50)'

    SET @SQL17 = N'ALTER TABLE ' + QUOTENAME(@TableName17) + N' ADD ' + QUOTENAME(@ColumnName17) + N' ' + @DataType17

    EXEC sp_executesql @SQL17

    COMMIT TRAN
END TRY
BEGIN CATCH
    ROLLBACK TRAN

    INSERT INTO #TEMP_LOG_17
    VALUES ( ERROR_MESSAGE(), GETDATE() )
END CATCH

SELECT TOP 5 * FROM #RESULT_TEMP_17

DROP TABLE #RESULT_TEMP_17
SELECT * FROM #TEMP_LOG_17
DROP TABLE #TEMP_LOG_17

------------------------------------------------------------------------------------------------------------------------------------------
-- 18
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_LOG_18
CREATE TABLE #TEMP_LOG_18
(
	ErrorLog  VARCHAR(255),
	ErrorDate DATETIME
)

-- ## A TABELA DE DESTINO DA EXPORTACAO E UMA TEMPORARIA

DROP TABLE IF EXISTS #RESULT_TEMP_18
CREATE TABLE #RESULT_TEMP_18
(
	ProductID   INT,
	ProductName VARCHAR(50),
	UnitPrice   MONEY
)

BEGIN TRAN

BEGIN TRY
    DECLARE @SQL18              NVARCHAR(MAX),
	        @DestinationTable18 SYSNAME,
			@Columns18          NVARCHAR(MAX),
			@SourceTable18      SYSNAME

	-- Tabelas e colunas atribuídas ANTES de montar o comando; o valor do critério entra como parâmetro
	SET @DestinationTable18 = N'#RESULT_TEMP_18'
	SET @Columns18          = N'ProductID, ProductName, UnitPrice'
	SET @SourceTable18      = N'Products'

	SET @SQL18 = N'INSERT INTO ' + QUOTENAME(@DestinationTable18) + N' (' + @Columns18 + N')
                 SELECT ' + @Columns18 + N' FROM ' + QUOTENAME(@SourceTable18) + N' WHERE UnitPrice > @MinPrice18'

    EXEC sp_executesql @SQL18,
                       N'@MinPrice18 MONEY',
                       @MinPrice18 = 50

    COMMIT TRAN
END TRY
BEGIN CATCH
    ROLLBACK TRAN

    INSERT INTO #TEMP_LOG_18
    VALUES ( ERROR_MESSAGE(), GETDATE() )
END CATCH

SELECT * FROM #RESULT_TEMP_18

DROP TABLE #RESULT_TEMP_18
SELECT * FROM #TEMP_LOG_18
DROP TABLE #TEMP_LOG_18

------------------------------------------------------------------------------------------------------------------------------------------
-- 19
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_LOG_19
CREATE TABLE #TEMP_LOG_19
(
	ErrorLog  VARCHAR(255),
	ErrorDate DATETIME
)

-- ## PARA NAO ALTERAR A BASE, A ATUALIZACAO E FEITA EM UMA COPIA TEMPORARIA DE PRODUCTS

DROP TABLE IF EXISTS #RESULT_TEMP_19
SELECT ProductID,
       ProductName,
       CategoryID,
       UnitPrice
  INTO #RESULT_TEMP_19
  FROM Products

BEGIN TRAN

BEGIN TRY
    DECLARE @SQL19       NVARCHAR(MAX),
	        @TableName19 SYSNAME,
			@Update19    NVARCHAR(MAX),
			@Condition19 NVARCHAR(MAX)

	-- Tabela, atualização e critério atribuídos ANTES de montar o comando; os valores entram como parâmetros
	SET @TableName19 = N'#RESULT_TEMP_19'
	SET @Update19    = N'UnitPrice = UnitPrice * @Factor19'
	SET @Condition19 = N'CategoryID = @CategoryId19'

    SET @SQL19 = N'UPDATE ' + QUOTENAME(@TableName19) + N' SET ' + @Update19 + N' WHERE ' + @Condition19

    EXEC sp_executesql @SQL19,
                       N'@Factor19 DECIMAL(5,2), @CategoryId19 INT',
                       @Factor19 = 1.1, @CategoryId19 = 3

    COMMIT TRAN
END TRY
BEGIN CATCH
    ROLLBACK TRAN

    INSERT INTO #TEMP_LOG_19
    VALUES ( ERROR_MESSAGE(), GETDATE() )
END CATCH

SELECT r.ProductID,
       r.ProductName,
       p.UnitPrice AS OldUnitPrice,
       r.UnitPrice AS NewUnitPrice
  FROM #RESULT_TEMP_19 r
  JOIN Products        p ON p.ProductID = r.ProductID
 WHERE r.CategoryID = 3

DROP TABLE #RESULT_TEMP_19
SELECT * FROM #TEMP_LOG_19
DROP TABLE #TEMP_LOG_19

------------------------------------------------------------------------------------------------------------------------------------------
-- 20
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #TEMP_LOG_20
CREATE TABLE #TEMP_LOG_20
(
	ErrorLog  VARCHAR(255),
	ErrorDate DATETIME
)

DROP TABLE IF EXISTS #RESULT_TEMP_20
CREATE TABLE #RESULT_TEMP_20
(
	EmployeeId  INT,
	TotalOrders INT,
	TotalSales  MONEY
)

BEGIN TRAN

BEGIN TRY
	DECLARE @SQL20 NVARCHAR(MAX)

	-- COUNT(DISTINCT): depois do JOIN com Order Details há uma linha por item, não por pedido
	SET @SQL20 = N'
          SELECT o.EmployeeID,
                 COUNT( DISTINCT o.OrderID )       AS TotalOrders,
          	     SUM( od.Quantity * od.UnitPrice ) AS TotalSales
            FROM Orders           o
            JOIN [Order Details] od ON od.OrderID = o.OrderID
           WHERE OrderDate BETWEEN @BeginDate20 AND @EndDate20
        GROUP BY EmployeeID
        ORDER BY EmployeeID'

	INSERT INTO #RESULT_TEMP_20
	EXEC sp_executesql @SQL20,
	                   N'@BeginDate20 DATETIME, @EndDate20 DATETIME',
					   @BeginDate20 = '19970101', @EndDate20 = '19970930'

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN

	INSERT INTO #TEMP_LOG_20
	VALUES ( ERROR_MESSAGE(), GETDATE() )
END CATCH

SELECT * FROM #RESULT_TEMP_20

DROP TABLE #RESULT_TEMP_20
SELECT * FROM #TEMP_LOG_20
DROP TABLE #TEMP_LOG_20

