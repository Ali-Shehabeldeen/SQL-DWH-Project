-- Building dimentionl tables from the silver layer

-- 1. Building the Customers Dimention Table
-- We have three tabels that includes data for customers (one from the crm and two in the erp)

SELECT TOP (5) * From silver.crm_cust_info;

SELECT TOP (5) * From silver.erp_cust_az12;

SELECT TOP (5) * From silver.erp_loc_a101;

-- By selecting the first five records of each table, it seems that the crm table include most of the information
-- While the other includes additional information that could be joined to the masetr table

SELECT 
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_status,
	ci.cst_gndr,
	ci.cst_create_date,
	ca.bdate,
	ca.gen,
	la.cntry
FROM silver.crm_cust_info AS ci
LEFT JOIN	silver.erp_cust_az12 AS ca
ON			ca.cid = ci.cst_key
LEFT JOIN	silver.erp_loc_a101 AS la
ON			la.cid = ci.cst_key;

-- After joining the table, we need to check if there exist dublicates in the primary key as follows 

SELECT 
	cst_id,
	COUNT(*) AS dublicated_ids
FROM (
SELECT 
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_status,
	ci.cst_gndr,
	ci.cst_create_date,
	ca.bdate,
	ca.gen,
	la.cntry
FROM silver.crm_cust_info AS ci
LEFT JOIN	silver.erp_cust_az12 AS ca
ON			ca.cid = ci.cst_key
LEFT JOIN	silver.erp_loc_a101 AS la
ON			la.cid = ci.cst_key) t
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- The results show that there are no dublicates

-- It is observed that the new table includes two columns that provide the same info about the gender 
-- One comes from the crm system, and the other one comes from the erp system
-- Therefore, we need to compare both info and try to integrate both in one column, makking it more representative

-- 1. Compare both columns
SELECT DISTINCT
	ci.cst_gndr,
	ca.gen
FROM silver.crm_cust_info AS ci
LEFT JOIN	silver.erp_cust_az12 AS ca
ON			ca.cid = ci.cst_key
LEFT JOIN	silver.erp_loc_a101 AS la
ON			la.cid = ci.cst_key
ORDER BY 1,2;

-- By comparing both tables, it seems that there is a mismatch between both columns
-- Therefore, we will apply the following rules
-- The CRM source data is the master; however if the crm has NA, use the information from the other table
-- If the information from the other table is Null use NA

SELECT DISTINCT
	ci.cst_gndr,
	ca.gen,
	CASE 
		WHEN ci.cst_gndr != 'NA' THEN ci.cst_gndr -- CRM is the master
		ELSE COALESCE(ca.gen, 'NA')
	END AS new_gen
FROM silver.crm_cust_info AS ci
LEFT JOIN	silver.erp_cust_az12 AS ca
ON			ca.cid = ci.cst_key
LEFT JOIN	silver.erp_loc_a101 AS la
ON			la.cid = ci.cst_key
ORDER BY 1,2;


-- Now, we ca nuse the new column in the table

SELECT 
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_status,
	CASE 
		WHEN ci.cst_gndr != 'NA' THEN ci.cst_gndr -- CRM is the master
		ELSE COALESCE(ca.gen, 'NA')
	END AS new_gen,
	ci.cst_create_date,
	ca.bdate,
	la.cntry
FROM silver.crm_cust_info AS ci
LEFT JOIN	silver.erp_cust_az12 AS ca
ON			ca.cid = ci.cst_key
LEFT JOIN	silver.erp_loc_a101 AS la
ON			la.cid = ci.cst_key;

-- Next, we will rename the column to be easy to read and understand
-- Also, we will reorder them to group the more relevant columns together

SELECT 
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

-- We need also to create a surrogate key for this dimentional table using the window function row_number()

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

-- Lastly, we will create the view to be ready for use by other 

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

-- Now, let's check the quality of the view 

-- Test the view
SELECT * FROM  gold.dim_customers;

-- Check the gender column
SELECT DISTINCT gender FROM  gold.dim_customers;


-- 1. Building the Products Dimention Table
-- We have two tabels that includes data for customers (one from the crm and one in the erp)

SELECT TOP (5) * From silver.crm_prd_info;

SELECT TOP (5) * From silver.erp_px_cat_g1v2;

-- It is observed that the crm_prd_info table includes historical data about the products
-- Let's we need only to focus on the current products (which have null in the end_date)

SELECT 
	pinf.prd_id,
	pinf.cat_id,
	pinf.prd_key,
	pinf.prd_nm,
	pinf.prd_cost,
	pinf.prd_line,
	pinf.prd_start_dt
From silver.crm_prd_info AS pinf
WHERE prd_end_dt IS NULL -- Filter out all historical data

-- Now we need tojoin both tables inone dim table
SELECT 
	pinf.prd_id,
	pinf.cat_id,
	pinf.prd_key,
	pinf.prd_nm,
	pinf.prd_cost,
	pinf.prd_line,
	pinf.prd_start_dt,
	pc.cat,
	pc.subcat,
	pc.maintenance
From silver.crm_prd_info AS pinf
LEFT JOIN	silver.erp_px_cat_g1v2 AS pc
ON			pc.id = pinf.cat_id			
WHERE prd_end_dt IS NULL -- Filter out all historical data

-- Check the dublicates
SELECT 
	prd_key, 
	COUNT(*) AS dublicates
FROM (
SELECT 
	pinf.prd_id,
	pinf.cat_id,
	pinf.prd_key,
	pinf.prd_nm,
	pinf.prd_cost,
	pinf.prd_line,
	pinf.prd_start_dt,
	pc.cat,
	pc.subcat,
	pc.maintenance
From silver.crm_prd_info AS pinf
LEFT JOIN	silver.erp_px_cat_g1v2 AS pc
ON			pc.id = pinf.cat_id			
WHERE prd_end_dt IS NULL) t -- Filter out all historical data
GROUP BY prd_key
HAVING COUNT(*) > 1;

-- Prefect, no dublicates found and also it seems that we don't have any dublicate columns

-- Let's reorder the columns to group relevant column together and rename them with discriptive names as follows

SELECT 
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
WHERE prd_end_dt IS NULL -- Filter out all historical data

-- Lastly, we will create a surorgate key and the view as well

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
WHERE prd_end_dt IS NULL -- Filter out all historical data
