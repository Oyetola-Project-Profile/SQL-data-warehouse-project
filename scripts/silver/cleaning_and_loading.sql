--=========================================================
--  TEST IF TABLES EXSIT AND CREATE TABLES FOR SILVER LAYER
--=========================================================


if OBJECT_ID ('silver.crm_cust_info','U') is not null
	DROP TABLE silver.crm_cust_info;
Create table silver.crm_cust_info 
(
	cst_id int,
	cst_key nvarchar(50),
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_marital_status nvarchar(50),
	cst_gndr nvarchar(50),
	cst_create_date date,
	dwh_create_date datetime2 default getdate()
);
go

if OBJECT_ID ('silver.crm_prd_info','U') is not null
	DROP TABLE silver.crm_prd_info;
Create table silver.crm_prd_info
(
	prd_id int,
	prd_key nvarchar(50),
	prd_nm  nvarchar(50),
	prd_cost int,
	prd_line nvarchar(20),
	prd_start_dt datetime,
	prd_end_dt datetime,
	dwh_create_date datetime2 default getdate()
);
go


IF OBJECT_ID('silver.crm_sales_details','U' ) IS NOT NULL
	DROP TABLE silver.crm_sales_details;
Create table silver.crm_sales_details
(
	sls_ord_num nvarchar(50),
	sls_prd_key nvarchar(50),
	sls_cust_id int,
	sls_order_dt int,
	sls_ship_dt int,
	sls_due_dt int,
	sls_sales int,
	sls_quantity int,
	sls_price int,
	dwh_create_date datetime2 default getdate()
);
go



IF OBJECT_ID('silver.erp_cust_az12','U' ) IS NOT NULL
	DROP TABLE silver.erp_cust_az12;
Create table silver.erp_cust_az12
(
	CID nvarchar(50),
	BDATE date,
	GEN nvarchar(50),
	dwh_create_date datetime2 default getdate()
);
go



IF OBJECT_ID('silver.erp_loc_a101','U') IS NOT NULL
	DROP TABLE silver.erp_loc_a101;
Create table silver.erp_loc_a101
(
	CID nvarchar(50),
	CNTRY nvarchar(50),
	dwh_create_date datetime2 default getdate()
);
go


IF OBJECT_ID('silver.erp_px_cat_g1v2','U') IS NOT NULL
	DROP TABLE silver.erp_px_cat_g1v2
Create table silver.erp_px_cat_g1v2
(
	ID nvarchar(50),
	CAT nvarchar(50),
	SUBCAT nvarchar(50),
	MAINTENANCE nvarchar(50),
	dwh_create_date datetime2 default getdate()
);
go


--=======================================
--CHECKING FOR DUPLICATES AND NULLS 
--In table bronze.crm_cust_info
--=======================================

-- checking for duplicates and nulls
SELECT cst_id , count(*) as countid
FROM [bronze].[crm_cust_info]
GROUP BY cst_id
having count(*) > 1 or cst_id is null

-- checking for nulls
SELECT cst_id , count(*) as countid
FROM [bronze].[crm_cust_info]
GROUP BY cst_id
having cst_id is null

-- displyaing records with null cst_id
select * from [bronze].[crm_cust_info]
where cst_id is null


-- displyaing records with duplicate cst_id
select * from [bronze].[crm_cust_info]
where cst_id in (29483, 29449, 29473, 29433, 29466)



--=======================================
--CHECKING FOR LEADING OR TRAILING SPACES
--In table bronze.crm_cust_info
--=======================================

-- This displays rows with spaces in the column
-- Our expectation is tha it returns no result

SELECT CST_FIRSTNAME
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_lastname)





--==================================================
--CHECKING FOR STANDARDIZATION AND CONSISTENCY
--In table bronze.crm_cust_info
--==================================================
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info

SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info




--===========================================================
--CLEANING DUPLICATES AND NULLS in table bronze.crm_cust_info
--This will be used as the base for all cleaning
--===========================================================

SELECT * FROM 
(
	SELECT 
	* ,
	ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL	

) t WHERE flag_last = 1	





--=======================================================
--CLEANING THE TABLE bronze.crm_cust_info
--ALSO CHECK THE DATE COLUMN TO MAKE SURE IT IS DATE TYPE
--=======================================================

SELECT [cst_id]
      ,[cst_key]
      ,TRIM([cst_firstname])
      ,TRIM([cst_lastname])
      ,CASE WHEN cst_marital_status = 'M' THEN 'Married'
			WHEN cst_marital_status = 'S' THEN 'Single'
			ELSE 'n/a'
		END	[cst_marital_status]
      ,CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			ELSE 'n/a'
		END [cst_gndr]
      ,[cst_create_date]
  FROM 
 (
	SELECT 
	* ,
	ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL	

) t WHERE flag_last = 1	





--==================================================
--INSERTING INTO SILVER LAYER TABLE:
--silver.crm_cust_info
--==================================================


INSERT INTO silver.crm_cust_info
(
	   [cst_id]
      ,[cst_key]
      ,[cst_firstname]
      ,[cst_lastname]
      ,[cst_marital_status]
      ,[cst_gndr]
      ,[cst_create_date]
)

SELECT [cst_id]
      ,[cst_key]
      ,TRIM([cst_firstname])
      ,TRIM([cst_lastname])
      ,CASE WHEN cst_marital_status = 'M' THEN 'Married'
			WHEN cst_marital_status = 'S' THEN 'Single'
			ELSE 'n/a'
		END	[cst_marital_status]
      ,CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			ELSE 'n/a'
		END [cst_gndr]
      ,[cst_create_date]
  FROM 
 (
	SELECT 
	* ,
	ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL	

) t WHERE flag_last = 1	



SELECT * FROM silver.crm_cust_info
	


--===================================================
--TESTING SILVER LAYER FOR LEADING OR TRAILING SPACES
-- Our expectation is tha it returns no result
--===================================================

-- checking for duplicates and nulls
SELECT cst_id , count(*) as countid
FROM [silver].[crm_cust_info]
GROUP BY cst_id
having count(*) > 1 or cst_id is null

-- checking for nulls
SELECT cst_id , count(*) as countid
FROM [silver].[crm_cust_info]
GROUP BY cst_id
having cst_id is null

-- displyaing records with null cst_id
select * from [silver].[crm_cust_info]
where cst_id is null


-- displyaing records with duplicate cst_id
select * from [silver].[crm_cust_info]
where cst_id in (29483, 29449, 29473, 29433, 29466)



--===================================================
--TESTING SILVER LAYER FOR LEADING OR TRAILING SPACES
-- Our expectation is tha it returns no result
--===================================================


SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);
go

SELECT cst_lastname, len(cst_lastname)
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)





--========================================================
--TESTING SILVER LAYER FOR STANDARDIZATION AND CONSISTENCY
--We should have proper data
--========================================================
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info













