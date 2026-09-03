

/*
===================================================================================
Stored Procedure: Load Silver Layer (from Bronze to Silver)
===================================================================================

Script Purpose:
	This stored procedure performs the ETL (Extract, Transforme and Load
	process to populate the 'silver' schema tables from the 'bronze' schema.

Action Performed:
	-Truncate silver tables.
	-Insert transformed and cleansed data from bronze into silver tables.


Parameters:
	-None.
	-This stored procedure does not accept any parameter or return any values.

Usage Example:
	EXEC silver.load_siler

===================================================================================
*/


CREATE OR ALTER PROC silver.load_silver  AS

BEGIN
    DECLARE @start_time as DATETIME, @stop_time as DATETIME, 
            @batch_start_time as DATETIME, @batch_stop_time as DATETIME

    BEGIN TRY
        SET @batch_start_time = GETDATE()
        PRINT'======================='
        PRINT'LOADING SILVER LAYER'
        PRINT'======================='




        PRINT'----------------------'
        PRINT'LOADING CRM TABLES'
        PRINT'----------------------'
        --==================================================
        --INSERTING INTO SILVER LAYER TABLE:
        --silver.crm_cust_info
        --==================================================
        SET @start_time = GETDATE()
        PRINT '>>TRUNCATING TABLE: silver.crm_cust_info'
        TRUNCATE TABLE silver.crm_cust_info
        PRINT '>>INSERT DATA INTO: silver.crm_cust_info '

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
        SET @stop_time =  GETDATE()
        PRINT 'Duration' + '  ' +  CAST(DATEDIFF(SECOND,@start_time,@stop_time) AS NVARCHAR)
        PRINT '---------------------------'






        --==================================================
        --INSERTING INTO SILVER LAYER TABLE:
        --silver.crm_prd_info
        --==================================================
        SET @start_time = GETDATE()
        PRINT '>>TRUNCATING TABLE: silver.crm_prd_info'
        TRUNCATE TABLE silver.crm_prd_info
        PRINT '>>INSERT DATA INTO: silver.crm_prd_info '

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
          SET @stop_time = GETDATE()
          PRINT'Duration' + ' ' + CAST(DATEDIFF(SECOND,@start_time,@stop_time) AS NVARCHAR)
          PRINT '---------------------------'


        --==================================================
        --INSERTING INTO SILVER LAYER TABLE:
        --silver.crm_sales_details
        --==================================================
        SET @start_time = GETDATE()
        PRINT '>>TRUNCATING TABLE: silver.crm_sales_details'
        TRUNCATE TABLE silver.crm_sales_details
        PRINT '>>INSERT DATA INTO: silver.crm_sales_details '

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
              ,CASE  WHEN sls_sales <= 0 OR sls_sales IS NULL OR 
                            sls_sales != sls_quantity * ABS(sls_price)
                    THEN sls_quantity * ABS(sls_price)
                    ELSE sls_sales
                END  sls_sales
              ,sls_quantity
              ,CASE WHEN sls_price IS NULL OR sls_price <= 0 
                    THEN sls_sales / NULLIF(sls_quantity,0)
                    ELSE ABS(sls_price)
               END sls_price
        FROM bronze.crm_sales_details
        SET @stop_time = GETDATE()
        PRINT 'Duration' + ' ' + CAST(DATEDIFF(SECOND,@start_time,@stop_time) AS NVARCHAR)
        PRINT '---------------------------'


        PRINT'----------------------'
        PRINT'LOADING ERP TABLES'
        PRINT'----------------------'
        --==================================================
        --INSERTING INTO SILVER LAYER TABLE:
        --silver.erp_cust_az12
        --==================================================
        SET @start_time = GETDATE()
        PRINT '>>TRUNCATING TABLE: silver.erp_cust_az12'
        TRUNCATE TABLE silver.erp_cust_az12
        PRINT '>>INSERT DATA INTO: silver.erp_cust_az12 '

        INSERT INTO silver.erp_cust_az12
        (
            CID,
            BDATE,
            GEN
        )
        SELECT 
            CASE WHEN cid LIKE '%NAS%'
				         THEN SUBSTRING(cid,4,LEN(cid))
				         ELSE cid
	        END AS CID,
            CASE WHEN BDATE > GETDATE()
		         THEN NULL
		         ELSE BDATE
	        END BDATE,
            CASE	WHEN TRIM(GEN) IS NULL THEN 'n/a'
			        WHEN TRIM(GEN) = ''	 THEN 'n/a'
			        WHEN TRIM(GEN) = 'F' THEN 'Female'
			        WHEN TRIM(GEN) = 'M' THEN 'Male'
			        ELSE GEN
	        END AS GEN
        FROM bronze.erp_cust_az12
        SET @stop_time = GETDATE()
        PRINT 'Duration' + ' ' + CAST(DATEDIFF(SECOND,@start_time,@stop_time) AS NVARCHAR)
        PRINT '---------------------------'



        --==================================================
        --INSERTING INTO SILVER LAYER TABLE:
        --silver.erp_loc_a101
        --==================================================
        SET @start_time = GETDATE()
        PRINT '>>TRUNCATING TABLE: silver.erp_loc_a101'
        TRUNCATE TABLE silver.erp_loc_a101
        PRINT '>>INSERT DATA INTO: silver.erp_loc_a101 '

        INSERT INTO silver.erp_loc_a101
        (
            CID,
            CNTRY
        )
        SELECT
             REPLACE(CID,'-','') AS CID,
            CASE WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
                     WHEN TRIM(CNTRY) IN ('us','USA') THEN 'United States'
                     WHEN TRIM(CNTRY) IS NULL OR  TRIM(CNTRY) = '' THEN 'n/a'
                     ELSE CNTRY
            END AS CNTRY
        FROM bronze.erp_loc_a101
        SET @stop_time = GETDATE()
        PRINT 'Duration' + ' ' + CAST(DATEDIFF(SECOND,@start_time,@stop_time) AS NVARCHAR)
        PRINT '---------------------------'




        --==================================================
        --INSERTING INTO SILVER LAYER TABLE:
        --silver.erp_px_cat_g1v2
        --==================================================
        SET @start_time = GETDATE()
        PRINT '>>TRUNCATING TABLE: silver.erp_px_cat_g1v2'
        TRUNCATE TABLE silver.erp_px_cat_g1v2
        PRINT '>>INSERT DATA INTO: silver.erp_px_cat_g1v2 '

        INSERT INTO silver.erp_px_cat_g1v2
        (
            ID,
            CAT,
            SUBCAT,
            MAINTENANCE
        )
        SELECT 
            ID,
            CAT,
            SUBCAT,
            MAINTENANCE 
        FROM bronze.erp_px_cat_g1v2
        SET @stop_time = GETDATE()
        PRINT 'Duration' + ' ' + CAST(DATEDIFF(SECOND,@start_time,@stop_time) AS NVARCHAR)
        PRINT '---------------------------'
        
        
        
        SET @batch_stop_time = GETDATE()
        PRINT'==========================='
        PRINT'LOADING SILVER LAYER COMPLETED'
        PRINT'>>Total batch duration' + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_stop_time) AS NVARCHAR)
        PRINT'==========================='

    END TRY
    BEGIN CATCH
        PRINT '====================================='
        PRINT 'ERROR OCCURED DURING SILVER LAYER LOAD '
        PRINT 'Error message' + ERROR_MESSAGE()
        PRINT 'Error message' + CAST(ERROR_NUMBER() AS NVARCHAR)
        PRINT 'Error message' + CAST(ERROR_STATE() AS NVARCHAR)
        PRINT '====================================='
    END CATCH
END

