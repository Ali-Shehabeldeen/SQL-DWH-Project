/*
=================================================================================
EDA: Exploring the database
=================================================================================
Script Purpose:
    This script explores the database structure and understand the relationships 
    between the tables. 
    This involves examining the tables, columns, data types, and relationships 
    to gain insights into the data model.

Usage:
    - Use these analyses to explore your database.
=================================================================================
*/ 

-- List all DB tables
SELECT 
	* 
FROM INFORMATION_SCHEMA.TABLES;

-- List all columns in a specific table
SELECT 
	*
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'; -- select specific table
