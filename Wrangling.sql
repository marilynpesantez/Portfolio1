-- Add column to online_retail for store row status (sale, cancellation, giveaway, test/misc, duplicates)
ALTER TABLE online_retail
ADD row_status NVARCHAR (50)

-- Create view1 using online_retail
CREATE VIEW view1 AS
SELECT online_retail.*, 
		DATE_FORMAT(InvoiceDate, '%Y') AS Year_num,
        DATE_FORMAT(InvoiceDate, '%M') AS Month_name,
		DATE_FORMAT(InvoiceDate, '%D') AS 'Day',
        MONTH(InvoiceDate) AS Month_num,
		Quantity*UnitPrice AS total_value,
		ROW_NUMBER() OVER (PARTITION BY InvoiceNo, StockCode, Item, Quantity, InvoiceDate, UnitPrice, CustomerID, Country ORDER BY (SELECT NULL)) AS row_num
FROM online_retail

-- Create table1 using view1
CREATE TABLE table1 AS
SELECT *
FROM view1;

-- Update table1 to label duplicate records
UPDATE table1
SET row_status = 'duplicate'
WHERE row_num > 1

-- Update table1 to label sales records
UPDATE table1
SET row_status = 'sale'
WHERE row_num = 1 AND 
	(Quantity > 0 AND UnitPrice > 0 AND StockCode <> 'B' AND InvoiceNo NOT LIKE 'C%')
    
-- Update table1 to label cancelled sales records
UPDATE table1
SET row_status = 'cancellation'
WHERE row_num = 1 AND 
	(Quantity < 0 AND InvoiceNo LIKE 'C%')
    
-- Update table1 to label records for items given away for free
UPDATE table1
SET row_status = 'giveaway'
WHERE row_num = 1 AND 
	(Quantity > 0 AND UnitPrice = 0 AND CustomerID != '')
    
-- Update table 1 to label test/misc records
UPDATE table1
SET row_status = 'test_misc'
WHERE row_num = 1 AND
	(UnitPrice = 0 AND CustomerID = '')
    
-- Update table 1 to label debt adjustments
UPDATE table1
SET row_status = 'adjustments'
WHERE row_num = 1 AND
	(StockCode = 'B' OR (Quantity > 0 AND InvoiceNo LIKE 'C%'))
    
-- Verify that all records have been labeled
SELECT row_status, count(row_status) AS cnt
FROM table1
GROUP BY row_status
------------------------------------------------------------------------------------------------------------------------------------------------
-- Create sales view using table1 
CREATE VIEW sales_view AS
SELECT *
FROM table1
WHERE row_status = 'sale'

-- Create cancellations view using table1
CREATE VIEW cancellations_view AS
SELECT *
FROM table1
WHERE row_status = 'cancellation'