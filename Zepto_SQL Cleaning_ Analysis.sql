/* ========================================================
   ZEPTO SQL DATA CLEANING & BUSINESS ANALYSIS
   Author: Jyotshna Janjanam
   Description:
   - Cleans and analyzes product data from Zepto
   - Identifies pricing, discount, and stock patterns
======================================================== */

/* =========================
   1. CREATE & SELECT DATABASE
   ========================= */
CREATE DATABASE IF NOT EXISTS Zepto;
USE Zepto;

/* =========================
   2. FIX ENCODING ISSUES
   ========================= */
-- Remove BOM from column name
ALTER TABLE ZEPTO_V2 CHANGE `ï»¿Category` Category VARCHAR(255);

/* =========================
   3. DATA CLEANING
   ========================= */
-- 3.1 Identify rows with NULLs in important fields
SELECT * FROM ZEPTO_V2
WHERE Category IS NULL
   OR NAME IS NULL
   OR MRP IS NULL
   OR DISCOUNTPERCENT IS NULL
   OR AVAILABLEQUANTITY IS NULL
   OR DISCOUNTEDSELLINGPRICE IS NULL
   OR WEIGHTINGMS IS NULL
   OR OUTOFSTOCK IS NULL
   OR QUANTITY IS NULL;

-- 3.2 Remove invalid price entries
DELETE FROM ZEPTO_V2
WHERE MRP = 0 OR DISCOUNTEDSELLINGPRICE = 0;

-- 3.3 Adjust values if stored in paise instead of rupees
UPDATE ZEPTO_V2
SET MRP = MRP / 100,
    DISCOUNTEDSELLINGPRICE = DISCOUNTEDSELLINGPRICE / 100
WHERE MRP > 1000; -- Only adjust if values look too large

-- 3.4 Identify inconsistent pricing (discounted price > MRP)
SELECT * FROM ZEPTO_V2
WHERE DISCOUNTEDSELLINGPRICE > MRP;

-- 3.5 Correct discount percentage calculation
UPDATE ZEPTO_V2
SET DISCOUNTPERCENT = ROUND(((MRP - DISCOUNTEDSELLINGPRICE) / MRP) * 100, 2)
WHERE MRP > 0;

/* =========================
   4. DATA EXPLORATION
   ========================= */
-- 4.1 Distinct categories
SELECT DISTINCT Category FROM ZEPTO_V2 ORDER BY Category;

-- 4.2 Stock availability summary
SELECT OUTOFSTOCK, COUNT(*) AS CountPerStatus
FROM ZEPTO_V2
GROUP BY OUTOFSTOCK;

-- 4.3 Duplicate product names
SELECT NAME, COUNT(*) AS DuplicateCount
FROM ZEPTO_V2
GROUP BY NAME
HAVING COUNT(NAME) > 1
ORDER BY DuplicateCount DESC;

/* =========================
   5. BUSINESS INSIGHTS
   ========================= */

-- 5.1 Top discounted products
SELECT DISTINCT NAME, Category, MRP, DISCOUNTPERCENT
FROM ZEPTO_V2
ORDER BY DISCOUNTPERCENT DESC
LIMIT 10;

-- 5.2 Highest proportion of out-of-stock products by category
SELECT Category, COUNT(*) AS OutOfStockCount
FROM ZEPTO_V2
WHERE OUTOFSTOCK = 'Yes' OR OUTOFSTOCK = 1
GROUP BY Category
ORDER BY OutOfStockCount DESC;

-- 5.3 High MRP products that are out of stock
SELECT DISTINCT NAME, MRP
FROM ZEPTO_V2
WHERE OUTOFSTOCK = TRUE AND MRP > 300
ORDER BY MRP DESC;

-- 5.4 Predict risk factor of stock availability
SELECT
    NAME,
    Category,
    AVAILABLEQUANTITY,
    DISCOUNTPERCENT,
    CASE
        WHEN AVAILABLEQUANTITY <= 10 AND DISCOUNTPERCENT >= 30 THEN 'High Risk'
        WHEN AVAILABLEQUANTITY <= 20 AND DISCOUNTPERCENT >= 20 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS StockoutRisk
FROM ZEPTO_V2
ORDER BY StockoutRisk DESC, AVAILABLEQUANTITY ASC;

-- 5.5 Estimate revenue for each category
SELECT Category,
       ROUND(SUM(DISCOUNTEDSELLINGPRICE * AVAILABLEQUANTITY), 2) AS TotalRevenue
FROM ZEPTO_V2
GROUP BY Category
ORDER BY TotalRevenue DESC;

-- 5.6 Highest average selling price by category
SELECT Category,
       ROUND(AVG(DISCOUNTEDSELLINGPRICE), 2) AS AvgSellingPrice
FROM ZEPTO_V2
GROUP BY Category
ORDER BY AvgSellingPrice DESC;

-- 5.7 Top categories by average discount percentage
SELECT Category,
       ROUND(AVG(DISCOUNTPERCENT), 2) AS AvgDiscount
FROM ZEPTO_V2
GROUP BY Category
ORDER BY AvgDiscount DESC
LIMIT 5;

-- 5.8 Price per gram for products over 100g
SELECT DISTINCT NAME, MRP, WEIGHTINGMS, DISCOUNTEDSELLINGPRICE,
       ROUND(DISCOUNTEDSELLINGPRICE / WEIGHTINGMS, 2) AS PricePerGram
FROM ZEPTO_V2
WHERE WEIGHTINGMS >= 100
ORDER BY PricePerGram DESC;

-- 5.9 Categorize products by weight
SELECT DISTINCT NAME, WEIGHTINGMS,
       CASE
           WHEN WEIGHTINGMS <= 1000 THEN 'LOW'
           WHEN WEIGHTINGMS <= 5000 THEN 'MEDIUM'
           ELSE 'BULK'
       END AS WeightCategory
FROM ZEPTO_V2;

-- 5.10 Total inventory weight per category
SELECT Category,
       SUM(WEIGHTINGMS * AVAILABLEQUANTITY) AS TotalWeight
FROM ZEPTO_V2
GROUP BY Category
ORDER BY TotalWeight DESC;
