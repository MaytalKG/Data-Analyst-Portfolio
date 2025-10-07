-- Project 2 - SQL Data Analysis


-- Submitted By Maytal Koren Grodman


--1
SELECT tb2.InvoiceYear, FORMAT(tb2.IncomeYear,'#,#.00') AS IncomePerYear , tb2.NumberOfDistinctMonth,
FORMAT(tb2.YearlyLIncome,'#,#.00') AS YearlyLinearIncome,
CAST(ROUND((tb2.YearlyLIncome/(LAG(tb2.YearlyLIncome,1)OVER(ORDER BY tb2.InvoiceYear))-1)*100,2) AS MONEY) AS GrowthRate
FROM(SELECT tb1.*, tb1.IncomeYear/tb1.NumberOfDistinctMonth*12 AS YearlyLIncome
	 FROM (SELECT YEAR(si.InvoiceDate) AS InvoiceYear, 
		   SUM(sil.ExtendedPrice-sil.TaxAmount) AS IncomeYear,
		   COUNT(DISTINCT MONTH(si.InvoiceDate)) AS NumberOfDistinctMonth
		   FROM Sales.Invoices si JOIN Sales.InvoiceLines sil
		   ON si.InvoiceID=sil.InvoiceID
		   GROUP BY Year(si.InvoiceDate)) AS tb1) AS tb2
ORDER BY tb2.InvoiceYear


--2
GO

WITH tb1
AS
(SELECT YEAR(si.InvoiceDate) AS TheYear, DATEPART(Q,si.InvoiceDate) AS TheQuarter, sc.CustomerName,
SUM(sil.ExtendedPrice-sil.TaxAmount) AS IncomePerQuarterYear
FROM Sales.Customers sc JOIN Sales.Invoices si
ON sc.CustomerID=si.CustomerID
JOIN Sales.InvoiceLines sil
ON si.InvoiceID=sil.InvoiceID
GROUP BY YEAR(si.InvoiceDate), DATEPART(Q,si.InvoiceDate), sc.CustomerName),
tb2
AS
(SELECT tb1.*, DENSE_RANK()OVER(PARTITION BY tb1.TheYear, tb1.TheQuarter ORDER BY tb1.IncomePerQuarterYear DESC) AS DNR
FROM tb1)
SELECT tb2.*
FROM tb2
WHERE tb2.DNR IN (1,2,3,4,5)

GO


--3
SELECT TOP 10 wsi.StockItemID, wsi.StockItemName, SUM(sil.ExtendedPrice-sil.TaxAmount) AS TotalProfit
FROM Warehouse.StockItems wsi JOIN Sales.InvoiceLines sil
ON wsi.StockItemID=sil.StockItemID
GROUP BY wsi.StockItemID, wsi.StockItemName
ORDER BY TotalProfit DESC


--4
SELECT ROW_NUMBER()OVER(ORDER BY (wsi.RecommendedRetailPrice-wsi.UnitPrice) DESC) AS RN,
wsi.StockItemID, wsi.StockItemName, wsi.UnitPrice, wsi.RecommendedRetailPrice,
wsi.RecommendedRetailPrice-wsi.UnitPrice AS NorminalProductProfit,
DENSE_RANK()OVER(ORDER BY (wsi.RecommendedRetailPrice-wsi.UnitPrice) DESC) AS DNR
FROM Warehouse.StockItems wsi
WHERE wsi.ValidTo>GETDATE()


--5
SELECT CONCAT(ps.SupplierID, ' - ', ps.SupplierName) AS SupplierDetails, 
STRING_AGG(CONCAT(wsi.StockItemID, ' ',wsi.StockItemName, ' '),'/, ') AS ProductDetails
FROM Purchasing.Suppliers ps JOIN Warehouse.StockItems wsi
ON ps.SupplierID=wsi.SupplierID
GROUP BY ps.SupplierID, ps.SupplierName
ORDER BY ps.SupplierID


--6
GO

WITH tb1
AS
(SELECT sc.CustomerID, ac.CityName, aco.CountryName, aco.Continent, aco.Region, 
SUM(sil.ExtendedPrice) AS Total_ExtendedPrice
FROM Sales.Customers sc JOIN Application.Cities ac
ON sc.DeliveryCityID=ac.CityID
JOIN Application.StateProvinces asp
ON ac.StateProvinceID=asp.StateProvinceID
JOIN Application.Countries aco
ON asp.CountryID=aco.CountryID
JOIN Sales.Invoices si
ON sc.CustomerID=si.CustomerID
JOIN Sales.InvoiceLines sil
ON si.InvoiceID=sil.InvoiceID
GROUP BY sc.CustomerID, ac.CityName, aco.CountryName, aco.Continent, aco.Region)
SELECT TOP 5 tb1.CustomerID, tb1.CityName, tb1.CountryName, tb1.Continent, tb1.Region, 
FORMAT(tb1.Total_ExtendedPrice,'#,#.00') AS TotalExtendedPrice
FROM tb1
ORDER BY Total_ExtendedPrice DESC

GO


--7 
GO

CREATE VIEW TotalPerMonth
AS
SELECT YEAR(si.InvoiceDate) AS InvoiceYear, MONTH(si.InvoiceDate) AS InvoiceMonth, 
SUM(sil.ExtendedPrice-sil.TaxAmount) AS MTotal
FROM Sales.Invoices si JOIN Sales.InvoiceLines sil
ON si.InvoiceID=sil.InvoiceID
GROUP BY YEAR(si.InvoiceDate), MONTH(si.InvoiceDate)

GO

CREATE VIEW By_Year
AS
SELECT TotalPerMonth.InvoiceYear, CAST(TotalPerMonth.InvoiceMonth AS VARCHAR) AS InvoiceMonth, 
FORMAT(TotalPerMonth.MTotal,'#,#.00') AS MonthlyTotal,
FORMAT(
	SUM(TotalPerMonth.MTotal) 
		OVER(PARTITION BY TotalPerMonth.InvoiceYear ORDER BY TotalPerMonth.InvoiceMonth),'#,#.00') AS CumulativeTotal
FROM TotalPerMonth
UNION ALL
SELECT TotalPerMonth.InvoiceYear, 'Grand Total', FORMAT(SUM(TotalPerMonth.MTotal),'#,#.00'), 
FORMAT(SUM(TotalPerMonth.MTotal),'#,#.00')
FROM TotalPerMonth
GROUP BY TotalPerMonth.InvoiceYear

GO

SELECT By_Year.*
FROM By_Year
WHERE By_Year.InvoiceYear=2013
UNION ALL
SELECT By_Year.*
FROM By_Year
WHERE By_Year.InvoiceYear=2014
UNION ALL
SELECT By_Year.*
FROM By_Year
WHERE By_Year.InvoiceYear=2015
UNION ALL
SELECT By_Year.*
FROM By_Year
WHERE By_Year.InvoiceYear=2016

GO


--8
SELECT OrderMonth,[2013],[2014],[2015],[2016] 
FROM(SELECT so.OrderID, MONTH(so.OrderDate) AS OrderMonth, YEAR(so.OrderDate) AS OrderYear
	 FROM Sales.Orders so) AS tb1
PIVOT(COUNT(tb1.OrderID) FOR OrderYear IN ([2013],[2014],[2015],[2016])) AS PVT
ORDER BY OrderMonth


--9
GO

WITH tb1
AS
(SELECT so.CustomerID, sc.CustomerName, so.OrderDate, 
LAG(so.OrderDate,1)OVER(PARTITION BY sc.CustomerID ORDER BY so.OrderDate) AS PreviousOrderDate,
MAX(so.OrderDate)OVER(PARTITION BY sc.CustomerID) AS LastCustOrderDate, 
MAX(so.OrderDate)OVER() AS LastOrderDateAll,
ROW_NUMBER()OVER(ORDER BY so.OrderDate) AS RN
FROM Sales.Orders so JOIN Sales.Customers sc
ON so.CustomerID=sc.CustomerID),
tb2 
AS
(SELECT tb1.*,
AVG(ISNULL(DATEDIFF(dd,tb1.PreviousOrderDate,tb1.OrderDate),0))
OVER(PARTITION BY tb1.CustomerID)
AS AvgDaysBetweenOrders,
DATEDIFF(dd,tb1.LastCustOrderDate,tb1.LastOrderDateAll) AS DaysSinceLastOrder
FROM tb1
GROUP BY tb1.CustomerID, tb1.CustomerName, tb1.OrderDate, tb1.PreviousOrderDate, tb1.LastCustOrderDate,
tb1.LastOrderDateAll, tb1.RN)
SELECT tb2.CustomerID, tb2.CustomerName, tb2.OrderDate, tb2.PreviousOrderDate, tb2.AvgDaysBetweenOrders,
tb2.LastCustOrderDate, tb2.LastOrderDateAll, tb2.DaysSinceLastOrder,
CASE WHEN tb2.DaysSinceLastOrder>2*tb2.AvgDaysBetweenOrders	THEN 'Potential Churn'
	 ELSE 'Active'
	 END AS CustomerStatus
FROM tb2

GO


--10
GO

WITH tb1
AS
(SELECT DISTINCT scu.CustomerCategoryID, 
				 CASE WHEN scu.CustomerName LIKE '%Tailspin%' THEN 'Tailspin'
					  WHEN scu.CustomerName LIKE '%Wingtip%' THEN 'Wingtip'
				 ELSE scu.CustomerName
				 END AS DistinctCustName
FROM Sales.Customers scu),
tb2
AS
(SELECT DISTINCT scc.CustomerCategoryName, 
		CAST(COUNT(tb1.DistinctCustName)OVER(PARTITION BY tb1.CustomerCategoryID) AS FLOAT) AS CustomerCOUNT,
		CAST(COUNT(tb1.DistinctCustName)OVER() AS FLOAT) AS TotalCustCount
FROM tb1 JOIN Sales.CustomerCategories scc
ON tb1.CustomerCategoryID=scc.CustomerCategoryID
GROUP BY scc.CustomerCategoryName, tb1.CustomerCategoryID, tb1.DistinctCustName)
SELECT tb2.*, FORMAT(tb2.CustomerCOUNT/tb2.TotalCustCount,'#,#.00%') AS DistributionFactor
FROM tb2

GO


