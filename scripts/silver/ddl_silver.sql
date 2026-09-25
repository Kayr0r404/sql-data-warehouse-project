/*
 ===============================================================================
 DDL Script: Create Silver Tables (SQLite Version)
 ===============================================================================
 Script Purpose:
 This script creates tables in the 'silver' layer, dropping existing tables 
 if they already exist.
 Run this script to re-define the DDL structure of 'silver' Tables
 ===============================================================================
 */
DROP TABLE IF EXISTS silver_crm_cust_info;

CREATE TABLE silver_crm_cust_info (
    cst_id INTEGER,
    cst_key TEXT,
    cst_firstname TEXT,
    cst_lastname TEXT,
    cst_marital_status TEXT,
    cst_gndr TEXT,
    cst_create_date DATE,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver_crm_prd_info;

CREATE TABLE silver_crm_prd_info (
    prd_id INTEGER,
    cat_id TEXT,
    prd_key TEXT,
    prd_nm TEXT,
    prd_cost INTEGER,
    prd_line TEXT,
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver_crm_sales_details;

CREATE TABLE silver_crm_sales_details (
    sls_ord_num TEXT,
    sls_prd_key TEXT,
    sls_cust_id INTEGER,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INTEGER,
    sls_quantity INTEGER,
    sls_price INTEGER,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver_erp_loc_a101;

CREATE TABLE silver_erp_loc_a101 (
    cid TEXT,
    cntry TEXT,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver_erp_cust_az12;

CREATE TABLE silver_erp_cust_az12 (
    cid TEXT,
    bdate DATE,
    gen TEXT,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver_erp_px_cat_g1v2;

CREATE TABLE silver_erp_px_cat_g1v2 (
    id TEXT,
    cat TEXT,
    subcat TEXT,
    maintenance TEXT,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);