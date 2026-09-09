/*
=========================================
DDL Script: Create Gold Views
=========================================

Script Purpose:
	This script creates views for the Gold layer in the data warehouse.
	The Gold layer represents the final dimension and fact tables (star schema)
	
	Each view performs transformations and combines data from the silver layer
	to produce a clean, enriched, and business-ready dataset.

Usage:
	These vies can be queried directly for analytics and reporting.

*/



--Creating the VIEW object: gold dimension customer

IF OBJECT_ID ('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO


CREATE VIEW gold.dim_customers AS 
SELECT
	ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS firstname,
	ci.cst_lastname AS lastname,
	ci.cst_marital_status AS marital_status,
	CASE	WHEN ci.cst_gndr != 'n/a' 
			THEN ci.cst_gndr
			ELSE COALESCE(ec.gen,'n/a')
	END AS gender,
	el.CNTRY AS country,
	ec.BDATE AS birthdate,
	cst_create_date AS create_date	
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ec
	ON ci.cst_key = ec.CID
LEFT JOIN silver.erp_loc_a101 el
	ON ci.cst_key = el.CID





--Creating the view gold.dim_products

IF OBJECT_ID ('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY prd_start_dt, prd_key) AS product_key,
	pr.prd_id AS product_id,
	pr.prd_key AS product_number,
	pr.prd_nm AS product_name,
	pr.cat_id AS category_id,
	px.CAT AS category,
	px.SUBCAT AS subcategory,
	px.maintenance ,
	pr.prd_cost AS cost,
	pr.prd_line AS product_line,
	pr.prd_start_dt AS 'start_date'
FROM silver.crm_prd_info pr
LEFT JOIN silver.erp_px_cat_g1v2 px
	ON pr.cat_id = px.ID
WHERE pr.prd_end_dt IS NULL --To filter out historical dat



--Creating the view gold.fact_sales
  
IF OBJECT_ID ('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT 
	sd.sls_ord_num AS order_number,
	pr.product_key,
	cu.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS ship_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales  AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON		sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON		sd.sls_cust_id = cu.customer_id
