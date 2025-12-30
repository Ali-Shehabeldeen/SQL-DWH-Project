/*
=================================================================================
EDA: Ranking Analysis
=================================================================================
Script Purpose:
    This script focuses on using SQL Server's ranking functions such as RANK(), 
    DENSE_RANK(), and ROW_NUMBER(). 
    These functions allow us to assign ranks to rows based on the values in the 
    measure columns, enabling us to identify top performers, bottom performers, 
    and other ranking-based insights.

Usage:
    - Use these analyses for more insights of your data based on ranking.
=================================================================================
*/ 
-- 1. Which 5 products generate the highest revenu and lowest revnue

-- Identify the highest revenue products
SELECT TOP (5) 
	dp.product_name,
	dp.category,
	FORMAT(SUM(fs.sales_amount), 'C0') AS revenue
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
ON dp.product_key = fs.product_key
GROUP BY 
	dp.product_name,
	dp.category
ORDER BY SUM(fs.sales_amount) DESC;
-- Using window functions and subquery
SELECT 
	product_name,
	category,
	revenue
FROM( 
SELECT 
	dp.product_name,
	dp.category,
	FORMAT(SUM(fs.sales_amount), 'C0') AS revenue,
	ROW_NUMBER() OVER (ORDER BY SUM(fs.sales_amount) DESC) AS ranked_products
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
ON dp.product_key = fs.product_key
GROUP BY 
	dp.product_name,
	dp.category)t
WHERE ranked_products <= 5;

-- Identify the worest revenue products
SELECT TOP (5) 
	dp.product_name,
	dp.category,
	FORMAT(SUM(fs.sales_amount), 'C0') AS revenue
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
ON dp.product_key = fs.product_key
GROUP BY 
	dp.product_name,
	dp.category
ORDER BY SUM(fs.sales_amount) ASC;
