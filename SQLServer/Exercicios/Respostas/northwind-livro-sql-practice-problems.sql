USE NORTHWIND
GO

-- O livro usa uma versao propria do Northwind, com pedidos entre 2014 e 2016.
-- Estas respostas rodam no Northwind padrao (1996 a 1998): onde o livro pede 2015, uso 1997; onde pede 2016, uso 1998.

--------------------------------------------------------
-- LISTA DE EXERCICIOS - LIVRO: SQL PRACTICE PROBLEMS --
--------------------------------------------------------


---------------------------
-- INTRODUCTORY PROBLEMS --
---------------------------

-- 01
  select *
    from Shippers

-- 02
  select CategoryName,
         [Description]
    from Categories

-- 03
  select FirstName,
         LastName,
		 HireDate
    from Employees
   where Title = 'Sales Representative'

-- 04
  select FirstName,
         LastName,
		 HireDate
    from Employees
   where Title   = 'Sales Representative'
     and Country = 'USA'

-- 05
  select OrderID,
         OrderDate
    from Orders
   where EmployeeID = 5

-- 06
  select SupplierID,
         ContactName,
		 ContactTitle
    from Suppliers
   where ContactTitle != 'Marketing Manager'

-- 07
  select ProductID,
         ProductName
    from Products
   where ProductName like '%queso%'

-- 08
  select OrderID,
         CustomerID,
		 ShipCountry
    from Orders
   where ShipCountry = 'Belgium'
      or ShipCountry = 'France'

-- 09
    select OrderID,
         CustomerID,
		 ShipCountry
    from Orders
   where ShipCountry in ( 'Brazil', 'Mexico', 'Argentina', 'Venezuela' )

-- 10
-- "oldest employees first": ordem crescente de BirthDate
  select FirstName,
         LastName,
		 Title,
		 BirthDate
    from Employees
order by BirthDate

-- 11
  select FirstName,
         LastName,
		 Title,
		 convert(date, BirthDate) as BirthDate
    from Employees
order by BirthDate

-- 12
  select FirstName,
         LastName,
		 FirstName + ' ' + LastName as FullName
    from Employees

-- 13
  select OrderID,
         ProductID,
		 UnitPrice,
		 Quantity,
		 (UnitPrice * Quantity) as TotalPrice
    from [Order Details]
order by OrderID, ProductID

-- 14
  select count(*) as TotalCustomers
    from Customers

-- 15
  select cast(min(OrderDate) as date) as FirstOrderDate
    from Orders

-- 16
  select distinct
         Country
	from Customers

-- 17
  select ContactTitle,
         count(*) as Quantity
	from Customers
group by ContactTitle
order by Quantity desc

-- 18
  select p.ProductID,
         p.ProductName,
		 s.CompanyName
    from Products p
	join Suppliers s
	  on s.SupplierID = p.SupplierID
order by ProductID

-- 19
  select o.OrderID,
         cast(o.OrderDate as date) as OrderDate,
		 s.CompanyName
    from Orders   o
	join Shippers s
	  on s.ShipperID = o.ShipVia
   where OrderID < 10300
order by OrderID


---------------------------
-- INTERMEDIATE PROBLEMS --
---------------------------


-- 20
  select c.CategoryName,
         count(*) as Quantity
    from Products   p
	join Categories c
	  on c.CategoryID = p.CategoryID
group by c.CategoryName
order by Quantity desc

-- 21
  select Country,
         City,
		 count(*) as Quantity
    from Customers
group by Country, City
order by Quantity desc

-- 22
  select ProductID,
         ProductName,
		 UnitsInStock,
		 ReorderLevel
    from Products
   where UnitsInStock < ReorderLevel
order by ProductID

-- 23
  select ProductID,
         ProductName,
		 UnitsInStock,
		 UnitsOnOrder,
		 ReorderLevel,
		 Discontinued
    from Products
   where (UnitsInStock + UnitsOnOrder) <= ReorderLevel
     and Discontinued = 0
order by ProductID

-- 24
-- nulos por ultimo e, dentro da mesma regiao, ordem de CustomerID
  select CustomerID,
         CompanyName,
		 Region
    from Customers
order by case when Region is null then 1 else 0 end,
         Region,
		 CustomerID

-- 25
  select top 3
         ShipCountry,
         avg(Freight) as AverageFreight
    from Orders
group by ShipCountry
order by AverageFreight desc

-- 26
  select top 3
         ShipCountry,
         avg(Freight) as AverageFreight
    from Orders
   where cast(OrderDate as date) between '1997-01-01' and '1997-12-31'
group by ShipCountry
order by AverageFreight desc

-- 27
-- No banco do livro, um pedido de 31/12 tem horario preenchido e fica fora de "between ... and '20151231'".
-- No Northwind padrao todas as datas estao a meia-noite, entao o problema nao se reproduz;
-- a consulta abaixo lista os pedidos do ultimo dia do ano, que seriam os afetados.
  select OrderID,
         OrderDate
    from Orders
   where OrderDate >= '19971231'
     and OrderDate <  '19980101'

-- 28
  select top 3
         ShipCountry,
         avg(Freight) as AverageFreight
    from Orders
   where OrderDate >= dateadd(yy, -1, ( select max(OrderDate)
                                          from Orders ))
group by ShipCountry
order by AverageFreight desc

-- 29
  select o.EmployeeID,
         e.LastName,
		 o.OrderID,
		 p.ProductName,
		 od.Quantity
    from Orders o
	join [Order Details] od
	  on od.OrderID = o.OrderID
	join Employees e
	  on e.EmployeeID = o.EmployeeID
	join Products p
	  on p.ProductID = od.ProductID

-- 30
  select c.CustomerID as Customer_CustomerID,
         o.CustomerID as Order_CustomerID
    from Customers c
	left join Orders o
	  on o.CustomerID = c.CustomerID
   where o.CustomerID is null

-- 31
  select c.CustomerID as Customer_CustomerID,
         o.CustomerID as Order_CustomerID
    from Customers c
	left join Orders o
	  on o.CustomerID = c.CustomerID
	 and o.EmployeeID = 4
   where o.CustomerID is null


-----------------------
-- ADVANCED PROBLEMS --
-----------------------


-- 32
-- pedidos (individuais) com valor total de 10.000 ou mais
  select c.CustomerID,
         c.CompanyName,
		 o.OrderID,
		 sum(( od.Quantity * od.UnitPrice )) as TotalPrice
    from Orders o
	join Customers c
	  on c.CustomerID = o.CustomerID
	join [Order Details] od
	  on od.OrderID = o.OrderID
   where year(o.OrderDate) = 1998
group by c.CustomerID, c.CompanyName, o.OrderID
  having sum(( od.Quantity * od.UnitPrice )) >= 10000
order by TotalPrice desc

-- 33
  select c.CustomerID,
         c.CompanyName,
		 sum(( od.Quantity * od.UnitPrice )) as TotalPrice
    from Orders o
	join Customers c
	  on c.CustomerID = o.CustomerID
	join [Order Details] od
	  on od.OrderID = o.OrderID
   where year(o.OrderDate) = 1998  
group by c.CustomerID, c.CompanyName
  having sum(( od.Quantity * od.UnitPrice )) >= 15000
order by TotalPrice desc

-- 34
  select c.CustomerID,
         c.CompanyName,
		 sum(( od.Quantity * od.UnitPrice )) as TotalPrice,
		 sum(( od.Quantity * od.UnitPrice ) * ( 1 - od.Discount )) as TotalWithDiscount
    from Orders o
	join Customers c
	  on c.CustomerID = o.CustomerID
	join [Order Details] od
	  on od.OrderID = o.OrderID
   where year(o.OrderDate) = 1998  
group by c.CustomerID, c.CompanyName
  having sum(( od.Quantity * od.UnitPrice ) * ( 1 - od.Discount )) >= 10000
order by TotalWithDiscount desc

-- 35
  select EmployeeID,
         OrderID,
		 OrderDate
    from Orders
   where OrderDate = eomonth(OrderDate)
order by EmployeeID, OrderID

-- 36
  select top 10
         OrderID,
         count(*) as TotalOrder
    from [Order Details]
group by OrderID
order by TotalOrder desc

-- 37
-- sem "order by newid()" o top devolve sempre as mesmas linhas, nao uma amostra aleatoria
  select top 2 percent
         OrderID
    from Orders
order by newid()

-- 38
  select o.OrderID
    from Orders o
	join [Order Details] od
	  on od.OrderID = o.OrderID
   where od.Quantity >= 60
group by o.OrderID, od.Quantity
  having count(o.OrderID) > 1

-- 39
  ;with OrderIdCTE as
  (
	select o.OrderID
	  from Orders o
	  join [Order Details] od
	    on od.OrderID = o.OrderID
     where od.Quantity >= 60
  group by o.OrderID, od.Quantity
    having count(o.OrderID) > 1
  )
  select od.OrderID,
         od.ProductID,
		 od.Quantity,
		 od.UnitPrice,
		 od.Discount
    from Orders o
	join [Order Details] od
	  on od.OrderID = o.OrderID
   where od.OrderID in ( select OrderID from OrderIdCTE )

-- 40
  ;with OrderIdCTE as
  (
	select o.OrderID
	  from Orders o
	  join [Order Details] od
	    on od.OrderID = o.OrderID
     where od.Quantity >= 60
  group by o.OrderID, od.Quantity
    having count(o.OrderID) > 1
  )
  select distinct 
         od.OrderID,
         od.ProductID,
		 od.Quantity,
		 od.UnitPrice,
		 od.Discount
    from Orders o
	join [Order Details] od
	  on od.OrderID = o.OrderID
   where od.OrderID in ( select OrderID from OrderIdCTE )

-- 41
-- mesmo criterio de atraso usado nos problemas 42 a 47 (e no livro): RequiredDate <= ShippedDate
  select OrderID,
         OrderDate,
		 RequiredDate,
		 ShippedDate
    from Orders
   where RequiredDate <= ShippedDate

-- 42
  select o.EmployeeID,
         e.LastName,
		 count(*) as TotalLateOrders
    from Orders o
	join Employees e
	  on e.EmployeeID = o.EmployeeID
   where o.RequiredDate <= o.ShippedDate
group by o.EmployeeID,
         e.LastName
order by TotalLateOrders desc

-- 43
  ;with LateOrdersCTE as
  (
		select EmployeeID,
		       count(*) as TotalLateOrders
		  from Orders
		 where RequiredDate <= ShippedDate
	  group by EmployeeID
  ),
      AllOrdersCTE as
  (
		select EmployeeID,
		       count(*) as TotalOrders
		  from Orders
	  group by EmployeeID
  )
  select e.EmployeeID,
         e.LastName,
		 ao.TotalOrders,
		 lo.TotalLateOrders
    from Employees e
	join LateOrdersCTE lo
	  on lo.EmployeeID = e.EmployeeID
	join AllOrdersCTE ao
	  on ao.EmployeeID = e.EmployeeID

-- 44
-- left join: funcionario sem nenhum pedido atrasado continua aparecendo
  ;with LateOrdersCTE as
  (
		select EmployeeID,
		       count(*) as TotalLateOrders
		  from Orders
		 where RequiredDate <= ShippedDate
	  group by EmployeeID
  ),
      AllOrdersCTE as
  (
		select EmployeeID,
		       count(*) as TotalOrders
		  from Orders
	  group by EmployeeID
  )
  select e.EmployeeID,
         e.LastName,
		 ao.TotalOrders,
		 lo.TotalLateOrders
    from Employees e
	join AllOrdersCTE ao
	  on ao.EmployeeID = e.EmployeeID
	left join LateOrdersCTE lo
	  on lo.EmployeeID = e.EmployeeID

-- 45
  ;with LateOrdersCTE as
  (
		select EmployeeID,
		       count(*) as TotalLateOrders
		  from Orders
		 where RequiredDate <= ShippedDate
	  group by EmployeeID
  ),
      AllOrdersCTE as
  (
		select EmployeeID,
		       count(*) as TotalOrders
		  from Orders
	  group by EmployeeID
  )
  select e.EmployeeID,
         e.LastName,
		 ao.TotalOrders,
		 isnull(lo.TotalLateOrders, 0) as TotalLateOrders
    from Employees e
	join AllOrdersCTE ao
	  on ao.EmployeeID = e.EmployeeID
	left join LateOrdersCTE lo
	  on lo.EmployeeID = e.EmployeeID

-- 46
  ;with LateOrdersCTE as
  (
		select EmployeeID,
		       count(*) as TotalLateOrders
		  from Orders
		 where RequiredDate <= ShippedDate
	  group by EmployeeID
  ),
      AllOrdersCTE as
  (
		select EmployeeID,
		       count(*) as TotalOrders
		  from Orders
	  group by EmployeeID
  )
  select e.EmployeeID,
         e.LastName,
		 ao.TotalOrders,
		 isnull(lo.TotalLateOrders, 0) as TotalLateOrders,
		 (cast(isnull(lo.TotalLateOrders, 0) as float) / cast(ao.TotalOrders as float)) as PercentOrders
    from Employees e
	join AllOrdersCTE ao
	  on ao.EmployeeID = e.EmployeeID
	left join LateOrdersCTE lo
	  on lo.EmployeeID = e.EmployeeID

-- 47
  ;with LateOrdersCTE as
  (
		select EmployeeID,
		       count(*) as TotalLateOrders
		  from Orders
		 where RequiredDate <= ShippedDate
	  group by EmployeeID
  ),
      AllOrdersCTE as
  (
		select EmployeeID,
		       count(*) as TotalOrders
		  from Orders
	  group by EmployeeID
  )
  select e.EmployeeID,
         e.LastName,
		 ao.TotalOrders,
		 isnull(lo.TotalLateOrders, 0) as TotalLateOrders,
		 round((cast(isnull(lo.TotalLateOrders, 0) as float) / cast(ao.TotalOrders as float)), 2) as PercentOrders
    from Employees e
	join AllOrdersCTE ao
	  on ao.EmployeeID = e.EmployeeID
	left join LateOrdersCTE lo
	  on lo.EmployeeID = e.EmployeeID

-- 48
;with Orders1997CTE as
(
	select c.CustomerID,
	       c.CompanyName,
		   sum( od.Quantity * od.UnitPrice ) as TotalOrder
	  from Customers        c
	  join Orders           o on o.CustomerID = c.CustomerID
	  join [Order Details] od on od.OrderID   = o.OrderID
	 where year(o.OrderDate) = 1997
  group by c.CustomerID, c.CompanyName
)
	select CustomerID,
	       CompanyName,
		   TotalOrder,
		   case when TotalOrder >= 0     and TotalOrder < 1000  then 'Low'
		        when TotalOrder >= 1000  and TotalOrder < 5000  then 'Medium'
				when TotalOrder >= 5000  and TotalOrder < 10000 then 'High'
				when TotalOrder >= 10000                        then 'Very High'
		   end CustomerGroup
	  from Orders1997CTE
  order by CustomerID

-- 49
;with Orders1997CTE as
(
	select c.CustomerID,
	       c.CompanyName,
		   sum( od.Quantity * od.UnitPrice ) as TotalOrder
	  from Customers        c
	  join Orders           o on o.CustomerID = c.CustomerID
	  join [Order Details] od on od.OrderID   = o.OrderID
	 where year(o.OrderDate) = 1997
  group by c.CustomerID, c.CompanyName
)
	select CustomerID,
	       CompanyName,
		   isnull(TotalOrder, 0) as TotalOrder,
		   case when TotalOrder >= 0     and TotalOrder < 1000  then 'Low'
		        when TotalOrder >= 1000  and TotalOrder < 5000  then 'Medium'
				when TotalOrder >= 5000  and TotalOrder < 10000 then 'High'
				when TotalOrder >= 10000                        then 'Very High'
		   end CustomerGroup
	  from Orders1997CTE
  order by CustomerID

-- 50
;with Orders1997CTE as
(
	select c.CustomerID,
	       c.CompanyName,
		   sum( od.Quantity * od.UnitPrice ) as TotalOrder
	  from Customers        c
	  join Orders           o on o.CustomerID = c.CustomerID
	  join [Order Details] od on od.OrderID   = o.OrderID
	 where year(o.OrderDate) = 1997
  group by c.CustomerID, c.CompanyName
),
	QuantityGroupCTE as
(
	select CustomerID,
	       CompanyName,
		   TotalOrder,
	       case when TotalOrder >= 0     and TotalOrder < 1000  then 'Low'
		        when TotalOrder >= 1000  and TotalOrder < 5000  then 'Medium'
				when TotalOrder >= 5000  and TotalOrder < 10000 then 'High'
				when TotalOrder >= 10000                        then 'Very High'
		   end as CustomerGroup
	  from Orders1997CTE
)
	select CustomerGroup,
	       count(*)                                                            as TotalInGroup,
		   cast(count(*) as float) / ( select count(*) from QuantityGroupCTE ) as PercentageInGroup
	  from QuantityGroupCTE
  group by CustomerGroup
  order by TotalInGroup desc

-- 51
-- O livro resolve este problema com a tabela CustomerGroupThresholds, que so existe no banco do livro.
-- Aqui as faixas ficam em uma tabela temporaria equivalente, e o grupo sai de um join por intervalo.
drop table if exists #CustomerGroupThresholds
create table #CustomerGroupThresholds
(
	CustomerGroupName varchar(20),
	RangeBottom       decimal(16,5),
	RangeTop          decimal(16,5)
)

insert into #CustomerGroupThresholds
values ( 'Low',       0,     999.99999 ),
       ( 'Medium',    1000,  4999.99999 ),
       ( 'High',      5000,  9999.99999 ),
       ( 'Very High', 10000, 9999999999.99999 )

;with Orders1997CTE as
(
	select c.CustomerID,
	       c.CompanyName,
		   sum( od.Quantity * od.UnitPrice ) as TotalOrder
	  from Customers        c
	  join Orders           o on o.CustomerID = c.CustomerID
	  join [Order Details] od on od.OrderID   = o.OrderID
	 where year(o.OrderDate) = 1997
  group by c.CustomerID, c.CompanyName
)
	select o.CustomerID,
	       o.CompanyName,
		   o.TotalOrder,
		   t.CustomerGroupName
	  from Orders1997CTE o
	  join #CustomerGroupThresholds t
	    on o.TotalOrder between t.RangeBottom and t.RangeTop
  order by o.CustomerID

drop table #CustomerGroupThresholds

-- 52
	select distinct *
	  from (
	
	select Country
	  from Customers

	union

	select Country
	  from Suppliers) x

-- 53
;with CustomersCountryCTE as
(
	select distinct 
	       Country as CustomersCountry
	  from Customers 
),
	SuppliersCountryCTE as
(
	select distinct 
	       Country as SuppliersCountry
	  from Suppliers 
)
	     select s.SuppliersCountry,
		        c.CustomersCountry
	       from CustomersCountryCTE c
full outer join SuppliersCountryCTE s
			 on s.SuppliersCountry = c.CustomersCountry

-- 54
;with CustomersCountryCTE as
(
	select Country  as CustomersCountry,
	       count(*) as TotalCustomers
	  from Customers
  group by Country
),
	SuppliersCountryCTE as
(
	select Country  as SuppliersCountry,
	       count(*) as TotalSuppliers
	  from Suppliers
  group by Country
)
	     select isnull(s.SuppliersCountry, c.CustomersCountry) as Country,
		        isnull(c.TotalCustomers, 0)                    as TotalCustomers,
				isnull(s.TotalSuppliers, 0)                    as TotalSuppliers
	       from CustomersCountryCTE c
full outer join SuppliersCountryCTE s
			 on s.SuppliersCountry = c.CustomersCountry

-- 55
;with CountryOrdersCTE as
(
	select ShipCountry,
	       CustomerID,
		   OrderID,
		   cast(OrderDate as date)													 as OrderDate,
		   row_number() over(partition by ShipCountry order by ShipCountry, OrderID) as RowNumber
	  from Orders
)
	select ShipCountry,
	       CustomerID,
		   OrderID,
		   OrderDate
	  from CountryOrdersCTE
	 where RowNumber = 1
  order by ShipCountry

-- 56
-- pedidos no mesmo dia tambem contam (0 dias de intervalo); a ordem dos pedidos vem do OrderID
	select i.CustomerID,
	       i.OrderID                               as InitialOrderID,
		   cast(i.OrderDate as date)               as InitialOrderDate,
		   n.OrderID                               as NextOrderID,
		   cast(n.OrderDate as date)               as NextOrderDate,
		   datediff(day, i.OrderDate, n.OrderDate) as DaysBetweenOrders
	  from Orders i
	  join Orders n
	    on i.CustomerID = n.CustomerID
	   and i.OrderID    < n.OrderID
	 where datediff(day, i.OrderDate, n.OrderDate) <= 5
  order by i.CustomerID, i.OrderID

-- 57
-- versao com funcao de janela: lead() traz a data do pedido seguinte do mesmo cliente, sem self join
;with NextOrderDateCTE as
(
	select CustomerID,
	       cast(OrderDate as date)                                                                         as OrderDate,
		   cast(lead(OrderDate, 1) over(partition by CustomerID order by CustomerID, OrderDate) as date) as NextOrderDate
	  from Orders
)
	select CustomerID,
	       OrderDate,
		   NextOrderDate,
		   datediff(day, OrderDate, NextOrderDate) as DaysBetweenOrders
	  from NextOrderDateCTE
	 where datediff(day, OrderDate, NextOrderDate) <= 5

