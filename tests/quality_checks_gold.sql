/*
=================================================================================
Quality Checks
=================================================================================
Script Purpose:
    This performs various quality checks to validate the integrity, consistency
    , and accuracy of the gold layer.
    These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity beteen fact and dimension tables.
    - Validation of relationship in the data model for analytical purposes.

Usage Note:
    - Run these checks after data loading into Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
=================================================================================
*/

-- ========================================================
-- Checking Customers Dimension Table 'gold.dim_customers'
-- ========================================================
-- Check for uniqueness of Customer key
-- Expectation: No Results

SELECT
  customer_key,
  COUNT(*) AS dublicates
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- ========================================================
-- Checking Products Dimension Table 'gold.dim_products'
-- ========================================================
-- Check for uniqueness of Product key
-- Expectation: No Results

SELECT
  product_key,
  COUNT(*) AS dublicates
FROM gold.dim_customers
GROUP BY product_key
HAVING COUNT(*) > 1;


-- ========================================================
-- Checking Fact Sales Table 'gold.fact_sales'
-- ========================================================
-- Check for uniqueness of Product key
-- Expectation: No Results
SELECT 
	*
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
ON fs.product_key = dp.product_key
LEFT JOIN gold.dim_customers AS dc
ON fs.customer_key = dc.customer_key
WHERE dp.product_key IS NULL OR dc.customer_key IS NULL;
