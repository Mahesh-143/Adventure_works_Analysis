create database adventure_details;
use  adventure_details;
select * from dimcustomer;
select * from dimdate;
select * from dimproduct;
select * from dimproductcategory;
select * from dimproductsubcategory;
select * from dimsalesterritory;
select * from fact_internet_sales_new;
select * from factinternetsales;
desc fact_internet_sales_new;
desc factinternetsales;
SELECT *
FROM FactInternetSales
LIMIT 5;
SELECT *
FROM Fact_Internet_Sales_New
LIMIT 5;

-- q0

CREATE TABLE Sales AS
SELECT *
FROM FactInternetSales
UNION ALL
SELECT *
FROM Fact_Internet_Sales_New;
DESCRIBE Sales;

ALTER TABLE DimProduct ADD PRIMARY KEY (ProductKey);
ALTER TABLE Sales ADD CONSTRAINT fk_sales_product FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey);
ALTER TABLE DimCustomer ADD PRIMARY KEY (CustomerKey);
ALTER TABLE Sales ADD CONSTRAINT fk_sales_customer FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey);
ALTER TABLE DimDate ADD PRIMARY KEY (DateKey);
ALTER TABLE Sales ADD CONSTRAINT fk_sales_date FOREIGN KEY (OrderDateKey) REFERENCES DimDate(DateKey);
ALTER TABLE DimSalesTerritory ADD PRIMARY KEY (SalesTerritoryKey);
ALTER TABLE Sales ADD CONSTRAINT fk_sales_territory FOREIGN KEY (SalesTerritoryKey) REFERENCES DimSalesTerritory(SalesTerritoryKey);

desc dimproduct;
desc dimproductcategory;
desc dimproductsubcategory;

CREATE TABLE DimProductMerged AS
SELECT
    p.ProductKey,
    p.`Unit price`,
    p.ProductAlternateKey,
    p.ProductSubcategoryKey,
    p.EnglishProductName AS ProductName,
    p.StandardCost,
    p.Color,
    p.Size,
    ps.EnglishProductSubcategoryName AS ProductSubcategory,
    pc.EnglishProductCategoryName AS ProductCategory
FROM DimProduct p
LEFT JOIN DimProductSubCategory ps
    ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
LEFT JOIN DimProductCategory pc
    ON ps.ProductCategoryKey = pc.ProductCategoryKey;
    
    SELECT COUNT(*) AS TotalProducts
FROM DimProductMerged;

desc DimProductMerged;

SELECT ProductKey, COUNT(*) AS cnt
FROM DimProductMerged
GROUP BY ProductKey
HAVING COUNT(*) > 1;

ALTER TABLE DimProductMerged ADD PRIMARY KEY (ProductKey);
ALTER TABLE Sales
DROP FOREIGN KEY fk_sales_product;

ALTER TABLE Sales
ADD CONSTRAINT fk_sales_productmerged
FOREIGN KEY (ProductKey)
REFERENCES DimProductMerged(ProductKey);

-- q1
SELECT
    s.SalesOrderNumber,
    s.SalesOrderLineNumber,
    s.ProductKey,
    p.ProductName
FROM Sales s
LEFT JOIN DimProductMerged p
    ON s.ProductKey = p.ProductKey
order by s.productkey asc;
    
    -- q2
    SELECT
    s.SalesOrderNumber,
    s.SalesOrderLineNumber,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerFullName,
    p.`Unit price` AS UnitPrice
FROM Sales s
LEFT JOIN DimProductMerged p
    ON s.ProductKey = p.ProductKey
LEFT JOIN DimCustomer c
    ON s.CustomerKey = c.CustomerKey;
    
    -- q3
    SELECT
    s.SalesOrderNumber,
    s.SalesOrderLineNumber,
    s.OrderDateKey,
    STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d') AS OrderDate
FROM Sales s;

-- q3(a)
SELECT
    s.SalesOrderNumber,
    s.SalesOrderLineNumber,
    STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d') AS OrderDate,
    YEAR(STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d')) AS Year
FROM Sales s;

-- q3(b)
SELECT
    s.SalesOrderNumber,
    s.SalesOrderLineNumber,
    STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d') AS OrderDate,
    MONTH(STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d')) AS MonthNo
FROM Sales s;

-- q3(c)
SELECT
    s.SalesOrderNumber,
    s.SalesOrderLineNumber,
    STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d') AS OrderDate,
    MONTHNAME(
        STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d')
    ) AS MonthName
FROM Sales s;

-- q3(d)
SELECT
    s.SalesOrderNumber,
    s.SalesOrderLineNumber,
    STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d') AS OrderDate,
    CONCAT(
        'Q',
        QUARTER(
            STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d')
        )
    ) AS Quarter
FROM Sales s;

-- q3(e)
SELECT
    s.SalesOrderNumber,
    s.SalesOrderLineNumber,
    STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d') AS OrderDate,
    DATE_FORMAT(
        STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d'),
        '%Y-%b'
    ) AS YearMonth
FROM Sales s;

-- q3(f)
SELECT
    s.SalesOrderNumber,
    s.SalesOrderLineNumber,
    STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d') AS OrderDate,
    WEEKDAY(
        STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d')
    ) AS Weekday
FROM Sales s;
    
    -- q3(g)
SELECT
    s.SalesOrderNumber,
    s.SalesOrderLineNumber,
    STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d') AS OrderDate,
    DAYNAME(
        STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d')
    ) AS WeekdayName
FROM Sales s;

-- q3(h)
SELECT
    s.SalesOrderNumber,
    s.SalesOrderLineNumber,
    STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d') AS OrderDate,

    CASE
        WHEN MONTH(STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d')) >= 7
            THEN MONTH(STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d')) - 6
        ELSE MONTH(STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d')) + 6
    END AS FinancialMonth

FROM Sales s;

-- q3(i)
SELECT
    s.SalesOrderNumber,
    s.SalesOrderLineNumber,
    STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d') AS OrderDate,

    CONCAT(
        'Q',
        CASE
            WHEN MONTH(STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d')) BETWEEN 7 AND 9 THEN 1
            WHEN MONTH(STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d')) BETWEEN 10 AND 12 THEN 2
            WHEN MONTH(STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d')) BETWEEN 1 AND 3 THEN 3
            WHEN MONTH(STR_TO_DATE(CAST(s.OrderDateKey AS CHAR), '%Y%m%d')) BETWEEN 4 AND 6 THEN 4
        END
    ) AS FinancialQuarter

FROM Sales s;

-- q4
desc sales;

SELECT
    SalesOrderNumber,
    SalesOrderLineNumber,
    UnitPrice,
    OrderQuantity,
    UnitPriceDiscountPct,
    ROUND(
        UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct / 100),
        2
    ) AS SalesAmount
FROM Sales;

-- q5
SELECT
    SalesOrderNumber,
    SalesOrderLineNumber,
    ProductStandardCost AS UnitCost,
    OrderQuantity,
    ROUND(ProductStandardCost * OrderQuantity, 2) AS ProductionCost
FROM Sales;

-- q6
SELECT
    SalesOrderNumber,
    SalesOrderLineNumber,
    ROUND(
        (UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct / 100))
        - (ProductStandardCost * OrderQuantity),
        2
    ) AS Profit
FROM Sales;