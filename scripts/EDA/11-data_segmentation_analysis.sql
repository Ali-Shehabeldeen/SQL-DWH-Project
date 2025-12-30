/*
=================================================================================
EDA: Data Segmentation Analysis
=================================================================================
Script Purpose:
    This script focuses on using the data segmentation technique to divide the 
    data into distinct groups or segments based on specific criteria. 
    This analysis helps identify patterns and trends within different segments, 
    enabling targeted strategies and interventions. 
    This is by grouping the data based on relevant attributes and analyzing the 
    characteristics of each segment.

Usage:
    - Use these analyses to to divide the data into distinct groups.
=================================================================================
*/ 

/* Segment products into cost ranges and
count how many products fall into each segment */
WITH CostSegments AS (
	SELECT
		product_key,
		product_name,
		cost,
		CASE 
			WHEN cost < 100 THEN 'Below 100'
			WHEN cost BETWEEN 100 AND 500 THEN '100-500'
			WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
			ELSE 'Above 1000'
		END AS cost_ranges
	FROM gold.dim_products
)

SELECT
	cost_ranges,
	COUNT(product_key) AS total_products
FROM CostSegments
GROUP BY cost_ranges
ORDER BY COUNT(product_key) DESC;

/* Group customers into three segments based on their spending behaviour:
	- VIP: Customers with at least 12 months of history and spending more than 5,000
	- Regular: Customers with at least 12 months of history and spending less than or equal 5,000
	- New: Customers with a lifespan < 12 months
And find the total number of customers by each group
*/
WITH CustomerSpending AS (
	SELECT
		c.customer_key AS customer_key,
		SUM(f.sales_amount) AS total_sales,
		DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_customers AS c
	ON c.customer_key = f.customer_key
	GROUP BY c.customer_key
)
SELECT 
	customer_type,
	FORMAT(COUNT(DISTINCT customer_key), 'N0') AS total_customers
FROM (
	SELECT 
		customer_key,
		total_sales,
		lifespan,
		CASE
			WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
			WHEN lifespan >= 12 AND total_sales < 5000 THEN 'Regular'
			ELSE 'New'
		END AS customer_type
	FROM CustomerSpending
)t
GROUP BY customer_type
ORDER BY COUNT(DISTINCT customer_key) DESC;
