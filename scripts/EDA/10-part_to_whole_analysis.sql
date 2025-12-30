/*
=================================================================================
EDA: Part-to-Whole Analysis
=================================================================================
Script Purpose:
    This script focuses on examining the contribution of individual components 
    or segments to the overall total. 
    This analysis helps understand the relative importance of different factors 
    and their impact on key metrics. 
    This is by calculating the percentage contribution of each component to the 
    total and visualizing the results using pie charts or bar charts.

Usage:
    - Use these analyses to understand the relative importance of different 
      factors in your business.
=================================================================================
*/ 
-- Which categories contribute the most to overall sales?
SELECT 
	category,
	FORMAT(SUM(sales_amount), 'C0') AS total_sales,
	CONCAT(ROUND((CAST(SUM(sales_amount) AS FLOAT) * 100) / CAST((SELECT SUM(sales_amount) FROM gold.fact_sales) AS FLOAT), 2), '%') AS Percentage_contribution
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
ON dp.product_key = fs.product_key
GROUP BY category
ORDER BY SUM(sales_amount) DESC;
