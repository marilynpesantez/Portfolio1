-- 0A. Create table with the following datatypes
CREATE TABLE online_retail
(
InvoiceNo VARCHAR(255),
StockCode VARCHAR(255),
Item VARCHAR(255),
Quantity INT,
InvoiceDate DATETIME,
UnitPrice DOUBLE,
CustomerID VARCHAR(255),
Country VARCHAR(255)
);

-- 0B. Enable local infile 
SHOW VARIABLES LIKE 'local_infile'
SET GLOBAL local_infile = 'ON'

-- 0C. Load 2009-2010 data into online_retail table
LOAD DATA LOCAL INFILE '/Users/marilynpesantez/Downloads/Portfolio_1/Data/online_retail_IIA.csv'
INTO TABLE online_retail
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

-- 0D. Load 2010-2011 data into online_retail table
LOAD DATA LOCAL INFILE '/Users/marilynpesantez/Downloads/Portfolio_1/Data/online_retail_IIB.csv'
INTO TABLE online_retail
FIELDS TERMINATED BY ','
IGNORE 1 LINES;
------------------------------------------------------------------------------------------------------------------------------------------------
-- 1. Look for duplicated transactions
WITH CTE AS 
(
SELECT online_retail.*,
	   ROW_NUMBER() OVER (PARTITION BY InvoiceNo, StockCode, Item, Quantity, InvoiceDate, UnitPrice, CustomerID, Country ORDER BY (SELECT NULL)) AS row_num
FROM online_retail
)
SELECT *
FROM CTE
WHERE row_num > 1
ORDER BY row_num DESC
-- 34,336 rows returned
-- Exclude from views used for analysis
------------------------------------------------------------------------------------------------------------------------------------------------
-- 2. Look for empty string values
SELECT
    SUM(CASE WHEN InvoiceNo = '' OR InvoiceNo = ' ' THEN 1 ELSE 0 END) AS InvoiceNo_empty_string_count,
    SUM(CASE WHEN StockCode = '' OR StockCode = ' ' THEN 1 ELSE 0 END) AS StockCode_empty_string_count,
    SUM(CASE WHEN Item = '' OR Item = ' ' THEN 1 ELSE 0 END) AS Item_empty_string_count,
    SUM(CASE WHEN Quantity = '' OR Quantity = ' ' THEN 1 ELSE 0 END) AS Quantity_empty_string_count,
    SUM(CASE WHEN UnitPrice = '' OR UnitPrice = ' 'THEN 1 ELSE 0 END) AS UnitPrice_empty_string_count,
    SUM(CASE WHEN CustomerID = '' OR CustomerID = ' ' THEN 1 ELSE 0 END) AS CustomerID_empty_string_count,
    SUM(CASE WHEN Country = '' OR Country = ' ' THEN 1 ELSE 0 END) AS Country_empty_string_count
FROM online_retail
-- Result: 4,382 in Item column, 6,202 in UnitPrice column, and 243,007 in CustomerID column
------------------------------------------------------------------------------------------------------------------------------------------------
/* 3. Look for invalid data
		A. Investigate negative values in the Quantity column
        B. Investigate C values in InvoiceNo
     	C. Investigate negative or 0 values in the UnitPrice column
*/

-- A1. Quantity < 0
SELECT COUNT(*)
FROM online_retail
WHERE Quantity < 0;
-- 22,950 rows returned

-- A2. Quantity < 0 and UnitPrice < 0
SELECT COUNT(*)
FROM online_retail
WHERE Quantity < 0 AND UnitPrice < 0;
-- 0 rows returned

-- A3. Quantity < 0 and UnitPrice > 0
SELECT COUNT(*)
FROM online_retail
WHERE Quantity < 0 AND UnitPrice > 0;
-- 19,493 rows returned
-- All rows seem to have InvoiceNo starting with 'C'
-- These appear to be cancellations, with Quantity and UnitPrice multiplying to a negative quantity

-- A4. Quantity < 0 and UnitPrice = 0
SELECT COUNT(*)
FROM online_retail
WHERE Quantity < 0 AND UnitPrice = 0;
-- 3,457 rows returned
-- Will investigate this further in section C

------------------------------------------------------------------------------------------------------------------------------------------------
-- B1. InvoiceNo LIKE 'C%'
SELECT *
FROM online_retail
WHERE InvoiceNo LIKE 'C%';
-- 19,494 rows returned (1 more than the previous query)
-- Rows returned appear to have negative Quantity and positive UnitPrice

-- B2. InvoiceNo LIKE 'C%' and Quantity < 0 and UnitPrice > 0
SELECT *
FROM online_retail
WHERE InvoiceNo LIKE 'C%' AND Quantity < 0 AND UnitPrice > 0;
-- 19,493 rows returned
-- Confirmed: 19,493 out of 19,494 records with C InvoiceNo also have negative Quantity and positive UnitPrice
-- Assumption: Transactions with C in InvoiceNo represent cancelled transactions
-- Exclude from sales view, include in cancelled sales view.

-- B3. Look for the singular transactions where InvoiceNo LIKE 'C%' and (Quantity > 0 OR UnitPrice <= 0)
SELECT * 
FROM online_retail
WHERE InvoiceNo LIKE 'C%' and (Quantity > 0 OR UnitPrice <= 0)
-- 1 row returned
-- Confirmed: 1 cancellation with positive Quanitity
-- This could be a miscellaneous business expense that was cancelled
-- Exclude from sales, include in adjustments view

------------------------------------------------------------------------------------------------------------------------------------------------
-- C1. UnitPrice = 0
SELECT *
FROM online_retail
WHERE UnitPrice = 0
-- 6,202 rows returned
-- We know from A4 that 3,457 are accounted for by records where Quantity < 0
-- These are likely not sales. Some have customer IDs and some do not.

-- C2. Quantity > 0 and UnitPrice = 0
SELECT *
FROM online_retail
WHERE Quantity > 0 AND UnitPrice = 0
-- 2,745 rows returned
-- Some have a CustomerID value while and some do not

-- C3. Quantity > 0 and UnitPrice = 0 and CustomerID != ''
SELECT *
FROM online_retail
WHERE Quantity > 0 AND UnitPrice = 0 AND CustomerID != ''
-- 71 rows returned
-- These may represent items given away for free
-- Exclude from sale review, include in giveaway view. 

-- C4. Quantity > 0 and UnitPrice = 0 and CustomerID = ''
SELECT *
FROM online_retail
WHERE Quantity > 0 AND UnitPrice = 0 AND CustomerID = ''
-- 2,674 rows returned
-- Exclude from sale view, include in test/miscellaneaous records view

-- C5. Quantity < 0 and UnitPrice = 0
SELECT * 
FROM online_retail
WHERE Quantity < 0 AND UnitPrice = 0
-- 3,457 rows returned
-- All rows seem to have no CustomerID

-- C6. Verify that records with Quantity < 0 and UnitPrice = 0 have an empty CustomerID.
SELECT *
FROM online_retail
WHERE Quantity < 0 AND UnitPrice = 0 AND CustomerID = '';
-- 3,457 rows returned
-- Confirmed: All rows with negative Quantity and UnitPrice of zero have no CustomerId
-- Exclude from sales view, include in test/miscellaneous records view

-- C7. UnitPrice < 0
SELECT *
FROM online_retail
WHERE UnitPrice < 0
-- 5 rows returned
-- These all start with letter 'A', StockCode = 'B' for adjust bad debt, and no CustomerID
------------------------------------------------------------------------------------------------------------------------------------------------
-- D1. InvoiceNo like 'A%'
SELECT *
FROM online_retail
WHERE InvoiceNo LIKE 'A%'
-- 6 rows returned
-- 5 from previous query (UnitPrice < 0) and one with positive UnitPrice
-- All have StockCode = 'B', Quantity = 1, and no CustomerID

-- D2. StockCode = 'B'
SELECT *
FROM online_retail
WHERE StockCode = 'B';
-- 6 rows returned
-- Same rows as query from above
-- Exclude from sales, include in adjustments view
------------------------------------------------------------------------------------------------------------------------------------------------
-- SALE
SELECT *
FROM online_retail
WHERE Quantity > 0 AND UnitPrice > 0 AND StockCode <> 'B' AND InvoiceNo NOT LIKE 'C%'
-- 1,041,669 rows returned

-- (B2) CANCELLED SALES
SELECT *
FROM online_retail
WHERE Quantity < 0 AND InvoiceNo LIKE 'C%'
-- 19,493 rows returned
-- Excludes cancellation record with positive Quantity

-- (C3) GIVEAWAYS
SELECT *
FROM online_retail
WHERE Quantity > 0 AND UnitPrice = 0 AND CustomerID != ''
-- 71 rows returned
-- Of 2,745 records with positive Quantity and zero UnitPrice, 71 have a CustomerID value

-- (C4 + C6) TEST + MISC RECORDS
SELECT *
FROM online_retail
WHERE UnitPrice = 0 AND CustomerID = ''
-- 6,131 rows returned
-- Of 2,745 rows with positive Quantity and zero UnitPrice, 2,674 do not have CustomerID value
-- All 3,457 rows with negative Quantity and zero UnitPrice have no CustomerID

-- (D2 + B3) ADJUSTMENTS
SELECT *
FROM online_retail
WHERE StockCode = 'B' OR (Quantity > 0 AND InvoiceNo LIKE 'C%')
-- 7 rows returned
-- Includes adjust bad debt records and cancellation record with positive Quantity