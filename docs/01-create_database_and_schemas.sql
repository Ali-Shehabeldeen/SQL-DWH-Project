-- Step 01: Create Database 'DataWarehouse'

use master; 

create database DataWarehouse;

use DataWarehouse;

-- Step 02: Create Schemas for the three layers (Bronze, Silver, and Gold)

create schema bronze;
go

create schema silver;
go

create schema gold;
