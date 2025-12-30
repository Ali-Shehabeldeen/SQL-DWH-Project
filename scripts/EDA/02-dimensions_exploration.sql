/*
=================================================================================
EDA: Exploring dimension columns
=================================================================================
Script Purpose:
    This script focuses on the descriptive attributes that provide context and 
    meaning to the data. 
    This involves examining the columns in the dimension tables to understand 
    their data types, distributions, and relationships with other tables.

Usage:
    - Use these analyses to explore the dimension columns in your DB tables.
=================================================================================
*/ 

-- ===========================================================
-- Exploring dimensions in gold.dim_customers
-- ===========================================================
-- 1. Explore all countries our customers come from
SELECT DISTINCT
	country
FROM gold.dim_customers;

-- 2. Explore all categories "The Major Divisions"
SELECT 
	*
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_products' -- select specific column

SELECT DISTINCT
	category
FROM gold.dim_products;

-- 3. Explore the hirearchy of the products (Product Name, Subcategory, and category)
SELECT DISTINCT
	product_name,
	subcategory,
	category
FROM gold.dim_products
ORDER BY 3,2,1;
