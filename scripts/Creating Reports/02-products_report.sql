/*
=================================================================================================
Products Report
=================================================================================================
Purpose:
	- This report consolidates key product metrics and behaviours

Highlights:
	1. Gathers essential fields such as product name, category, subcategory, and cost.
	2. Segment products by revenue to identify High-Performances, Mid-Range or Low-Performances.
	3. Aggregates product-level metrics:
		- total orders
		- total sales
		- total quantity sold
		- total customers
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- Recency (months since last order)
		- average order revenue (AOR)
		- average monthly revenue

-- Usage case
      SELECT * FROM gold.products_report;
=================================================================================================
*/
IF OBJECT_ID('gold.products_report', 'V') IS NOT NULL
	DROP VIEW gold.products_report;
GO

CREATE VIEW gold.products_report AS
WITH ProductsBase AS (
/*
----------------------------------------------------------------------------------
1) Base Query: Retrive core columns from tables, and define the scope of data
----------------------------------------------------------------------------------
*/
	SELECT 
		f.order_number,
		f.customer_key,
		f.order_date,
		f.sales_amount,
		f.quantity,
		f.price,
		p.product_key,
		p.product_id,
		p.product_name,
		p.category,
		p.subcategory,
		p.cost
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
	ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL	
),
ProductAggregation AS (
	SELECT
		product_id,
		product_key,
		product_name,
		category,
		subcategory,
		cost,
		COUNT(DISTINCT order_number) AS total_orders,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		COUNT(DISTINCT customer_key) AS total_customers,
		MAX(order_date) AS last_sale_order,
		DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
		ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 0) AS avg_selling_price
	FROM ProductsBase
	GROUP BY
			product_id,
			product_key,
			product_name,
			category,
			subcategory,
			cost
)

SELECT
	product_id,
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_order,
	DATEDIFF(MONTH, last_sale_order, GETDATE()) AS recency_in_months,
	total_sales,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	total_orders,
	total_quantity,
	total_customers,
	lifespan,
	avg_selling_price,
	-- Calculate Order Revenue (sales / orders)
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_order_revenue,
	-- Calculate average monthly revenue (sales / lifespan)
	CASE 
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_monthly_revenue
FROM ProductAggregation;
