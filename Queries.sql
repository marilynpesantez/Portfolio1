-- A. Monthly sales revenue, revenue growth, order volume, average order value, and units sold
WITH MonthlySales AS
(
	SELECT
		Year_num,
		Month_name,
		Month_num,
		ROUND(SUM(total_value), 2) AS sales_revenue,
		COUNT(DISTINCT InvoiceNo) AS order_volume,
		ROUND(SUM(total_value)/COUNT(DISTINCT InvoiceNo), 2) AS average_order_value,
		SUM(Quantity) AS units_sold
	FROM sales_view
	GROUP BY Year_num, Month_name, Month_num
)
SELECT
	curr.Year_num AS 'Year', curr.Month_name AS 'Month', curr.Month_num,
	curr.sales_revenue,
	ROUND((curr.sales_revenue - previous.sales_revenue) * 100 / previous.sales_revenue, 2) AS MOM_revenue_growth,
	curr.order_volume,
	curr.average_order_value,
	curr.units_sold
FROM MonthlySales AS curr
LEFT JOIN MonthlySales AS previous
	ON curr.Year_num = previous.Year_num AND curr.Month_num = previous.Month_num + 1
	OR (curr.Year_num = previous.Year_num + 1 AND curr.Month_num = 1 AND previous.Month_num = 12)
ORDER BY curr.Year_num, curr.Month_num
------------------------------------------------------------------------------
-- B. Country level sales revenue, order volume, average order value, and units sold
SELECT 
	Country, 
    ROUND(SUM(total_value), 2) AS sales_revenue,
	COUNT(DISTINCT InvoiceNo) AS order_volume,
    SUM(Quantity) AS country_units_sold,
    ROUND(SUM(total_value)/COUNT(DISTINCT InvoiceNo), 2) AS country_average_order_value
FROM sale_view
GROUP BY Country
----------------------------------------------------------------------------------------------------------------------------------------
-- C. Product level sales revenue, order volume, and units sold
SELECT 
	Item, 
    ROUND(SUM(total_value), 2) AS sales_revenue,
	COUNT(DISTINCT InvoiceNo) AS order_volume,
    SUM(Quantity) AS units_sold
FROM sale_view
WHERE Item <> 'Manual'
GROUP BY Item
ORDER BY product_sales DESC







