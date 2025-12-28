/*
=================================================================================
DDL Script: Create Gold Views
=================================================================================
Script Purpose:
    This script creates views for the 'gold' schema in the data warehouse.
    The gold layer represents the final dimension and fact tables (Star Schema).

    Each view performs transformations and combines data from the Silver layer
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be quired directly for analytics and reporting.
=================================================================================
*/ 

-- ===========================================================
-- Create Dimension Table (Customers): gold.dim_customers
-- ===========================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
	DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE 
		WHEN ci.cst_gndr != 'NA' THEN ci.cst_gndr -- CRM is the master
		ELSE COALESCE(ca.gen, 'NA')
	END AS gender,
	ca.bdate AS birthday,
	ci.cst_create_date AS create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN	silver.erp_cust_az12 AS ca
ON			ca.cid = ci.cst_key
LEFT JOIN	silver.erp_loc_a101 AS la
ON			la.cid = ci.cst_key;

-- ===========================================================
-- Create Dimension Table (Products): gold.dim_products
-- ===========================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
	DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER (ORDER BY prd_start_dt, prd_key) AS product_key,
	pinf.prd_id AS product_id,
	pinf.prd_key AS product_number,
	pinf.prd_nm product_name,
	pinf.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance AS maintenance,
	pinf.prd_cost AS cost,
	pinf.prd_line AS product_line,
	pinf.prd_start_dt AS start_date
From silver.crm_prd_info AS pinf
LEFT JOIN	silver.erp_px_cat_g1v2 AS pc
ON			pc.id = pinf.cat_id			
WHERE prd_end_dt IS NULL; -- Filter out all historical data


-- ===========================================================
-- Create Fact Table (Sales): gold.fact_sales
-- ===========================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
	DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT 
	sd.sls_ord_num AS order_number,
	dp.product_key,
	dc.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS dp
ON sd.sls_prd_key = dp.product_number
LEFT JOIN gold.dim_customers AS dc
ON sd.sls_cust_id = dc.customer_id;






