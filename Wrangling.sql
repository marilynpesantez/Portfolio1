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

-- Create transactions using view1
CREATE TABLE transactions AS
SELECT *
FROM view1;

-- Update transactions to label duplicate records
UPDATE transactions
SET row_status = 'duplicate'
WHERE row_num > 1

-- Update transactions to label sales records
UPDATE transactions
SET row_status = 'sale'
WHERE row_num = 1 AND 
	(Quantity > 0 AND UnitPrice > 0 AND StockCode <> 'B' AND InvoiceNo NOT LIKE 'C%')
    
-- Update transactions to label cancelled sales records
UPDATE transactions
SET row_status = 'cancellation'
WHERE row_num = 1 AND 
	(Quantity < 0 AND InvoiceNo LIKE 'C%')
    
-- Update transactions to label records for items given away for free
UPDATE transactions
SET row_status = 'giveaway'
WHERE row_num = 1 AND 
	(Quantity > 0 AND UnitPrice = 0 AND CustomerID != '')
    
-- Update transactions to label test/misc records
UPDATE transactions
SET row_status = 'test_misc'
WHERE row_num = 1 AND
	(UnitPrice = 0 AND CustomerID = '')
    
-- Update transactions to label debt adjustments
UPDATE transactions
SET row_status = 'adjustment'
WHERE row_num = 1 AND
	(StockCode = 'B' OR (Quantity > 0 AND InvoiceNo LIKE 'C%'))
    
-- Verify that all records have been labeled
SELECT row_status, count(row_status) AS cnt
FROM transactions
GROUP BY row_status
------------------------------------------------------------------------------------------------------------------------------------------------
-- Create sales view using transactions 
CREATE VIEW sales_view AS
SELECT *
FROM transactions
WHERE row_status = 'sale'

-- Create cancellations view using transactions
CREATE VIEW cancellations_view AS
SELECT *
FROM transactions
WHERE row_status = 'cancellation'

-- Create giveaways view using transactions
CREATE VIEW giveaways_view AS
SELECT *
FROM transactions
WHERE row_status = 'giveaway'

-- Create test/misc view using transactions
CREATE VIEW test_misc_view AS
SELECT *
FROM transactions
WHERE row_status = 'test_misc'

-- Create adjustments view using transactions
CREATE VIEW adjustments_view AS
SELECT *
FROM transactions
WHERE row_status = 'adjustment'

-- Create duplicated records view using transactions
CREATE VIEW duplicates_view AS
SELECT *
FROM transactions
WHERE row_status = 'duplicate'