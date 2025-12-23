/*
==========================================================
Create Database and Schemas
==========================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists.
    If the database exists, it is dropped and recreated. 
    Additionally, the script sets up three schemas within the database: 'bronze', 'silver', and 'gold'.

WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists.
    All data in the database will be permanently deleted. 
    Proceed with caution and ensure you have proper backups before running this script.
*/ 


-- Step 01: Create Database 'DataWarehouse'

USE master; 
GO

-- Drop and recreate the 'DataWarehouse' database if exists
IF  EXISTS (SELECT 1 FROM sys.database WHERE name = 'DataWarehouse')
BEGIN
  ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE DataWarehouse
END;
GO

-- Create the database 'DataWarehouse' and active it
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;


-- Step 02: Create Schemas for the three layers (Bronze, Silver, and Gold)
CREATE SCHEMA bronze;
GO
  
CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
