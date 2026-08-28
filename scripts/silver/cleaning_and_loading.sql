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




--=============================================
--CLEAN AND LOAD INTO 
--silver.crm_prd_info
--=============================================



--=======================================
--CHECKING FOR DUPLICATES AND NULLS 
--In table bronze.crm_prd_info
--Expectation is no result
--=======================================


SELECT prd_id, count(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL


--=============================================================
--CHECKING CATEGORY ID in bronze.crm that are not in bronze.erp
--=============================================================

SELECT TOP (1000) 
       prd_key
      ,[prd_id]
      ,REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id
      ,[prd_nm]
  FROM [DataWarehouse].[bronze].[crm_prd_info]
  WHERE REPLACE(SUBSTRING(prd_key,1,5),'-','_')  NOT IN
    (SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2)


--================================================================================
--CHECKING prd_key in bronze.crm_prd_info that are not in bronze.crm_sales_details
--================================================================================

SELECT TOP (1000) 
       [prd_id]
      ,[prd_key]
      ,REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id
      ,SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key
      ,[prd_nm]
      ,[prd_cost]
      ,[prd_line]
      ,[prd_start_dt]
      ,[prd_end_dt]
  FROM [DataWarehouse].[bronze].[crm_prd_info]
  WHERE SUBSTRING(prd_key,7,LEN(prd_key)) NOT IN --Use 'NOT IN' and 'IN' 
  (SELECT sls_prd_key FROM bronze.crm_sales_details)


--================================================================================
--CHECKING FOR UNWANTED SPACES in bronze.crm_prd_info 
--Expecting no result
--================================================================================

SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)


--================================================================================
--CHECKING FOR NULLS OR NEGATIVE NUMBERS in bronze.crm_prd_info 
--Expecting no result
--================================================================================

SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost  < 0 OR prd_cost IS NULL


--================================================================================
--CHECKING FOR standardization and consistency in bronze.crm_prd_info
--Need to normalize or enrich the data
--================================================================================

SELECT distinct prd_line
FROM bronze.crm_prd_info

--================================================================================
--CHECKING FOR INVALID DATE ORDER in bronze.crm_prd_info
--Dates must not overlap
--Last or end date must be greater than start or begin date
--================================================================================

SELECT * FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt






--=============================================
--CLEANING AND TRANSFORMING 
--bronze.crm_prd_info
--=============================================


SELECT  
       [prd_id]
      ,REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id
      ,SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key
      ,[prd_nm]
      ,ISNULL([prd_cost],0) AS prd_cost
      ,CASE 
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN   'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN   'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN   'Other sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN   'Touring'
            ELSE 'n/a'
        END AS [prd_line]
      ,CAST([prd_start_dt] AS DATE) AS prd_start_dt
      ,CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) -1 AS DATE)  AS [prd_end_dt]
  FROM [DataWarehouse].[bronze].[crm_prd_info]



--==================================================
--INSERTING INTO SILVER LAYER TABLE:
--silver.crm_prd_info
--==================================================

INSERT INTO silver.crm_prd_info
(
[prd_id]
,cat_id
,[prd_key]
,[prd_nm]
,prd_cost
,[prd_line]
,prd_start_dt
,[prd_end_dt]
)
SELECT  
       [prd_id]
      ,REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id
      ,SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key
      ,[prd_nm]
      ,ISNULL([prd_cost],0) AS prd_cost
      ,CASE 
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN   'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN   'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN   'Other sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN   'Touring'
            ELSE 'n/a'
        END AS [prd_line]
      ,CAST([prd_start_dt] AS DATE) AS prd_start_dt
      ,CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) -1 AS DATE)  AS [prd_end_dt]
  FROM [DataWarehouse].[bronze].[crm_prd_info]








--=======================================
--TESTING  TESTING  TESTING  TESTING  
--silver.crm_prd_info
--=======================================





--=======================================
--TESTING FOR DUPLICATES AND NULLS 
--In table silver.crm_prd_info
--Expectation is no result
--=======================================


SELECT prd_id, count(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL


--=============================================================
--TESTING CATEGORY ID in silver.crm that are not in silver.erp
--=============================================================

SELECT TOP (1000) 
       prd_key
      ,[prd_id]
      ,REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id
      ,[prd_nm]
  FROM [DataWarehouse].[silver].[crm_prd_info]
  WHERE REPLACE(SUBSTRING(prd_key,1,5),'-','_')  NOT IN
    (SELECT DISTINCT id FROM silver.erp_px_cat_g1v2)


--================================================================================
--TESTING prd_key in silver.crm_prd_info that are not in silver.crm_sales_details
--================================================================================

SELECT TOP (1000) 
       [prd_id]
      ,[prd_key]
      ,REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id
      ,SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key
      ,[prd_nm]
      ,[prd_cost]
      ,[prd_line]
      ,[prd_start_dt]
      ,[prd_end_dt]
  FROM [DataWarehouse].[silver].[crm_prd_info]
  WHERE SUBSTRING(prd_key,7,LEN(prd_key)) NOT IN --Use 'NOT IN' and 'IN' 
  (SELECT sls_prd_key FROM silver.crm_sales_details)


--================================================================================
--TESTING FOR UNWANTED SPACES in silver.crm_prd_info 
--Expecting no result
--================================================================================

SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)


--================================================================================
--TESTING FOR NULLS OR NEGATIVE NUMBERS in silver.crm_prd_info 
--Expecting no result
--================================================================================

SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost  < 0 OR prd_cost IS NULL


--================================================================================
--TESTING FOR standardization and consistency in silver.crm_prd_info
--Need to normalize or enrich the data
--================================================================================

SELECT distinct prd_line
FROM silver.crm_prd_info

--================================================================================
--TESTING FOR INVALID DATE ORDER in silver.crm_prd_info
--Dates must not overlap
--Last or end date must be greater than start or begin date
--================================================================================

SELECT * FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt


/*
TO GET TABLE INFORMATION USE ONE OF THE TWO BELOW:

(1)
EXEC sp_help '[bronze].[crm_sales_details]';
go

(2)
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'crm_sales_details'
  AND TABLE_SCHEMA = 'bronze'
ORDER BY ORDINAL_POSITION;

*/


SELECT * FROM silver.crm_prd_info



--=============================================
--CLEAN AND LOAD INTO 
--silver.crm_sales_details
--=============================================



--CHECKING COLUMN [sls_prd_key] & [sls_cust_id] IN bronze.crm_sales_details

--Checking the sls_ord_num column for whitespaces
--This should return no result
SELECT 
       [sls_ord_num]
FROM [DataWarehouse].[bronze].[crm_sales_details] 
WHERE sls_ord_num != TRIM(sls_ord_num)



--Checking for sls_prd_key column not in silver.crm_prd_info
--This should return no records
SELECT 
       [sls_ord_num]
      ,[sls_prd_key]
      ,[sls_cust_id]
FROM [DataWarehouse].[bronze].[crm_sales_details] 
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)


--Checking for sls_cust_id column not in silver.crm_cust_info
--This should return no records
SELECT 
       [sls_ord_num]
      ,[sls_prd_key]
      ,[sls_cust_id]
FROM [DataWarehouse].[bronze].[crm_sales_details] 
WHERE [sls_cust_id] NOT IN (SELECT cst_id FROM silver.crm_cust_info)




--==============
--ALTERNATIVELY
--==============

--Checking relation between [bronze].[crm_sales_details]
--and silver.crm_prd_info based on sls_prd_key and prd_key
SELECT 
     sd.[sls_cust_id], 
     sd.[sls_prd_key],
     prd.prd_key    
FROM 
       [bronze].[crm_sales_details] as sd
--Use either left or inner join the result is same
join silver.crm_prd_info as prd 
        on sd.sls_prd_key = prd.prd_key


--Checking relation between [bronze].[crm_sales_details]
--and silver.crm_prd_info based on sls_prd_key and prd_key
SELECT 
     sd.[sls_cust_id], 
     cst.cst_id
FROM 
       [bronze].[crm_sales_details] as sd
--Use either left or inner join the result is same
 join silver.crm_cust_info as cst 
        on sd.sls_cust_id = cst.cst_id


--To see data type for each column
EXEC SP_HELP 'bronze.crm_sales_details'



--CHECKING FOR INVALID DATES 

--The following code will fail because of invalid dates
--Invalid dates are date values with:
--zeros or < 0 or 
--!= 8 that the integer is < or > 8 digits. 
--For example 20261301 indicates 13th month
--So first we need to treat invalid dates in the code



--CHECKING DATE COLUMNS for invalid dates or format
Select 
    NULLIF (sls_order_dt,0) as sls_order_dt
from bronze.crm_sales_details
where   sls_order_dt < 0        OR
        sls_order_dt = 0        OR
        LEN(sls_order_dt) != 8  OR
        sls_order_dt > 20251201 OR
        sls_order_dt < 19001201


--CHECKING DATE COLUMNS for invalid dates orders
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
    or sls_order_dt > sls_due_dt
     



--TRANSFORMING DATE COLUMNS
SELECT 

      CASE WHEN sls_order_dt = 0 OR sls_order_dt < 0 OR LEN(sls_order_dt) != 8
            THEN NULL
            ELSE CAST(CAST(sls_order_dt AS NVARCHAR (50)) AS DATE)
       END sls_order_dt
      ,CASE WHEN sls_ship_dt = 0 OR sls_ship_dt < 0 OR LEN(sls_ship_dt) != 8
            THEN NULL
            ELSE CAST(CAST(sls_ship_dt AS NVARCHAR (50)) AS DATE)
       END sls_order_dt
      ,CASE WHEN sls_due_dt = 0 OR sls_due_dt < 0 OR LEN(sls_due_dt) != 8
            THEN NULL
            ELSE CAST(CAST(sls_due_dt AS NVARCHAR (50)) AS DATE)
       END sls_order_dt
FROM bronze.crm_sales_details



--CHECK BUSINESS RULES FOR Sales, Quantity and Price COLUMNS
-- >> Quantity * Price = Sales
-- >> Negative values, zeros or Null is not allowed


SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_price * sls_quantity != sls_sales
OR      sls_price IS NULL OR sls_quantity IS NULL OR sls_sales IS NULL
OR      sls_price <= 0  OR sls_quantity <= 0 OR sls_sales <= 0








--TRANSFORMING Sales, Quantity and Price COLUMNS
--Rules to apply:
--If sales is negative, zero or null, derive it from Quantity * Price
--If Price is zero or null, derive it from Sales / Quantity
--If Price is negative, convert it to positive


SELECT 
      [sls_sales],
      CASE  WHEN [sls_sales] <= 0 OR [sls_sales] IS NULL 
            THEN sls_quantity * ABS(sls_price)
            ELSE [sls_sales]
      END  sls_sales_new
      ,[sls_quantity]
      ,sls_price 
      ,CASE WHEN sls_price IS NULL OR sls_price <= 0 
            THEN sls_sales / NULLIF(sls_quantity,0)
            ELSE ABS(sls_price)
       END sls_price_NEW
FROM bronze.crm_sales_details
WHERE [sls_sales] IS NULL OR [sls_sales] <= 0 OR
      [sls_price] IS NULL OR [sls_price] <= 0


--=========================================================
--BRING TRANSFORMATION OF BRONZE.CRM_SALES_DETAILS TOGETHER
--=========================================================

SELECT 
      sls_ord_num
      ,sls_prd_key
      ,sls_cust_id
      ,CASE WHEN sls_order_dt = 0 OR sls_order_dt < 0 OR LEN(sls_order_dt) != 8
            THEN NULL
            ELSE CAST(CAST(sls_order_dt AS NVARCHAR (50)) AS DATE)
       END sls_order_dt
      ,CASE WHEN sls_ship_dt = 0 OR sls_ship_dt < 0 OR LEN(sls_ship_dt) != 8
            THEN NULL
            ELSE CAST(CAST(sls_ship_dt AS NVARCHAR (50)) AS DATE)
       END sls_ship_dt
      ,CASE WHEN sls_due_dt = 0 OR sls_due_dt < 0 OR LEN(sls_due_dt) != 8
            THEN NULL
            ELSE CAST(CAST(sls_due_dt AS NVARCHAR (50)) AS DATE)
       END sls_due_dt
      ,CASE  WHEN [sls_sales] <= 0 OR [sls_sales] IS NULL 
            THEN sls_quantity * ABS(sls_price)
            ELSE [sls_sales]
        END  sls_sales
      ,[sls_quantity]
      ,CASE WHEN sls_price IS NULL OR sls_price <= 0 
            THEN sls_sales / NULLIF(sls_quantity,0)
            ELSE ABS(sls_price)
       END sls_price
FROM bronze.crm_sales_details;
go



--========================================
--INSERTING INTO SILVER.CRM_SALES_DETAILS
--========================================

INSERT INTO silver.crm_sales_details
(      [sls_ord_num]
      ,[sls_prd_key]
      ,[sls_cust_id]
      ,[sls_order_dt]
      ,[sls_ship_dt]
      ,[sls_due_dt]
      ,[sls_sales]
      ,[sls_quantity]
      ,[sls_price]
      
)
SELECT 
      sls_ord_num
      ,sls_prd_key
      ,sls_cust_id
      ,CASE WHEN sls_order_dt = 0 OR sls_order_dt < 0 OR LEN(sls_order_dt) != 8
            THEN NULL
            ELSE CAST(CAST(sls_order_dt AS NVARCHAR (50)) AS DATE)
       END sls_order_dt
      ,CASE WHEN sls_ship_dt = 0 OR sls_ship_dt < 0 OR LEN(sls_ship_dt) != 8
            THEN NULL
            ELSE CAST(CAST(sls_ship_dt AS NVARCHAR (50)) AS DATE)
       END sls_ship_dt
      ,CASE WHEN sls_due_dt = 0 OR sls_due_dt < 0 OR LEN(sls_due_dt) != 8
            THEN NULL
            ELSE CAST(CAST(sls_due_dt AS NVARCHAR (50)) AS DATE)
       END sls_due_dt
      ,CASE  WHEN [sls_sales] <= 0 OR [sls_sales] IS NULL 
            THEN sls_quantity * ABS(sls_price)
            ELSE [sls_sales]
        END  sls_sales
      ,[sls_quantity]
      ,CASE WHEN sls_price IS NULL OR sls_price <= 0 
            THEN sls_sales / NULLIF(sls_quantity,0)
            ELSE ABS(sls_price)
       END sls_price
FROM bronze.crm_sales_details;
go

SELECT * FROM silver.crm_sales_details











