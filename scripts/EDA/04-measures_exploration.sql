/*
=================================================================================
EDA: Exploring measure columns
=================================================================================
Script Purpose:
    This script focuses on the quantitative values that represent the metrics or 
    key performance indicators (KPIs) of interest. 
    This involves examining the measure columns in the fact tables to understand 
    their distributions, aggregations, and relationships with other dimensions.

Usage:
    - Use these analyses to explore the measure columns in your DB tables.
=================================================================================
*/
-- 1. Find the total sales
SELECT TOP (5) * FROM gold.fact_sales;

SELECT
	FORMAT(SUM(sales_amount), 'C') AS total_sales
FROM gold.fact_sales;

-- 2. Find how many items are sold
SELECT
	SUM(quantity) AS total_sold_items
FROM gold.fact_sales;

-- 3. Find the average selling price
SELECT
	AVG(price) AS avg_price
FROM gold.fact_sales;

-- 4. Find the total number of orders
SELECT
	COUNT(DISTINCT order_number) AS totoal_orders
FROM gold.fact_sales;

-- 5. Find the total number of products
SELECT TOP (5) * FROM gold.dim_products;

SELECT
	COUNT(DISTINCT product_key) AS totoal_orders,
	COUNT(DISTINCT product_number) AS totoal_orders,
	COUNT(DISTINCT product_name) AS totoal_orders
FROM gold.dim_products;

-- 6. Find the total number of customers
SELECT TOP (5) * FROM gold.fact_sales;

SELECT
	COUNT(DISTINCT customer_key) AS total_customers
FROM gold.dim_customers;

-- 7. Find the total number of customers that has placed an order
SELECT
	COUNT(DISTINCT customer_key) AS total_ordered_customers
FROM gold.fact_sales;

-- 8. Generate a report that shows all key mertics of the business

SELECT TOP (5) * FROM gold.fact_sales;
SELECT TOP (5) * FROM gold.dim_customers;
SELECT TOP (5) * FROM gold.dim_products;
-- 1. Find the total sales
-- 2. Find how many items are sold
-- 3. Find the average selling price
-- 4. Find the total number of orders
-- 5. Find the total number of products
-- 6. Find the total number of customers
-- 7. Find the total number of customers that has placed an order
SELECT 
	FORMAT(SUM(fs.sales_amount), 'C') AS total_sales,
	FORMAT(SUM(fs.quantity), 'N0') AS sold_items,
	FORMAT(AVG(fs.price), 'C') AS avg_price,
	FORMAT(COUNT(DISTINCT fs.order_number), 'N0') AS total_orders,
	FORMAT(COUNT(DISTINCT dp.product_name), 'N0') AS total_products,
	FORMAT(COUNT(DISTINCT dc.customer_id), 'N0') AS total_customers,
	FORMAT(COUNT(DISTINCT fs.customer_key), 'N0') AS total_ordered_customers
FROM gold.fact_sales as fs
LEFT JOIN gold.dim_customers as dc
ON		  fs.customer_key = dc.customer_key
LEFT JOIN gold.dim_products as dp
ON		  dp.product_key = fs.product_key;

-- OR
SELECT 
	'Total Sales' AS measure_name, 
	FORMAT(SUM(sales_amount), 'C0') AS measure_value 
FROM gold.fact_sales
UNION ALL
SELECT 
	'Total Quantity' AS measure_name, 
	FORMAT(SUM(quantity), 'N0') AS measure_value 
FROM gold.fact_sales
UNION ALL
SELECT 
	'Average Price' AS measure_name, 
	FORMAT(AVG(price), 'C0') AS measure_value 
FROM gold.fact_sales
UNION ALL
SELECT 
	'Total Orders' AS measure_name, 
	FORMAT(COUNT(DISTINCT order_number), 'N0') AS measure_value 
FROM gold.fact_sales
UNION ALL
SELECT 
	'Total Products' AS measure_name, 
	FORMAT(COUNT(DISTINCT product_name), 'N0') AS measure_value 
FROM gold.dim_products
UNION ALL
SELECT 
	'Total Customers' AS measure_name, 
	FORMAT(COUNT(DISTINCT customer_id), 'N0') AS measure_value 
FROM gold.dim_customers
UNION ALL
SELECT 
	'Total Ordered Customers' AS measure_name, 
	FORMAT(COUNT(DISTINCT customer_key), 'N0') AS measure_value 
FROM gold.fact_sales;
