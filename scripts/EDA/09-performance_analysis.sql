/*
=================================================================================
EDA: Performance Analysis
=================================================================================
Script Purpose:
    This script focuses on evaluating the performance of key metrics against 
    predefined targets or benchmarks. 
    This analysis helps identify areas of improvement and opportunities for 
    optimization, enabling data-driven decision-making. 
    This is by comparing actual performance metrics with target values and 
    calculating performance ratios or percentages.

Usage:
    - Use these analyses to identify areas of improvement in your business.
=================================================================================
*/ 

/* Analyze the yearly performance of products by comparing their sales
to both the average sales performance of the product and the previous year's sales */
WITH CurrentSales AS ( -- prepare the current sales in a CTE
SELECT
	YEAR(fs.order_date) AS order_year,
	dp.product_name AS product_name,
	SUM(fs.sales_amount) AS current_sales
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
ON
	fs.product_key = dp.product_key
WHERE fs.order_date IS NOT NULL
GROUP BY 
	YEAR(fs.order_date),
	dp.product_name
)
SELECT 
	order_year,
	product_name,
	FORMAT(current_sales, 'C0') AS current_sales,
	FORMAT(AVG(current_sales) OVER (PARTITION BY product_name), 'C0') AS avg_sales,
	FORMAT(current_sales - AVG(current_sales) OVER (PARTITION BY product_name), 'C0') AS diff_avg,
	CASE 
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Under Avg'
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Over Avg'
		ELSE 'At Avg'
	END AS avg_category,
	FORMAT(LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year), 'C0') AS py_sales,
	FORMAT(current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year), 'C0') AS diff_py,
	CASE 
		WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
		WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
		ELSE 'Flat'
	END AS py_category
FROM CurrentSales
ORDER By
		product_name,
		order_year;
