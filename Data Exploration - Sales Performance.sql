/*

Sales Performance Data Exploration (PostgreSQL)

*/ 



--- Select Data that we are going to be starting with

SELECT 
    SalesOrderNumber,
    OrderDate,
    ProductKey,
    EmployeeKey,
	SalesTerritoryKey,
    Quantity,
    UnitPrice,
    Sales,
    Cost
FROM 
    sales
ORDER BY OrderDate ASC;



--- Monthly Yearly Sales and Profit Analysis 

WITH MonthlyProfitability AS (
    SELECT
        EXTRACT(YEAR FROM OrderDate) AS Year,
        EXTRACT(MONTH FROM OrderDate) AS Month,
        SUM(Sales) AS TotalSales,
        SUM(Cost) AS TotalCost,
        ROUND(SUM((Sales - Cost) / Sales) * 100, 2) AS ProfitPercentage,
        ROUND(AVG((Sales - Cost) / Sales) * 100, 2) AS AvgProfitPercentage
    FROM
        sales
    WHERE
        EXTRACT(YEAR FROM OrderDate) BETWEEN 2017 AND 2020
    GROUP BY
        EXTRACT(YEAR FROM OrderDate),
        EXTRACT(MONTH FROM OrderDate)
    ORDER BY
        Year, Month
)

SELECT
    Year,
    Month,
    TotalSales,
    TotalCost,
    ProfitPercentage,
    AvgProfitPercentage
FROM
    MonthlyProfitability
ORDER BY
    Year, Month;
	
	
	
--- Yearly Sales and Profit Analysis 

SELECT
    EXTRACT(YEAR FROM OrderDate) AS Year,
    SUM(Sales) AS TotalSales,
    SUM(Cost) AS TotalCost,
    SUM(Quantity) AS TotalQuantity,
    ROUND(SUM((Sales - Cost) / Sales) * 100, 2) AS ProfitPercentage,
    ROUND(AVG((Sales - Cost) / Sales) * 100, 2) AS AvgProfitPercentage
FROM
    sales
WHERE
    EXTRACT(YEAR FROM OrderDate) BETWEEN 2017 AND 2020
GROUP BY
    EXTRACT(YEAR FROM OrderDate)
ORDER BY
    Year;

	
	
	
--- Yearly and Monthly Sales Performance by Region

SELECT
    EXTRACT(YEAR FROM s.OrderDate) AS OrderYear,
	TO_CHAR(s.OrderDate, 'Month') AS OrderMonth,
	r.Country,
    r.RegionName,
    SUM(s.Quantity) AS TotalQuantity,
    SUM(s.Sales) AS TotalSales,
    ROUND(AVG((s.Sales - s.Cost) / s.Sales) * 100, 2) AS ProfitPercentage
FROM
    sales s
FULL JOIN
    region r ON s.SalesTerritoryKey = r.SalesTerritoryKey
GROUP BY
    r.Country, r.RegionName, OrderMonth, OrderYear
ORDER BY
    OrderYear, OrderMonth;

	
	
	
-- Sales Contribution Analysis: Top Products
	
SELECT
    s.ProductKey,
    p.ProductName,
    p.SubCategory,
    p.Category,
    SUM(s.Sales) AS TotalSales,
    ROUND((SUM(s.Sales) / NULLIF((SELECT SUM(Sales) FROM sales), 0)) * 100, 2) AS SalesContributionPercentage
FROM
    sales s
FULL JOIN
    product p ON s.ProductKey = p.ProductKey
WHERE
    s.ProductKey IS NOT NULL AND s.Sales IS NOT NULL
GROUP BY
    s.ProductKey, p.ProductName, p.Category, p.SubCategory
HAVING
    ROUND((SUM(s.Sales) / NULLIF((SELECT SUM(Sales) FROM sales), 0)) * 100, 2) > 0
ORDER BY
    TotalSales DESC;
	
	
	
--- Top Resellers by Sales

SELECT
    ResellerKey,
    SUM(Quantity) AS TotalQuantity,
    SUM(Sales) AS TotalSales
FROM
    sales
GROUP BY
    ResellerKey
ORDER BY
    TotalSales DESC;
	
	
	
--- Salesperson Performance Overview

SELECT
    sp.SalespersonName,
    sp.Title,
    s.EmployeeKey,
    SUM(s.Quantity) AS TotalQuantity,
    SUM(s.Sales) AS TotalSales,
    ROUND((SUM(s.Sales) / (SELECT SUM(Sales) FROM sales)) * 100, 2) AS SalesContributionPercentage,
    sp.Email
FROM
    sales s
FULL JOIN
    salesperson sp ON s.EmployeeKey = sp.EmployeeKey
WHERE
    s.EmployeeKey IS NOT NULL
GROUP BY
    s.EmployeeKey, sp.SalespersonName, sp.Email, sp.Title  -- Added sp.Title to the GROUP BY
ORDER BY
    TotalQuantity DESC;


	
	
	
--- Total Sales, Cost, and Profit by Country

SELECT
    r.Country,
    SUM(s.Sales) AS TotalSales,
    SUM(s.Cost) AS TotalCost,
	SUM(s.Sales - s.Cost) AS TotalProfit,
    ROUND(AVG(s.Cost), 2) AS AverageCost,
    ROUND(AVG(s.Sales - s.Cost), 2) AS AverageProfit
FROM
    sales s
FULL JOIN
    region r ON s.SalesTerritoryKey = r.SalesTerritoryKey
GROUP BY
    r.Country
ORDER BY
    TotalProfit DESC;
	
	
	
--- Monthly Quantity Statistics by Category

SELECT
    EXTRACT(YEAR FROM s.OrderDate) AS OrderYear,
    TO_CHAR(s.OrderDate, 'Month') AS OrderMonth,
    p.Category,
	COUNT(s.Quantity) AS QuantityCount,
    SUM(s.Quantity) AS TotalQuantity
FROM
    sales s
FULL JOIN
    product p ON s.ProductKey = p.ProductKey
GROUP BY
    OrderYear, OrderMonth, p.Category
ORDER BY
    OrderYear, OrderMonth, TotalQuantity DESC;
	
	
	
--- Top Monthly Sales Categories

WITH MonthlySales AS (
    SELECT
        EXTRACT(YEAR FROM s.OrderDate) AS OrderYear,
        TO_CHAR(s.OrderDate, 'Month') AS OrderMonth,
        p.Category,
        SUM(s.Quantity) AS TotalQuantity,
        ROW_NUMBER() OVER (PARTITION BY EXTRACT(YEAR FROM s.OrderDate), TO_CHAR(s.OrderDate, 'Month') ORDER BY SUM(s.Quantity) DESC) AS rn
    FROM
        sales s
    FULL JOIN
        product p ON s.ProductKey = p.ProductKey
    GROUP BY
        OrderYear, OrderMonth, p.Category
)

SELECT
    OrderYear,
    OrderMonth,
    Category,
    TotalQuantity
FROM
    MonthlySales
WHERE
    rn = 1 AND OrderYear IS NOT NULL
ORDER BY
    OrderYear, OrderMonth;
	
	
--- Price and Profit Margin Analysis

SELECT
    p.ProductKey,
    p.ProductName,
    p.Category,
    p.SubCategory,
    ROUND(AVG(s.UnitPrice), 2) AS AvgUnitPrice,
    ROUND(AVG(s.Sales - s.Cost), 2) AS AvgProfitMargin
FROM
    sales s
JOIN
    product p ON s.ProductKey = p.ProductKey
WHERE
    s.Sales IS NOT NULL AND s.Cost IS NOT NULL
GROUP BY
    p.ProductKey, p.ProductName, p.Category, p.SubCategory
ORDER BY
    AvgProfitMargin DESC;
	
	
	
--- Order Time Pattern (Order Date)

SELECT
    EXTRACT(YEAR FROM OrderDate) AS OrderYear,
    EXTRACT(MONTH FROM OrderDate) AS OrderMonth,
    TO_CHAR(OrderDate, 'Month') AS MonthName,
    COUNT(DISTINCT SalesOrderNumber) AS UniqueOrders
FROM
    sales
GROUP BY
    OrderYear, OrderMonth, MonthName
ORDER BY
    OrderYear, OrderMonth;
	
	
--- Analysis of Order Quantity Based on Product Name

SELECT
    p.ProductName,
    COUNT(DISTINCT SalesOrderNumber) AS OrderCount
FROM
    sales s
JOIN
    product p ON s.ProductKey = p.ProductKey
GROUP BY
    p.ProductName
ORDER BY
    OrderCount DESC;
	
	
	
--- Top Color Analysis by Region

WITH ColorOrderCounts AS (
    SELECT
        r.RegionName AS Region,
        r.RegionGroup,
        p.Color,
        COUNT(p.Color) AS OrderCount,
        ROW_NUMBER() OVER (PARTITION BY r.RegionName ORDER BY COUNT(p.Color) DESC) AS ColorRank
    FROM
        sales s
    JOIN
        product p ON s.ProductKey = p.ProductKey
    JOIN
        region r ON s.SalesTerritoryKey = r.SalesTerritoryKey
    WHERE
        p.Color IS NOT NULL
    GROUP BY
        r.RegionName, r.RegionGroup, p.Color
)
SELECT
    Region,
	RegionGroup,
    Color,
    OrderCount
FROM
    ColorOrderCounts
WHERE
    ColorRank = 1;
	
	
	
--- Salesperson Ranking by Region

WITH SalespersonRanking AS (
    SELECT
        r.RegionName,
        sp.SalespersonName,
        SUM(s.Sales) AS TotalSales,
        ROW_NUMBER() OVER (PARTITION BY r.RegionName ORDER BY SUM(s.Sales) DESC) AS SalesRank
    FROM
        sales s
    JOIN
        salesperson sp ON s.EmployeeKey = sp.EmployeeKey
    JOIN
        region r ON s.SalesTerritoryKey = r.SalesTerritoryKey
    GROUP BY
        r.RegionName, sp.SalespersonName
)
SELECT
    RegionName,
    SalespersonName,
    TotalSales
FROM
    SalespersonRanking
WHERE
    SalesRank = 1;
	
	
	
--- Average Unit Price Analysis by Region

SELECT
    r.RegionName,
    ROUND(AVG(s.UnitPrice), 2) AS AverageUnitPrice,
    ROUND(AVG(s.Cost), 2) AS AverageCost
FROM
    sales s
JOIN
    region r ON s.SalesTerritoryKey = r.SalesTerritoryKey
GROUP BY
    r.RegionName
ORDER BY
    AverageUnitPrice, AverageUnitPrice;
	
	
	
--- Final for Data Visualization




SELECT
    s.OrderDate,
    p.ProductName,
    s.Quantity,
    s.UnitPrice,
    s.Sales,
    s.Cost,
    p.Color,
    p.Subcategory,
    p.Category,
    r.RegionName,
    r.RegionGroup,
    sp.SalesPersonName,
    sp.Title,
    sp.Email
FROM
    sales s
FULL JOIN product p ON s.ProductKey = p.ProductKey
FULL JOIN salesperson sp ON s.EmployeeKey = sp.EmployeeKey
FULL JOIN region r ON s.SalesTerritoryKey = r.SalesTerritoryKey
WHERE
    s.OrderDate IS NOT NULL
    AND p.ProductName IS NOT NULL
    AND s.Quantity IS NOT NULL
    AND s.UnitPrice IS NOT NULL
    AND s.Sales IS NOT NULL
    AND s.Cost IS NOT NULL
    AND p.Color IS NOT NULL
    AND p.Subcategory IS NOT NULL
    AND p.Category IS NOT NULL
    AND r.RegionName IS NOT NULL
    AND r.RegionGroup IS NOT NULL
    AND sp.SalesPersonName IS NOT NULL
    AND sp.Title IS NOT NULL
    AND sp.Email IS NOT NULL
ORDER BY
    s.OrderDate;
