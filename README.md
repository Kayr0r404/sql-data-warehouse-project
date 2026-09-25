# SQL Data Warehouse Project

A comprehensive SQL Server data warehouse implementation following the **Medallion Architecture** (Bronze → Silver → Gold), designed to transform raw CRM and ERP source data into business-ready analytical models.

## Table of Contents

- [Architecture](#architecture)
- [Data Layers](#data-layers)
- [Source Data](#source-data)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Data Quality Checks](#data-quality-checks)
- [Naming Conventions](#naming-conventions)

---

## Architecture

This project follows the **Medallion Architecture** pattern, organizing data into three distinct layers:

- **Bronze** — Raw, unmodified data ingested directly from source systems (CRM & ERP).
- **Silver** — Cleaned, standardized, and transformed data ready for integration.
- **Gold** — Business-ready dimension and fact tables structured in a **Star Schema** for analytics and reporting.

---

## Data Layers

### 🥉 Bronze Layer

The bronze layer stores raw data exactly as it exists in the source systems. No transformations are applied.

**Tables:**
| Table | Source System | Description |
|-------|--------------|-------------|
| `bronze.crm_cust_info` | CRM | Customer information |
| `bronze.crm_prd_info` | CRM | Product information |
| `bronze.crm_sales_details` | CRM | Sales transaction details |
| `bronze.erp_loc_a101` | ERP | Location/country codes |
| `bronze.erp_cust_az12` | ERP | Customer demographics |
| `bronze.erp_px_cat_g1v2` | ERP | Product category mappings |

### 🥈 Silver Layer

The silver layer applies data cleansing, standardization, deduplication, and type conversions to the bronze data.

**Tables:**
| Table | Description |
|-------|-------------|
| `silver.crm_cust_info` | Cleaned customer data with normalized marital status & gender |
| `silver.crm_prd_info` | Standardized product data with category extraction & date ranges |
| `silver.crm_sales_details` | Validated sales transactions with corrected dates & pricing |
| `silver.erp_loc_a101` | Normalized location data with full country names |
| `silver.erp_cust_az12` | Cleaned customer demographics with normalized gender & birthdates |
| `silver.erp_px_cat_g1v2` | Product category reference data |

### 🥇 Gold Layer

The gold layer presents a **Star Schema** with dimension and fact views optimized for analytical querying.

**Views:**
| View | Type | Description |
|------|------|-------------|
| `gold.dim_customers` | Dimension | Enriched customer profile with geo-demographic data |
| `gold.dim_products` | Dimension | Current product catalog with category & subcategory attributes |
| `gold.fact_sales` | Fact | Transactional sales facts linked to customer & product dimensions |

---

## Source Data

The project ingests data from two source systems:

### CRM Source (`datasets/source_crm/`)

| File                | Records | Description        |
| ------------------- | ------- | ------------------ |
| `cust_info.csv`     | ~18K    | Customer profiles  |
| `prd_info.csv`      | ~400    | Product catalog    |
| `sales_details.csv` | ~60K    | Sales transactions |

### ERP Source (`datasets/source_erp/`)

| File              | Description                                   |
| ----------------- | --------------------------------------------- |
| `CUST_AZ12.csv`   | Customer demographic data (birthdate, gender) |
| `LOC_A101.csv`    | Country/location codes                        |
| `PX_CAT_G1V2.csv` | Product category and subcategory mappings     |

---

## Project Structure

```
sql-data-warehouse-project/
├── datasets/
│   ├── source_crm/          # Raw CRM CSV files
│   └── source_erp/          # Raw ERP CSV files
├── scripts/
│   ├── init_database.sql    # Creates DataWarehouse DB and schemas (bronze, silver, gold)
│   ├── bronze/
│   │   ├── ddl_bronze.sql       # Bronze table definitions
│   │   └── proc_load_bronze.sql # Stored procedure to load bronze from CSVs
│   ├── silver/
│   │   ├── ddl_silver.sql       # Silver table definitions
│   │   └── proc_load_silver.sql # Stored procedure to transform bronze → silver
│   └── gold/
│       └── ddl_gold.sql         # Gold layer views (dim_customers, dim_products, fact_sales)
├── tests/
│   ├── quality_checks_silver.sql  # Data quality validation for silver layer
│   └── quality_checks_gold.sql    # Data quality validation for gold layer
├── docs/
│   ├── data_catalog.md        # Gold layer column-level documentation
│   ├── naming_conventions.md  # Naming conventions for all objects
│   ├── data_architecture.png  # Architecture diagram
│   ├── data_flow.png          # Data flow diagram
│   ├── data_integration.png   # Data integration diagram
│   ├── data_model.png         # ER/data model diagram
│   └── ETL.png                # ETL process diagram
├── LICENSE                  # MIT License
├── FUNDING.yml              # Funding information
└── README.md                # This file
```

---

## Getting Started

### Prerequisites

- **SQL Server** (2016 or later) or **SQL Server Express**
- Access to the `master` database to create the `DataWarehouse` database
- CSV files placed in the expected directory paths (see `scripts/bronze/proc_load_bronze.sql` for path configuration)

### Setup Instructions

1. **Create the Database and Schemas**

   ```sql
   -- Run the init script to create the DataWarehouse database and schemas
   -- WARNING: This drops the existing DataWarehouse database if it exists
   EXEC your_database;
   ```

   Or run `scripts/init_database.sql` directly in SQL Server Management Studio (SSMS).

2. **Create Bronze Tables**

   ```sql
   -- Execute the bronze DDL script
   -- Creates all bronze schema tables
   ```

3. **Load Bronze Layer**

   ```sql
   -- Update file paths in scripts/bronze/proc_load_bronze.sql if needed, then execute:
   EXEC bronze.load_bronze;
   ```

4. **Create Silver Tables**

   ```sql
   -- Execute the silver DDL script
   ```

5. **Load Silver Layer**

   ```sql
   -- Transforms and cleanses bronze data into silver
   EXEC silver.load_silver;
   ```

6. **Create Gold Views**
   ```sql
   -- Execute the gold DDL script
   -- Creates dimension and fact views
   ```

---

## Usage

Once fully loaded, query the Gold layer views for analytics:

```sql
-- View all customers with their demographic details
SELECT * FROM gold.dim_customers;

-- View current product catalog
SELECT * FROM gold.dim_products;

-- View sales transactions joined with customer and product details
SELECT * FROM gold.fact_sales;

-- Example: Total sales by customer
SELECT
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_sales
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.first_name, c.last_name
ORDER BY total_sales DESC;
```

---

## Data Quality Checks

Quality validation scripts are provided to ensure data integrity at each layer.

### Silver Layer Checks (`tests/quality_checks_silver.sql`)

- NULL or duplicate primary keys
- Unwanted spaces in string fields
- Invalid date ranges and orders
- Data consistency (e.g., `sales = quantity × price`)
- Out-of-range birthdates
- Standardized value validation (gender, country, product line)

### Gold Layer Checks (`tests/quality_checks_gold.sql`)

- Uniqueness of surrogate keys in dimension tables
- Referential integrity between fact and dimension tables
- Orphaned records in the fact table

**Run after each layer load:**

```sql
-- Execute quality check scripts in SSMS
-- All checks should return empty result sets (no issues)
```

---

## Naming Conventions

The project follows a consistent naming convention across all layers:

| Layer             | Pattern                    | Example                       |
| ----------------- | -------------------------- | ----------------------------- |
| Bronze            | `<source_system>_<entity>` | `crm_cust_info`               |
| Silver            | `<source_system>_<entity>` | `crm_cust_info`               |
| Gold              | `<category>_<entity>`      | `dim_customers`, `fact_sales` |
| Stored Procedures | `load_<layer>`             | `load_bronze`, `load_silver`  |
| Surrogate Keys    | `<table>_key`              | `customer_key`, `product_key` |
| Technical Columns | `dwh_<column>`             | `dwh_create_date`             |

See `docs/naming_conventions.md` for the full specification.

---

## ETL Process Summary

```
┌──────────────┐     BULK INSERT      ┌──────────────┐     Transform     ┌──────────────┐
│   CSV Files  │ ──────────────────▶  │   Bronze     │ ─────────────────▶ │   Silver     │
│  (Source CRM  │                      │   Layer      │   Clean, Dedup,    │   Layer      │
│   & ERP)     │                      │              │   Standardize     │              │
└──────────────┘                      └──────────────┘                    └──────────────┘
                                                              │
                                                              │ SQL Views
                                                              ▼
                                                    ┌──────────────┐
                                                    │    Gold      │
                                                    │  (Star Schema)│
                                                    │ dim_ / fact_ │
                                                    └──────────────┘
```

# WTC-8V22UE6Y
