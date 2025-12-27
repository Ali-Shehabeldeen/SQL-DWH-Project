# Data Warehouse and Analytics Project

Welcome to the **Data Warehouse and Analytics Project** repository! 

This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse to generating actionable insights, designed as a portfolio project highlights industry best practices in data engineering and analytics.

---

## Project Overview

This project involves:
1. **Data Archetecture**: Designing a modern data warehouse using medallion archetecture (Bronze, Silver, and Gold) layers
2. **ETL Pipeline**: Extractint, tranforming, and loading data from sourse system into warehouse.
3. **Data Modelling**: Developing fact and dimension tables optimized for analytical queries.
4. **Analytics & Reporting**: Creating SQL-based reports and dashboards for actionable insights.

---

## Project Requirements

### Building the Data Warehouse (Data Engineering)

#### Objective
Develop a modern data warehouse using SQL Server to consolidate sales data, enabeling analytical reporting and informed decision-making.

#### Specifications
- **Data Sources**: Import data from two source systems (ERP and CRM) provided as a CSV files.
- **Data Quality**: Cleanse and resolve data quality issues such as duplicates, missing values, and inconsistencies prior to analysis.
- **Integration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: Focus on latest dataset only, historization of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics team

---

### BI: Analytics & Reporting (Data Analysis)

#### Objective
Develop SQL-based analytics to deliver detailed insights into:
- **Customer Behavior**
- **Product Performance**
- **Sales Trends**

These insights empower stakeholders with key business metrics, enabling strategic decision-making.

--- 
## Data Archetecture

The data archetecture for this project follows Medallion Archetecture, including Bronze, Silver, and, Gold layers, as follows:

![Data_Arc](https://github.com/Ali-Shehabeldeen/SQL-DWH-Project/blob/main/docs/DWH%20Project%20Arch.drawio.png)

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV files into SQL Server Database.
2. **Silver Layer**: This layer includes data cleansing, standarization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.

## License

This project is licenced under the [MIT Licence](LICENCE). You are free to use modify, and shae this project with ptoper attribution.

## About Me
Hi, I’m Ali, a recent Ph.D. graduate from McMaster University with a multidisciplinary background spanning data analysis & data science and electrical power engineering, particularly medium- and high-voltage substation primary design.







