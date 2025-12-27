-- Check for the NULLs or Dublicates in the Primary key
-- Expectation: No Results

-- Check the customers table
SELECT 
	cst_id,
	COUNT(*) AS dublicated_ids
from bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- The results show that the bronze.crm_cust_info table includes dublictes IDs 
-- Therefore, we will check the records one by one and decide which one will be using and which will be removed
SELECT 
	*
FROM bronze.crm_cust_info
WHERE cst_id = 29466;

-- Based on the results, it seems that we can order the dublicates with the create date column and keep the last recorded one, as shown below
SELECT 
	*
FROM (
SELECT 
	*,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info
) t 
WHERE flag_last = 1;


-- It is also noted that the Customer table includes string columns that shhould be checked for unwanted spaces

SELECT 
	cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT 
	cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT 
	cst_marital_status
FROM bronze.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status);

SELECT 
	cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

-- The results show that there exist some leading or tailing spaces in the firstname and lastname columns that should be also removed from the table

SELECT 
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
FROM (
SELECT 
	*,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info
) t 
WHERE flag_last = 1;

-- It is recognized that the marital status and the gender columns includes appreviations; therefore we need to change them for better representation

SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;

SELECT 
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,

	CASE 
		WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		ELSE 'NA'
	END AS cst_marital_status,

	CASE 
		WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		ELSE 'NA'
	END AS cst_gndr,
	cst_create_date
FROM (
SELECT 
	*,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info
) t 
WHERE flag_last = 1 AND cst_id IS NOT NULL;


-- Now, we fixed everything in the Customer Table is cleaned 
-- Therefore, we can insert them into the silver table

INSERT INTO silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
)
SELECT 
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,

	CASE 
		WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		ELSE 'NA'
	END AS cst_marital_status, -- Normalize marital status values to readable format

	CASE 
		WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		ELSE 'NA'
	END AS cst_gndr, -- Normalize gender values to readable format
	cst_create_date
FROM (
SELECT 
	*,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info
) t 
WHERE flag_last = 1 AND cst_id IS NOT NULL;

-- Validate the results
SELECT * FROM silver.crm_cust_info;

SELECT DISTINCT cst_marital_status FROM silver.crm_cust_info;

SELECT 
	cst_id,
	COUNT(*) AS dublicated_ids
from silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1

-- Now everything is okay and thn we will check the product table

SELECT * FROM bronze.crm_prd_info;

SELECT * FROM bronze.crm_sales_details;

-- Check the duplicates or NULL values in the primary key

SELECT 
	prd_id,
	COUNT(*) AS dunblicated_ids
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- It is clean

-- It seems that the product key column need to be separated into two new columns in order to join it with other tables like (Sales and product category) tables
-- Also TRIM all the trailing or leading values from the prd_nm column 
-- Check Whether we have nulls or negative numbers in the numeric columns
-- The product line is also includes appreviations, which should be replaced with readable values

SELECT 
	 prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL 

-- This indicates that we have nulls in the cost
-- Therefore, we will replace it with 0 using ISNULL()

-- Checking the start and end date of products (Rule: Start date should be before the end date)

SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- The results shows that there are issues with the products start and end dates, as some records have prd_end_dt < prd_start_dt
-- Therefore, we need to six this issue by creating the end date column again making sure that for certain product the End date = Start date of the next record - 1 with the last one as null
-- Additionally, it is observed that these columns are dates not datetimes, which needs to be casted as well
-- Therefore, we will focus in two scenarios, preparing the query and apply it to the whole table

SELECT 
	*,
	LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS prd_end_dt_test  
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509')


SELECT 
	 prd_id,
	 prd_key,
	 REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	 SUBSTRING(prd_key, 5, LEN(prd_key)) AS prd_key,
	 TRIM(prd_nm) as prd_nm,
	 ISNULL(prd_cost, 0),
	 CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'NA'
	END AS prd_line,
	CAST(prd_start_dt AS DATE) AS prd_start_dt,
	CAST(
	LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info

-- Now we can inser the table in the silver product table
INSERT INTO silver.crm_prd_info (
	prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT 
	 prd_id,
	 REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Extract Category ID
	 SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key, -- Extract Product Key
	 TRIM(prd_nm) as prd_nm,
	 ISNULL(prd_cost, 0) AS prd_cost,
	 CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'NA'
	END AS prd_line, -- Mapping product line values to descriptive values
	CAST(prd_start_dt AS DATE) AS prd_start_dt,
	CAST(
	LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info

-- Validate the data in the Product table


-- Check the duplicates or NULL values in the primary key
SELECT 
	prd_id,
	COUNT(*) AS dunblicated_ids
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Checking the start and end date of products (Rule: Start date should be before the end date)
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- Check Whether we have nulls or negative numbers in the numeric columns
SELECT 
	 prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- Now every thing is perfect in the Product Table

-- Let's check the last table (Sales Transaction Table)

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
FROM bronze.crm_sales_details;

-- First check the issues with string columns (sls_ord_num, sls_prd_num, and sls_cust_id)
-- As well as checking the link between sls_prd_num and sls_cust_id with other tables (Customers and Products)

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
FROM bronze.crm_sales_details
-- WHERE sls_ord_num != TRIM(sls_ord_num)
-- WHERE sls_prd_key != TRIM(sls_prd_key)
-- WHERE sls_prd_key NOT IN (SELECT prd_key FROM [silver].[crm_prd_info])
WHERE sls_cust_id NOT IN (SELECT cst_id FROM [silver].[crm_cust_info])

-- Now the firt three columns are okay; however, all date columns are INT
-- Therefore we need to convert them to dates after checking if there 0 or -ve values exist (IF yes replace them with NULL)
-- Also, we will check if there are values that cannot be converted to dates (len != 8) convert them to null
SELECT 
    sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
OR LEN(sls_order_dt) != 8
OR sls_order_dt > 20500101 -- check the dates within upper boundary
OR sls_order_dt < 19000101 -- check the dates within lower boundary

-- It seems that the order date includes 0s and less than 8 values --> convert them first to NULL then CAST
-- Then repeat the same with the other dates
-- The last check is to check that the order of dates makes sense
SELECT 
	sls_ord_num,
    sls_prd_key,
    sls_cust_id,
	CASE 
		WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END AS sls_order_dt,
	CASE 
		WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END AS sls_ship_dt,
    CASE 
		WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END AS sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Now the dates are fixed

-- For the last three columns (Sales, Quantity, and Price), the rules are
-- 1- Sales = Quantity * Price
-- 2- No negative, zeros, nulls are allowed in these columns
SELECT
	sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales <= 0 
OR sls_sales IS NULL
OR sls_quantity <= 0 
OR sls_quantity IS NULL
OR sls_price <= 0 
OR sls_price IS NULL
ORDER BY sls_sales, sls_quantity, sls_price

-- The results indicates that the sales and price columns have some issues that need to be fixed 
-- Therefore, we will define the following rules to fix them
-- 1. If sales is -ve, 0, or null drive it using Quantity and Price
-- 2. If Price is 0 or NULL, calculate it using Sales and Quantity
-- 3. If Price is -ve, convert it to a positive value

SELECT
	sls_sales as sls_sales_old,
	CASE
		WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price)
			THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales,

	sls_price as sls_price_old,

	CASE
		WHEN sls_price <= 0 OR sls_price IS NULL
			THEN sls_sales / NULLIF(sls_quantity, 0)
		ELSE ABS(sls_price)
	END AS sls_price,

    sls_quantity
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales <= 0 
OR sls_sales IS NULL
OR sls_quantity <= 0 
OR sls_quantity IS NULL
OR sls_price <= 0 
OR sls_price IS NULL
ORDER BY sls_sales, sls_quantity, sls_price

-- Now we can implement this in the code

SELECT 
	sls_ord_num,
    sls_prd_key,
    sls_cust_id,
	CASE 
		WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END AS sls_order_dt,

	CASE 
		WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END AS sls_ship_dt,
    CASE 
		WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END AS sls_due_dt,
    
	CASE
		WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price)
			THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales,
    sls_quantity,
    CASE
		WHEN sls_price <= 0 OR sls_price IS NULL
			THEN sls_sales / NULLIF(sls_quantity, 0)
		ELSE ABS(sls_price)
	END AS sls_price
FROM bronze.crm_sales_details

-- Now, everything is okay, let we insert the data into the table

INSERT INTO silver.crm_sales_details (
	sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)

SELECT 
	sls_ord_num,
    sls_prd_key,
    sls_cust_id,
	CASE 
		WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END AS sls_order_dt,

	CASE 
		WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END AS sls_ship_dt,
    CASE 
		WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END AS sls_due_dt,
    
	CASE
		WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price)
			THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales,
    sls_quantity,
    CASE
		WHEN sls_price <= 0 OR sls_price IS NULL
			THEN sls_sales / NULLIF(sls_quantity, 0)
		ELSE ABS(sls_price)
	END AS sls_price
FROM bronze.crm_sales_details


-- Validate the entered data 
-- It seems that the order date includes 0s and less than 8 values --> convert them first to NULL then CAST
-- Then repeat the same with the other dates
-- The last check is to check that the order of dates makes sense
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

-- Now the dates are fixed

-- For the last three columns (Sales, Quantity, and Price), the rules are
-- 1- Sales = Quantity * Price
-- 2- No negative, zeros, nulls are allowed in these columns
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
ORDER BY sls_sales, sls_quantity, sls_price


SELECT * FROM silver.crm_sales_details;

-- Now everything in the Sales Transaction Table is fine



-- Let's check the erp_cust_az12 Table
SELECT *
FROM [bronze].[erp_cust_az12];

-- This Table includes three columns related to customers, which means that this will be linked to the customers table

-- Lets check first the cid column
-- 1- Check the TRIM
-- 2- Check the matching with the customer id column to link (cid with cust_key)

SELECT 
	cid
FROM bronze.erp_cust_az12
WHERE cid != TRIM(cid)

-- No spaces found

-- Check the matching ids
SELECT *
FROM bronze.erp_cust_az12;

SELECT *
FROM bronze.crm_cust_info;

-- The results show that the cid column includes 'NAS' Ch/cs in the beginning of some values, which need to be removed first to link with the cust_key
SELECT
	CASE 
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) 
		ELSE cid
	END AS cid,
	bdate,
	gen
FROM bronze.erp_cust_az12
WHERE CASE 
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) 
		ELSE cid
	END NOT IN (SELECT cst_key FROM silver.crm_cust_info) 

-- Prefect, the first column is now fine

-- Next, we need to check the bdate column 
-- 1. Check for birth dates in the future and change them to NULL if exist
SELECT
	CASE 
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) 
		ELSE cid
	END AS cid,
	bdate,
	gen
FROM bronze.erp_cust_az12
WHERE bdate < '1925-01-01' OR bdate > GETDATE()

-- It seems that there is some birth dates that invalid
-- Therefore, we need to change any future birth dates to NULL
SELECT
	CASE 
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) 
		ELSE cid
	END AS cid,
	CASE 
		WHEN bdate > GETDATE() THEN NULL
		ELSE bdate
	END AS bdate,
	gen
FROM bronze.erp_cust_az12
WHERE CASE 
		WHEN bdate > GETDATE() THEN NULL
		ELSE bdate
	END > GETDATE()

-- Now, the birth date column is modified
-- Let's check the gender column (It should include three values - Male, Female, or NA)

SELECT DISTINCT
	gen
FROM bronze.erp_cust_az12

-- The results indicate that the gen column include invalid values that should be modified
-- 1- Any 'M' or 'Male' should be 'Male'
-- 2- Any 'F' or 'Female' should be 'Female'
-- 3- Otherwise, should be 'NA'

SELECT DISTINCT
	gen AS gen_old,
	CASE 
		WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
		WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
		ELSE 'NA'
	END AS gen
FROM bronze.erp_cust_az12

SELECT
	CASE 
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) 
		ELSE cid
	END AS cid,
	CASE 
		WHEN bdate > GETDATE() THEN NULL
		ELSE bdate
	END AS bdate,
	CASE 
		WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
		WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
		ELSE 'NA'
	END AS gen
FROM bronze.erp_cust_az12

-- Now, as everything is okay
-- Let's insert into the silver table

INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
SELECT
	CASE 
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) 
		ELSE cid
	END AS cid,
	CASE 
		WHEN bdate > GETDATE() THEN NULL
		ELSE bdate
	END AS bdate,
	CASE 
		WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
		WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
		ELSE 'NA'
	END AS gen -- Normalizing the gender values to be readable
FROM bronze.erp_cust_az12

-- Validate the silver table


SELECT
	cid,
	bdate,
	gen
FROM silver.erp_cust_az12
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info) 
-- Checked

-- Check for birth dates in the future and change them to NULL if exist
SELECT
	cid,
	bdate,
	gen
FROM silver.erp_cust_az12
WHERE bdate > GETDATE()
--checked

-- Check the gen colmn
SELECT DISTINCT
	gen
FROM silver.erp_cust_az12

-- All is checked

SELECT
	*
FROM silver.erp_cust_az12

-- Now, Let's check the next table (Locations - bronze.erp_loc_a101)
SELECT
	*
FROM bronze.erp_loc_a101

-- The table includes two columns
-- The first column includes the cid (customers ids) that should be linked with the Customers Info Table
-- The second column includes the country info

-- First, let's check the validity of the first column 
-- 1. check the empty spaces
-- 2. Check the linkage issues

SELECT
	cid,
	cntry
FROM bronze.erp_loc_a101
WHERE cid != TRIM(cid) -- No empty spaces includes

SELECT
	cid,
	cntry
FROM bronze.erp_loc_a101;

SELECT cst_key FROM silver.crm_cust_info;

-- By comparing the customers key for linkage, it seems that the cid column includes '-' between the letters and numbers, which should be removed to link it with the customers info table
-- Therefore, the cid column should be modified as follows

SELECT
	cid AS cid_old,
	REPLACE(cid, '-', '') AS cid,
	cntry
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (SELECT cst_key FROM silver.crm_cust_info)

-- Validated and checked

-- Let's check the country column
SELECT DISTINCT
	cntry
FROM bronze.erp_loc_a101
ORDER BY cntry

-- The results show inconsistency in the data in the country that should be modified as follows
SELECT DISTINCT
	cntry AS cntry_old,
	CASE
		WHEN UPPER(TRIM(cntry)) IN ('DE', 'GERMANY') THEN 'Germany'
		WHEN UPPER(TRIM(cntry)) IN ('FR', 'FRANCE') THEN 'France'
		WHEN UPPER(TRIM(cntry)) IN ('CA', 'CANADA') THEN 'Canada'
		WHEN UPPER(TRIM(cntry)) IN ('AU', 'AUSTRALIA') THEN 'Australia'
		WHEN UPPER(TRIM(cntry)) IN ('UK', 'UNITED KINGDOM') THEN 'United Kingdom'
		WHEN UPPER(TRIM(cntry)) IN ('US', 'USA', 'UNITED STATES') THEN 'United States'
		ELSE 'NA'
	END AS cntry
FROM bronze.erp_loc_a101
ORDER BY cntry

-- Now every thing is okay!
-- Let's insert it into the silver table
INSERT INTO silver.erp_loc_a101 (cid, cntry)
SELECT
	REPLACE(cid, '-', '') AS cid,
	CASE
		WHEN UPPER(TRIM(cntry)) IN ('DE', 'GERMANY') THEN 'Germany'
		WHEN UPPER(TRIM(cntry)) IN ('FR', 'FRANCE') THEN 'France'
		WHEN UPPER(TRIM(cntry)) IN ('CA', 'CANADA') THEN 'Canada'
		WHEN UPPER(TRIM(cntry)) IN ('AU', 'AUSTRALIA') THEN 'Australia'
		WHEN UPPER(TRIM(cntry)) IN ('UK', 'UNITED KINGDOM') THEN 'United Kingdom'
		WHEN UPPER(TRIM(cntry)) IN ('US', 'USA', 'UNITED STATES') THEN 'United States'
		ELSE 'NA'
	END AS cntry -- Normalize and clean the country values
FROM bronze.erp_loc_a101


-- Validate the selver table

SELECT DISTINCT
	cntry
FROM silver.erp_loc_a101
ORDER BY cntry

SELECT * FROM silver.erp_loc_a101;


-- Now, everything is perfect with this column

-- Let's check the last table (Subcategories Informations)

SELECT
	id,
	cat,
	subcat,
	maintenance
FROM bronze.erp_px_cat_g1v2;

-- This table includes 4 string columns
-- First, let's check the empty spaces in all columns

SELECT
	id,
	cat,
	subcat,
	maintenance
FROM bronze.erp_px_cat_g1v2
WHERE id != TRIM(id)
OR cat != TRIM(cat)
OR subcat != TRIM(subcat) 
OR maintenance != TRIM(maintenance) 

-- The results show no issues

-- Next, lets check the linkage using the id columns with the product info table (cat_id)
SELECT
	id,
	cat,
	subcat,
	maintenance
FROM bronze.erp_px_cat_g1v2
WHERE id NOT IN (SELECT cat_id FROM silver.crm_prd_info)

-- Checked and no issues

-- Lastly, we need to check the consistency in the ca, sub_cat, and maintenance columns
SELECT DISTINCT
	cat
FROM bronze.erp_px_cat_g1v2 -- No issues found

SELECT DISTINCT
	subcat
FROM bronze.erp_px_cat_g1v2 -- No issues found

SELECT DISTINCT
	maintenance
FROM bronze.erp_px_cat_g1v2 -- No issues found

-- All checked with no issues

-- Lets insert the table into the silver table

INSERT INTO silver.erp_px_cat_g1v2 (
	id,
	cat,
	subcat,
	maintenance
)
SELECT
	id,
	cat,
	subcat,
	maintenance
FROM bronze.erp_px_cat_g1v2

SELECT * FROM silver.erp_px_cat_g1v2;