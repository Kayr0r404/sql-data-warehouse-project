/*
 ===============================================================================
 DDL Script: Create Bronze Tables (SQLite Version)
 ===============================================================================
 Script Purpose:
 This script creates tables in the 'bronze' layer, dropping existing tables 
 if they already exist.
 Run this script to re-define the DDL structure of 'bronze' Tables
 ===============================================================================
 */
DROP TABLE IF EXISTS bronze_crm_cust_info;

CREATE TABLE bronze_crm_cust_info (
    cst_id INTEGER,
    cst_key TEXT,
    cst_firstname TEXT,
    cst_lastname TEXT,
    cst_marital_status TEXT,
    cst_gndr TEXT,
    cst_create_date DATE
);

DROP TABLE IF EXISTS bronze_crm_prd_info;

CREATE TABLE bronze_crm_prd_info (
    prd_id INTEGER,
    prd_key TEXT,
    prd_nm TEXT,
    prd_cost INTEGER,
    prd_line TEXT,
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);

DROP TABLE IF EXISTS bronze_crm_sales_details;

CREATE TABLE bronze_crm_sales_details (
    sls_ord_num TEXT,
    sls_prd_key TEXT,
    sls_cust_id INTEGER,
    sls_order_dt INTEGER,
    sls_ship_dt INTEGER,
    sls_due_dt INTEGER,
    sls_sales INTEGER,
    sls_quantity INTEGER,
    sls_price INTEGER
);

DROP TABLE IF EXISTS bronze_erp_loc_a101;

CREATE TABLE bronze_erp_loc_a101 (cid TEXT, cntry TEXT);

DROP TABLE IF EXISTS bronze_erp_cust_az12;

CREATE TABLE bronze_erp_cust_az12 (cid TEXT, bdate DATE, gen TEXT);

DROP TABLE IF EXISTS bronze_erp_px_cat_g1v2;

CREATE TABLE bronze_erp_px_cat_g1v2 (
    id TEXT,
    cat TEXT,
    subcat TEXT,
    maintenance TEXT
);