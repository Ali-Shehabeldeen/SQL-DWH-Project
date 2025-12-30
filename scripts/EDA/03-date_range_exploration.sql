/*
=================================================================================
EDA: Exploring date columns
=================================================================================
Script Purpose:
    This script focuses on understanding the distribution and patterns of date 
    columns in the dimension tables. 
    This involves examining the date columns to identify trends, seasonality, 
    and other temporal patterns that may be relevant for analysis.

Usage:
    - Use these analyses to explore the date columns in your DB tables.
=================================================================================
*/ 

-- ===========================================================
-- Exploring date columns in gold.fact_sales
-- ===========================================================
-- 1. Exploring the sales dates (order date, shipping date, and due date)
SELECT 
	* 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'fact_sales';

-- 2. Exploring the boundaries and sapn of the order dates
-- Find the date of the first and last order
SELECT
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date,
	DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS order_spans
FROM gold.fact_sales;

-- 3. Exploring the birthdate for the customers
-- Find the youngest and oldest customers
SELECT
	MIN(birthday) AS oldest_birthdate,
	DATEDIFF(YEAR, MIN(birthday), GETDAtE()) AS oldest_age,
	MAX(birthday) AS youngest_birthdate,
	DATEDIFF(YEAR, MAX(birthday), GETDATE()) AS youngest_age
FROM gold.dim_customers;
