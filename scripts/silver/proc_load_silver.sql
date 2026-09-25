/*
 ===============================================================================
 SQL Script: Load Silver Layer (Bronze -> Silver) for SQLite
 ===============================================================================
 Script Purpose:
 This script performs the ETL (Extract, Transform, Load) process to 
 populate the 'silver' tables from the 'bronze' tables.
 Actions Performed:
 - Deletes old data from Silver tables.
 - Inserts transformed and cleansed data from Bronze into Silver tables.
 ===============================================================================
 */
-- Wrap the entire ETL load in a single transaction for safety and performance
BEGIN TRANSACTION;

-- ============================================================================
-- Loading silver_crm_cust_info
-- ============================================================================
DELETE FROM
	silver_crm_cust_info;

INSERT INTO
	silver_crm_cust_info (
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date
	)
SELECT
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	CASE
		WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		ELSE 'n/a'
	END AS cst_marital_status,
	CASE
		WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		ELSE 'n/a'
	END AS cst_gndr,
	cst_create_date
FROM
	(
		SELECT
			*,
			ROW_NUMBER() OVER (
				PARTITION BY cst_id
				ORDER BY
					cst_create_date DESC
			) AS flag_last
		FROM
			bronze_crm_cust_info
		WHERE
			cst_id IS NOT NULL
	) t
WHERE
	flag_last = 1;

-- ============================================================================
-- Loading silver_crm_prd_info
-- ============================================================================
DELETE FROM
	silver_crm_prd_info;

INSERT INTO
	silver_crm_prd_info (
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
	)
SELECT
	prd_id,
	REPLACE(SUBSTR(prd_key, 1, 5), '-', '_') AS cat_id,
	SUBSTR(prd_key, 7) AS prd_key,
	-- In SQLite, omitting the 3rd param goes to the end
	prd_nm,
	COALESCE(prd_cost, 0) AS prd_cost,
	CASE
		WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
		WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
		WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
		WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
		ELSE 'n/a'
	END AS prd_line,
	DATE(prd_start_dt) AS prd_start_dt,
	DATE(
		LEAD(prd_start_dt) OVER (
			PARTITION BY prd_key
			ORDER BY
				prd_start_dt
		),
		'-1 day'
	) AS prd_end_dt -- Calculate end date as one day before the next start date using SQLite date modifier
FROM
	bronze_crm_prd_info;

-- ============================================================================
-- Loading silver_crm_sales_details
-- ============================================================================
DELETE FROM
	silver_crm_sales_details;

INSERT INTO
	silver_crm_sales_details (
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
	)
SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	-- Manually format integer YYYYMMDD to YYYY-MM-DD for SQLite
	CASE
		WHEN sls_order_dt = 0
		OR LENGTH(CAST(sls_order_dt AS TEXT)) != 8 THEN NULL
		ELSE SUBSTR(CAST(sls_order_dt AS TEXT), 1, 4) || '-' || SUBSTR(CAST(sls_order_dt AS TEXT), 5, 2) || '-' || SUBSTR(CAST(sls_order_dt AS TEXT), 7, 2)
	END AS sls_order_dt,
	CASE
		WHEN sls_ship_dt = 0
		OR LENGTH(CAST(sls_ship_dt AS TEXT)) != 8 THEN NULL
		ELSE SUBSTR(CAST(sls_ship_dt AS TEXT), 1, 4) || '-' || SUBSTR(CAST(sls_ship_dt AS TEXT), 5, 2) || '-' || SUBSTR(CAST(sls_ship_dt AS TEXT), 7, 2)
	END AS sls_ship_dt,
	CASE
		WHEN sls_due_dt = 0
		OR LENGTH(CAST(sls_due_dt AS TEXT)) != 8 THEN NULL
		ELSE SUBSTR(CAST(sls_due_dt AS TEXT), 1, 4) || '-' || SUBSTR(CAST(sls_due_dt AS TEXT), 5, 2) || '-' || SUBSTR(CAST(sls_due_dt AS TEXT), 7, 2)
	END AS sls_due_dt,
	CASE
		WHEN sls_sales IS NULL
		OR sls_sales <= 0
		OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales,
	sls_quantity,
	CASE
		WHEN sls_price IS NULL
		OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0)
		ELSE sls_price
	END AS sls_price
FROM
	bronze_crm_sales_details;

-- ============================================================================
-- Loading silver_erp_cust_az12
-- ============================================================================
DELETE FROM
	silver_erp_cust_az12;

INSERT INTO
	silver_erp_cust_az12 (cid, bdate, gen)
SELECT
	CASE
		WHEN cid LIKE 'NAS%' THEN SUBSTR(cid, 4)
		ELSE cid
	END AS cid,
	CASE
		WHEN bdate > CURRENT_DATE THEN NULL
		ELSE bdate
	END AS bdate,
	CASE
		WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
		WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
		ELSE 'n/a'
	END AS gen
FROM
	bronze_erp_cust_az12;

-- ============================================================================
-- Loading silver_erp_loc_a101
-- ============================================================================
DELETE FROM
	silver_erp_loc_a101;

INSERT INTO
	silver_erp_loc_a101 (cid, cntry)
SELECT
	REPLACE(cid, '-', '') AS cid,
	CASE
		WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
		WHEN TRIM(cntry) = ''
		OR cntry IS NULL THEN 'n/a'
		ELSE TRIM(cntry)
	END AS cntry
FROM
	bronze_erp_loc_a101;

-- ============================================================================
-- Loading silver_erp_px_cat_g1v2
-- ============================================================================
DELETE FROM
	silver_erp_px_cat_g1v2;

INSERT INTO
	silver_erp_px_cat_g1v2 (id, cat, subcat, maintenance)
SELECT
	id,
	cat,
	subcat,
	maintenance
FROM
	bronze_erp_px_cat_g1v2;

-- Commit the transaction to apply all changes at once
COMMIT;