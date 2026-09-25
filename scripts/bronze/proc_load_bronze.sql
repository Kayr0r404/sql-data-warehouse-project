-- ===============================================================================
-- Script: Load Bronze Layer (Source -> Bronze) for SQLite
-- ===============================================================================
DELETE FROM
	bronze_crm_cust_info;

.import --csv --skip 1 "/home/kay3rr0r404/wtc_/python/sql-data-warehouse-project/datasets/source_crm/cust_info.csv" bronze_crm_cust_info
DELETE FROM
	bronze_crm_prd_info;

.import --csv --skip 1 "/home/kay3rr0r404/wtc_/python/sql-data-warehouse-project/datasets/source_crm/prd_info.csv" bronze_crm_prd_info
DELETE FROM
	bronze_crm_sales_details;

.import --csv --skip 1 "/home/kay3rr0r404/wtc_/python/sql-data-warehouse-project/datasets/source_crm/sales_details.csv" bronze_crm_sales_details
-- ============================================================================
-- Loading ERP Tables
-- ============================================================================
DELETE FROM
	bronze_erp_loc_a101;

.import --csv --skip 1 "/home/kay3rr0r404/wtc_/python/sql-data-warehouse-project/datasets/source_erp/LOC_A101.csv" bronze_erp_loc_a101
DELETE FROM
	bronze_erp_cust_az12;

.import --csv --skip 1 "/home/kay3rr0r404/wtc_/python/sql-data-warehouse-project/datasets/source_erp/CUST_AZ12.csv" bronze_erp_cust_az12
DELETE FROM
	bronze_erp_px_cat_g1v2;

.import --csv --skip 1 "/home/kay3rr0r404/wtc_/python/sql-data-warehouse-project/datasets/source_erp/PX_CAT_G1V2.csv" bronze_erp_px_cat_g1v2