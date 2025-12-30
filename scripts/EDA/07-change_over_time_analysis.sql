/*
=================================================================================
EDA: Change Over Time Analysis
=================================================================================
Script Purpose:
    This script focuses on analyzing how key metrics and measures evolve over 
    specific time periods. This analysis helps identify trends, seasonality, 
    and patterns in the data that may impact business performance. 
    This is by aggregating the data over different time intervals (e.g., daily, 
    monthly, yearly) and comparing the results to identify changes and trends.

Usage:
    - Use these analyses to monitor behaviour of the business over time.
=================================================================================
*/ 
-- Analyze sales amount change over time (monthly)
SELECT
	DATEPART(YEAR, order_date) AS year,
	DATEPART(MONTH, order_date) AS month,
	FORMAT(SUM(sales_amount), 'C0') AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY
	DATEPART(YEAR, order_date),
	DATEPART(MONTH, order_date)
ORDER BY
	year,
	month;
