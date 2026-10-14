-- ============================================================================
-- DATA ANALYST COURSE — WEEK 2: SQL FOR DATA ANALYSIS
-- Dataset: Awesome Chocolates Database (MySQL / SQLite Compatible)
-- Database Tables: sales, people, products, geo
-- ============================================================================

-- ============================================================================
-- SECTION 1: BASIC QUERIES & FILTERING (SELECT, WHERE, ORDER BY, LIMIT)
-- ============================================================================

-- 1.1 Select all columns from sales table (Limited to first 10 records)
SELECT * 
FROM sales 
LIMIT 10;

-- 1.2 Select specific operational columns with field aliasing
SELECT 
    SaleDate, 
    Amount, 
    Customers, 
    Boxes, 
    GeoID 
FROM sales 
LIMIT 10;

-- 1.3 Computed columns: Calculate Amount per Box
SELECT 
    SaleDate, 
    Amount, 
    Boxes, 
    ROUND(Amount / Boxes, 2) AS Amount_Per_Box 
FROM sales 
WHERE Boxes > 0 
LIMIT 10;

-- 1.4 WHERE clause: High-value shipments (> $10,000) ordered by Amount descending
SELECT 
    SaleDate, 
    SPID, 
    PID, 
    Amount, 
    Boxes 
FROM sales 
WHERE Amount > 10000 
ORDER BY Amount DESC 
LIMIT 10;

-- 1.5 Date & Year Filtering: Shipments in year 2022 with amount > $10,000
SELECT 
    SaleDate, 
    Amount, 
    Boxes 
FROM sales 
WHERE Amount > 10000 
  AND SaleDate >= '2022-01-01' 
  AND SaleDate <= '2022-12-31'
ORDER BY Amount DESC 
LIMIT 10;

-- 1.6 BETWEEN Operator: Shipments with boxes between 50 and 100
SELECT 
    SaleDate, 
    Amount, 
    Boxes 
FROM sales 
WHERE Boxes BETWEEN 50 AND 100 
ORDER BY Boxes ASC 
LIMIT 10;

-- ============================================================================
-- SECTION 2: MULTI-TABLE JOINS (INNER, LEFT JOIN)
-- ============================================================================

-- 2.1 Complete Relational Join: Sales + Salesperson + Product + Geography
SELECT 
    s.SaleDate,
    s.Amount,
    s.Boxes,
    s.Customers,
    p.Salesperson,
    p.Team,
    pr.Product,
    pr.Category,
    pr.Cost_per_box,
    g.Geo AS Country,
    g.Region
FROM sales s
JOIN people p ON s.SPID = p.SPID
JOIN products pr ON s.PID = pr.PID
JOIN geo g ON s.GeoID = g.GeoID
ORDER BY s.Amount DESC
LIMIT 10;

-- 2.2 Join with Conditional Filtering: Delish team sales in India
SELECT 
    s.SaleDate,
    p.Salesperson,
    p.Team,
    pr.Product,
    g.Geo AS Country,
    s.Amount
FROM sales s
JOIN people p ON s.SPID = p.SPID
JOIN products pr ON s.PID = pr.PID
JOIN geo g ON s.GeoID = g.GeoID
WHERE p.Team = 'Delish' AND g.Geo = 'India'
ORDER BY s.Amount DESC
LIMIT 10;

-- ============================================================================
-- SECTION 3: CONDITIONAL LOGIC (CASE STATEMENTS)
-- ============================================================================

-- 3.1 Categorizing Transaction Amounts into Tiers
SELECT 
    SaleDate,
    Amount,
    CASE 
        WHEN Amount < 1000 THEN 'Under 1k'
        WHEN Amount < 5000 THEN 'Under 5k'
        WHEN Amount < 10000 THEN 'Under 10k'
        ELSE '10k or more'
    END AS Amount_Category,
    Boxes
FROM sales
LIMIT 15;

-- 3.2 Volume Classification using CASE
SELECT 
    SaleDate,
    Boxes,
    CASE 
        WHEN Boxes >= 1000 THEN 'High Volume (1000+)'
        WHEN Boxes >= 500 THEN 'Medium Volume (500-999)'
        ELSE 'Standard Volume (<500)'
    END AS Shipment_Volume_Tier,
    Amount
FROM sales
ORDER BY Boxes DESC
LIMIT 15;

-- ============================================================================
-- SECTION 4: CORE ASSIGNMENT — TOP CUSTOMERS & AVERAGE ORDER VALUES
-- ============================================================================

-- 4.1 Top Salespersons (Customers/Reps) by Total Revenue & Performance
SELECT 
    p.Salesperson,
    p.Team,
    p.Location,
    COUNT(*) AS Total_Orders,
    SUM(s.Boxes) AS Total_Boxes_Sold,
    ROUND(SUM(s.Amount), 2) AS Total_Revenue,
    ROUND(AVG(s.Amount), 2) AS Average_Order_Value,
    ROUND(SUM(s.Amount) / SUM(s.Boxes), 2) AS Revenue_Per_Box
FROM sales s
JOIN people p ON s.SPID = p.SPID
GROUP BY p.Salesperson, p.Team, p.Location
ORDER BY Total_Revenue DESC
LIMIT 10;

-- 4.2 Overall Global Average Order Value (AOV) Metrics
SELECT 
    COUNT(*) AS Total_Shipments,
    ROUND(SUM(Amount), 2) AS Global_Revenue,
    ROUND(AVG(Amount), 2) AS Average_Order_Value_Per_Shipment,
    ROUND(SUM(Amount) / SUM(Customers), 2) AS Average_Value_Per_Customer,
    ROUND(AVG(Boxes), 2) AS Average_Boxes_Per_Order
FROM sales;

-- 4.3 Average Order Value by Country / Market
SELECT 
    g.Geo AS Country,
    g.Region,
    COUNT(*) AS Total_Shipments,
    ROUND(SUM(s.Amount), 2) AS Total_Revenue,
    ROUND(AVG(s.Amount), 2) AS Average_Order_Value
FROM sales s
JOIN geo g ON s.GeoID = g.GeoID
GROUP BY g.Geo, g.Region
ORDER BY Total_Revenue DESC;

-- 4.4 Average Order Value by Product Category
SELECT 
    pr.Category,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(s.Amount), 2) AS Total_Revenue,
    ROUND(AVG(s.Amount), 2) AS Average_Order_Value,
    ROUND(SUM(s.Amount) * 100.0 / (SELECT SUM(Amount) FROM sales), 2) AS Revenue_Share_Pct
FROM sales s
JOIN products pr ON s.PID = pr.PID
GROUP BY pr.Category
ORDER BY Total_Revenue DESC;

-- ============================================================================
-- SECTION 5: PRACTICE PROBLEMS (TUTORIAL HOMEWORK CHALLENGES)
-- ============================================================================

-- Problem 1 (Intermediate): Print details of shipments where amount > $2,000 and boxes < 100
SELECT 
    SaleDate, 
    Amount, 
    Boxes, 
    Customers 
FROM sales 
WHERE Amount > 2000 AND Boxes < 100 
ORDER BY Amount DESC;

-- Problem 2 (Intermediate): How many shipments each salesperson had in January 2022
SELECT 
    p.Salesperson, 
    COUNT(*) AS January_2022_Shipments
FROM sales s
JOIN people p ON s.SPID = p.SPID
WHERE s.SaleDate >= '2022-01-01' AND s.SaleDate <= '2022-01-31'
GROUP BY p.Salesperson
ORDER BY January_2022_Shipments DESC;

-- Problem 3 (Intermediate): Which product sells more boxes? Milk Bars or Eclairs?
SELECT 
    pr.Product, 
    SUM(s.Boxes) AS Total_Boxes_Sold,
    ROUND(SUM(s.Amount), 2) AS Total_Revenue
FROM sales s
JOIN products pr ON s.PID = pr.PID
WHERE pr.Product IN ('Milk Bars', 'Eclairs')
GROUP BY pr.Product
ORDER BY Total_Boxes_Sold DESC;

-- Problem 4 (Intermediate): Which product sold more boxes in the first 7 days of February 2022?
SELECT 
    pr.Product, 
    SUM(s.Boxes) AS Total_Boxes_Sold,
    ROUND(SUM(s.Amount), 2) AS Total_Revenue
FROM sales s
JOIN products pr ON s.PID = pr.PID
WHERE pr.Product IN ('Milk Bars', 'Eclairs')
  AND s.SaleDate >= '2022-02-01' AND s.SaleDate <= '2022-02-07'
GROUP BY pr.Product
ORDER BY Total_Boxes_Sold DESC;

-- Problem 5 (Intermediate): Shipments with under 100 customers and under 100 boxes, identifying Wednesday shipments
SELECT 
    SaleDate, 
    Amount, 
    Customers, 
    Boxes,
    CASE 
        WHEN strftime('%w', SaleDate) = '3' THEN 'Yes (Wednesday)'
        ELSE 'No'
    END AS Is_Wednesday
FROM sales
WHERE Customers < 100 AND Boxes < 100
ORDER BY SaleDate ASC
LIMIT 15;

-- Problem 6 (Hard): Salespersons with at least 1 shipment in first 7 days of January 2022
SELECT DISTINCT 
    p.Salesperson,
    p.Team,
    p.Location
FROM sales s
JOIN people p ON s.SPID = p.SPID
WHERE s.SaleDate >= '2022-01-01' AND s.SaleDate <= '2022-01-07'
ORDER BY p.Salesperson ASC;

-- Problem 7 (Hard): Salespersons who did NOT make any shipments in first 7 days of January 2022
SELECT 
    p.Salesperson, 
    p.Team, 
    p.Location
FROM people p
WHERE p.SPID NOT IN (
    SELECT DISTINCT s.SPID 
    FROM sales s 
    WHERE s.SaleDate >= '2022-01-01' AND s.SaleDate <= '2022-01-07'
)
ORDER BY p.Salesperson ASC;

-- Problem 8 (Hard): How many times we shipped more than 1,000 boxes in each month
SELECT 
    strftime('%Y-%m', SaleDate) AS Year_Month,
    COUNT(*) AS Shipments_Over_1000_Boxes
FROM sales
WHERE Boxes > 1000
GROUP BY strftime('%Y-%m', SaleDate)
ORDER BY Year_Month ASC;

-- Problem 9 (Hard): Monthly shipment status of 'After Nines' to 'New Zealand'
SELECT 
    strftime('%Y-%m', s.SaleDate) AS Year_Month,
    SUM(s.Boxes) AS Total_Boxes,
    CASE 
        WHEN SUM(s.Boxes) > 0 THEN 'Yes' 
        ELSE 'No' 
    END AS Shipped_Status
FROM sales s
JOIN products pr ON s.PID = pr.PID
JOIN geo g ON s.GeoID = g.GeoID
WHERE pr.Product = 'After Nines' AND g.Geo = 'New Zealand'
GROUP BY strftime('%Y-%m', s.SaleDate)
ORDER BY Year_Month ASC;

-- Problem 10 (Hard): India vs Australia — Who buys more chocolate boxes on a monthly basis?
SELECT 
    strftime('%Y-%m', s.SaleDate) AS Year_Month,
    SUM(CASE WHEN g.Geo = 'India' THEN s.Boxes ELSE 0 END) AS India_Boxes,
    SUM(CASE WHEN g.Geo = 'Australia' THEN s.Boxes ELSE 0 END) AS Australia_Boxes,
    CASE 
        WHEN SUM(CASE WHEN g.Geo = 'India' THEN s.Boxes ELSE 0 END) > SUM(CASE WHEN g.Geo = 'Australia' THEN s.Boxes ELSE 0 END) THEN 'India'
        ELSE 'Australia'
    END AS Leading_Market
FROM sales s
JOIN geo g ON s.GeoID = g.GeoID
GROUP BY strftime('%Y-%m', s.SaleDate)
ORDER BY Year_Month ASC;
