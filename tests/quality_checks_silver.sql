/*
===========================================================================
Quality Checks
===========================================================================
Script Purpose:
    This performs various quality checks for dat consistency, accuracy, and
    standarization across the 'silver' schema.
    It includes checks for:
    - Null or dublcate primary keys.
    - Unwanted spaces in string fields.
    - Data standarization and consistency.
    - Invalid data ranges and orders.
    - Data consistency between related fields..

Usage Note:
    - Run these checks after data loading into Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===========================================================================
*/

-- ---------------------------------
-- Checking CRM Tables
-- ---------------------------------

-- ======================================================
-- Checking Customers Info Table 'silver.crm_cust_info'
-- ======================================================
-- Check for the NULLs or Dublicates in the Primary key
-- Expectation: No Results
SELECT 
	cst_id,
	COUNT(*) AS dublicated_ids
from silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check unwanted spaces in string fields
SELECT 
	cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT 
	cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT 
	cst_marital_status
FROM silver.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status);

SELECT 
	cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

-- Check data standarization and consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;

-- Check the linakage with the sales fact table
SELECT *
FROM silver.crm_cust_info
WHERE cust_id IN (SELECT sls_cust_id FROM silver.crm_sales_details);

-- ======================================================
-- Checking Product Info Table 'silver.crm_prd_info'
-- ======================================================
-- Check for the NULLs or Dublicates in the Primary key
-- Expectation: No Results
SELECT 
	prd_id,
	COUNT(*) AS dunblicated_ids
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check invalid data
SELECT 
	 prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Checking date validation (Rule: Start date should be before the end date)
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- Check the linakage with the sales fact table
SELECT *
FROM silver.crm_prd_info
WHERE prd_key IN (SELECT sls_prd_key FROM silver.crm_sales_details);

-- ======================================================
-- Checking Sales Table 'silver.crm_sales_details'
-- ======================================================
-- Check for the NULLs or Dublicates in the Primary key
-- Expectation: No Results
SELECT 
	sls_ord_num,
  sls_prd_key,
  sls_cust_id,
  sls_order_dt,
  sls_ship_dt,
  sls_due_dt,
  sls_sales,
  sls_quantity,
  sls_price
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)
OR sls_prd_key != TRIM(sls_prd_key);

-- Check the linakage with the other tables
SELECT 
	sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
-- WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

-- Validate dates (sls_order_dt, sls_ship_dt, and sls_due_dt)
SELECT 
    sls_order_dt -- sls_ship_dt -- sls_due_dt
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0
OR LEN(sls_order_dt) != 8
OR sls_order_dt > 20500101 -- check the dates within upper boundary
OR sls_order_dt < 19000101; -- check the dates within lower boundary

SELECT 
	sls_ord_num,
  sls_prd_key,
  sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
  sls_due_dt,
  sls_sales,
  sls_quantity,
  sls_price
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- Validate the sales, quantity, and prices 
SELECT
	sls_sales,
  sls_quantity,
  sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales <= 0 
OR sls_sales IS NULL
OR sls_quantity <= 0 
OR sls_quantity IS NULL
OR sls_price <= 0 
OR sls_price IS NULL
ORDER BY sls_sales, sls_quantity, sls_price;

-- ---------------------------------
-- Checking ERP Tables
-- ---------------------------------

-- ======================================================
-- Checking Customers Table 'silver.erp_cust_az12'
-- ======================================================
-- Check for the NULLs or Dublicates in the Primary key
-- Expectation: No Results
SELECT 
	cid
FROM silver.erp_cust_az12
WHERE cid != TRIM(cid);

-- Check the linakage with the customers info table
SELECT
	cid,
	bdate,
	gen
FROM silver.erp_cust_az12
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info); 

-- Check for future birth dates 
SELECT
	cid,
	bdate,
	gen
FROM silver.erp_cust_az12
WHERE bdate > GETDATE();

-- Check data consistency in the gender column
SELECT DISTINCT
	gen
FROM silver.erp_cust_az12;

-- ======================================================
-- Checking Locations Table 'silver.erp_loc_a101'
-- ======================================================
-- Check for the NULLs or Dublicates in the Primary key
-- Expectation: No Results
SELECT
	cid,
	cntry
FROM silver.erp_loc_a101
WHERE cid != TRIM(cid);
  
-- Check data consistency in the country column
SELECT DISTINCT
	cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

-- Check the linakage with the customers info table
SELECT
	cid,
	cntry
FROM silver.erp_loc_a101
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);

-- ======================================================
-- Checking Categories Table 'silver.erp_px_cat_g1v2'
-- ======================================================
-- Check for the NULLs or Dublicates in the Primary key
-- Expectation: No Results
SELECT
	id,
	cat,
	subcat,
	maintenance
FROM silver.erp_px_cat_g1v2
WHERE id != TRIM(id)
OR cat != TRIM(cat)
OR subcat != TRIM(subcat) 
OR maintenance != TRIM(maintenance);

-- Check the linakage with the product info table
SELECT
	id,
	cat,
	subcat,
	maintenance
FROM silver.erp_px_cat_g1v2
WHERE id NOT IN (SELECT cat_id FROM silver.crm_prd_info);

-- Check data consistency in all column
SELECT DISTINCT
	cat
FROM silver.erp_px_cat_g1v2;

SELECT DISTINCT
	subcat
FROM silver.erp_px_cat_g1v2;

SELECT DISTINCT
	maintenance
FROM silver.erp_px_cat_g1v2;





















