/*
=================================================================================
EDA: Cumulative Analysis
=================================================================================
Script Purpose:
    This script focuses on using cumulative analysis to calculate running totals 
    or cumulative sums of key metrics over time. 
    This analysis helps track the overall performance and growth of key measures, 
    providing insights into long-term trends and patterns. 
    This is by aggregating the data over time and calculating the cumulative sum 
    for each time period.

Usage:
    - Use these analyses to track the overall performance of the business.
=================================================================================
*/
-- Calculate the total sales per month,
-- The monthly running total sales over time
-- The moving average price over time
WITH MonthlyCumSales AS (
	SELECT 
		DATETRUNC(MONTH, order_date) AS order_month,
		SUM(sales_amount) AS total_sales,
		AVG(price) AS avg_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH, order_date)
)
SELECT
	order_month,
	FORMAT(total_sales, 'C0') AS total_sales,
	FORMAT(SUM(total_sales) OVER (PARTITION BY order_month ORDER BY order_month), 'C0') AS rumming_total_sales,
	FORMAT(avg_price, 'C0') AS average_price,
	FORMAT(AVG(avg_price) OVER (PARTITION BY order_month ORDER BY order_month), 'C0') AS moving_average_price
FROM MonthlyCumSales;

-- Calculate the total sales per year,
-- The monthly running total sales over time
-- The moving average price over time
WITH YearlyCumSales AS (
	SELECT 
		DATETRUNC(YEAR, order_date) AS order_year,
		SUM(sales_amount) AS total_sales,
		AVG(price) AS avg_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(YEAR, order_date)
)
SELECT
	order_year,
	FORMAT(total_sales, 'C0') AS total_sales,
	FORMAT(SUM(total_sales) OVER (ORDER BY order_year), 'C0') AS rumming_total_sales,
	FORMAT(avg_price, 'C0') AS average_price,
	FORMAT(AVG(avg_price) OVER (ORDER BY order_year), 'C0') AS moving_average_price
FROM YearlyCumSales;
