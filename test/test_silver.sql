
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
--CLEANING AND TRANSFORMING bronze.crm_prd_info
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
,[prd_key]
,cat_id
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

