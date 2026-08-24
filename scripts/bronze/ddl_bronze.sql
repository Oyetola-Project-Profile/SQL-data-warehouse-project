
/*

===================================================================================
DDL Script: Create Bronze Tables
===================================================================================

Scritp Purpose:

	This script creates tables in the 'bronze' schema, dropping existing tables
	if they already exist.
	Run this script to re-define the DDL structure of 'bronze' Tables
====================================================================================

*/




--==============================================
--  TEST IF TABLES EXSIT AND CREATE TABLES
--==============================================


if OBJECT_ID ('bronze.crm_cust_info','U') is not null
	DROP TABLE bronze.crm_cust_info;
Create table bronze.crm_cust_info 
(
	cst_id int,
	cst_key nvarchar(50),
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_marital_status nvarchar(50),
	cst_gndr nvarchar(50),
	cst_create_date date
);
go

if OBJECT_ID ('bronze.crm_prd_info','U') is not null
	DROP TABLE bronze.crm_prd_info;
Create table bronze.crm_prd_info
(
	prd_id int,
	prd_key nvarchar(50),
	prd_nm  nvarchar(50),
	prd_cost int,
	prd_line nvarchar(20),
	prd_start_dt datetime,
	prd_end_dt datetime
);
go


IF OBJECT_ID('bronze.crm_sales_details','U' ) IS NOT NULL
	DROP TABLE bronze.crm_sales_details;
Create table bronze.crm_sales_details
(
	sls_ord_num nvarchar(50),
	sls_prd_key nvarchar(50),
	sls_cust_id int,
	sls_order_dt int,
	sls_ship_dt int,
	sls_due_dt int,
	sls_sales int,
	sls_quantity int,
	sls_price int
);
go



IF OBJECT_ID('bronze.erp_cust_az12','U' ) IS NOT NULL
	DROP TABLE bronze.erp_cust_az12;
Create table bronze.erp_cust_az12
(
	CID nvarchar(50),
	BDATE date,
	GEN nvarchar(50)
);
go



IF OBJECT_ID('bronze.erp_loc_a101','U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101;
Create table bronze.erp_loc_a101
(
	CID nvarchar(50),
	CNTRY nvarchar(50)
);
go


IF OBJECT_ID('bronze.erp_px_cat_g1v2','U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2
Create table bronze.erp_px_cat_g1v2
(
	ID nvarchar(50),
	CAT nvarchar(50),
	SUBCAT nvarchar(50),
	MAINTENANCE nvarchar(50)
);
go




--===================================================
--  TRUNCATE TABLES THEN LOAD TABLES WITH BULK INSERT
--===================================================

CREATE or ALTER PROCEDURE bronze.load_bronze AS

BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	
	
	BEGIN TRY
		SET @batch_start_time = GETDATE()
		PRINT '====================================';
		PRINT ' LOADING BRONZE LAYER';
		PRINT '====================================';



		PRINT '------------------------------------';
		PRINT ' LOADING CRM TABLES';
		PRINT '------------------------------------';
	
		SET @start_time = GETDATE();
		PRINT '>> Truncating table:bronze.crm_cust_info'; 
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Inserting table:bronze.crm_cust_info'; 
		BULK INSERT bronze.crm_cust_info
		FROM  'C:\Users\user\Documents\Data Analyst Portfolio\Baraa Data Warehouse project\datasets\source_crm\cust_info.csv'
		WITH 
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load duration' + ' ' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' ' + 'second';
		PRINT '>>--------------------';



		SET @start_time = GETDATE();
		PRINT '>> Truncating table:bronze.crm_prd_info'; 
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Inserting table:bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		from 'C:\Users\user\Documents\Data Analyst Portfolio\Baraa Data Warehouse project\datasets\source_crm\prd_info.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load duration' + ' ' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' ' + 'second';
		PRINT '>>--------------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating table:bronze.crm_sales_details'; 
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> Inserting table:bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		from 'C:\Users\user\Documents\Data Analyst Portfolio\Baraa Data Warehouse project\datasets\source_crm\sales_details.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load duration' + ' ' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' ' + 'second';
		PRINT '>>--------------------';


		PRINT '------------------------------------';
		PRINT ' LOADING ERP TABLES';
		PRINT '------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating table:bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT '>> Inserting table:bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		from 'C:\Users\user\Documents\Data Analyst Portfolio\Baraa Data Warehouse project\datasets\source_erp\cust_az12.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load duration' + ' ' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' ' + 'second';
		PRINT '>>--------------------';



		SET @start_time = GETDATE();
		PRINT '>> Truncating table:bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT '>> Inserting table:bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		from 'C:\Users\user\Documents\Data Analyst Portfolio\Baraa Data Warehouse project\datasets\source_erp\loc_a101.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load duration' + ' ' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' ' + 'second';
		PRINT '>>--------------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating table:bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT '>> Inserting table:bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		from 'C:\Users\user\Documents\Data Analyst Portfolio\Baraa Data Warehouse project\datasets\source_erp\px_cat_g1v2.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load duration' + ' ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' ' + 'second';
		PRINT '>>--------------------';
		
		SET @batch_end_time = GETDATE();

		PRINT '=================================';
		PRINT 'LOADING BRONZE LAYER IS COMPLETE'
		PRINT '>> Total Batch duration' + ' ' + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR) + ' ' + 'second';
		PRINT '=================================';

	END TRY
	BEGIN CATCH
		PRINT'=========================================='
		PRINT'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT'Error Message' + error_message();
		PRINT'Error Message' + cast (error_number() as nvarchar);
		PRINT'Error Message' + cast (error_state() as nvarchar);
		PRINT'=========================================='	
	END CATCH
END





/*
The code below were used to test during initial load

select count(*) from bronze.crm_cust_info
select * from bronze.crm_cust_info


SELECT COUNT(*) FROM bronze.crm_prd_info;
SELECT * FROM bronze.crm_prd_info;


SELECT COUNT(*) FROM bronze.crm_Sales_details;
SELECT * FROM bronze.crm_sales_details;


SELECT COUNT(*) FROM bronze.erp_cust_az12;
SELECT * FROM bronze.erp_cust_az12;



SELECT COUNT(*) FROM bronze.erp_loc_a101;
SELECT * FROM bronze.erp_loc_a101;


SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2;
SELECT * FROM bronze.erp_px_cat_g1v2; */
