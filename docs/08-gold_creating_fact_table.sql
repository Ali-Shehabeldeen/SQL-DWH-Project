-- Creating the fact sales table

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
FROM silver.crm_sales_details;

-- As this table is the fact table, the first thing we need to do lin it with the dimention tables (i.e., customers and products) based on the created surrogate keys iinstead of the prd_key and cust_id as follows

SELECT * FROM gold.dim_products;

SELECT * FROM gold.dim_customers;


SELECT 
	sd.sls_ord_num,
	dp.product_key,
	dc.customer_key,
	sd.sls_order_dt,
	sd.sls_ship_dt,
	sd.sls_due_dt,
	sd.sls_sales,
	sd.sls_quantity,
	sd.sls_price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS dp
ON sd.sls_prd_key = dp.product_number
LEFT JOIN gold.dim_customers AS dc
ON sd.sls_cust_id = dc.customer_id

-- Now, we linked the fact tble with the dimention tables
-- Let's give the column representative names and create the view
CREATE VIEW gold.fact_sales AS
SELECT 
	sd.sls_ord_num AS oreder_number,
	dp.product_key,
	dc.customer_key,
	sd.sls_order_dt AS oreder_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS dp
ON sd.sls_prd_key = dp.product_number
LEFT JOIN gold.dim_customers AS dc
ON sd.sls_cust_id = dc.customer_id

-- The last thing is to check the integrity of the fact table by trying to join it with dimention tables 

