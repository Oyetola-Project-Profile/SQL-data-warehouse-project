
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
