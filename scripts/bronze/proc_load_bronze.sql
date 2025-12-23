/*
==========================================================
Stored Procedure: Load Bronze Layer (Source --> Bronze)
==========================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files.
    It performs the following:
    - Truncate the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from CSV files to bronze tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
==========================================================
*/ 

CREATE or ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
    
    BEGIN TRY
        
        SET @batch_start_time = GETDATE();

        PRINT '===================================';
        PRINT 'Loading the Bronze Layer';
        PRINT '===================================';

        PRINT '--------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '--------------------------';


        PRINT '>> Truncating Table: bronze.crm_cust_info';

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Inserting Data Into: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'D:\data_scientest\02-SQL\course_files\main_course_content\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Loading Duration of bronze.crm_cust_info: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds'

        -- Load data into crm_prd_info table
        PRINT '>> Truncating Table: bronze.crm_prd_inf';

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>> Inserting Data Into: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'D:\data_scientest\02-SQL\course_files\main_course_content\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Loading Duration of bronze.crm_prd_info: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds'

        -- Load data into crm_sales_details table
        PRINT '>> Truncating Table: bronze.crm_sales_details';

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Inserting Data Into: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'D:\data_scientest\02-SQL\course_files\main_course_content\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Loading Duration of bronze.crm_sales_details: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds'

        PRINT '--------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '--------------------------';

        -- Load data into erp_cust_az12 table
        PRINT '>> Truncating Table: bronze.erp_cust_az12';

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM 'D:\data_scientest\02-SQL\course_files\main_course_content\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Loading Duration of bronze.erp_cust_az12: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds'

        -- Load data into erp_loc_a101 table
        PRINT '>> Truncating Table: bronze.erp_loc_a101';

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM 'D:\data_scientest\02-SQL\course_files\main_course_content\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Loading Duration of bronze.erp_loc_a101: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds'

        -- Load data into erp_px_cat_g1v2 table
        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'D:\data_scientest\02-SQL\course_files\main_course_content\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Loading Duration of bronze.erp_px_cat_g1v2: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds'

        SET @batch_end_time = GETDATE();
        PRINT '=====================================================';
        PRINT '>> Loading Duration of Bronze Layer: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' Seconds'
        PRINT '=====================================================';

    END TRY
    BEGIN CATCH
        PRINT '=====================================================';
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
        PRINT 'EROOR MESSAGE' + ERROR_MESSAGE();
        PRINT 'ERROR NUMBER' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'ERROR STATE' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '=====================================================';
    END CATCH
END

