
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

