# Data Dictionary for Gold Layer

## Overview
The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of **dimension tables**, **fact tables**, and **views** for specific business metrics.

---

## Tables and Views in the Gold Layer

### 1. **gold.dim_customers**
- **Purpose:** Stores customer details enriched with demographic and geographic data.
- **Columns:**
  
| Column Name      | Data Type     | Description                                                                                 |
|------------------|---------------|---------------------------------------------------------------------------------------------|
| customer_key     | INT           | Surrogate key uniquely identifying each record in the customer dimension table.             |
| customer_id      | INT           | A unique identifier for the customer within the organization.                              |
| customer_number  | NVARCHAR(50)  | A number assigned to the customer for identification and tracking purposes.                |
| first_name       | NVARCHAR(50)  | The first name of the customer.                                                            |
| last_name        | NVARCHAR(50)  | The last name or family name of the customer.                                              |
| country          | NVARCHAR(50)  | The country where the customer resides or is registered.                                   |
| marital_status   | NVARCHAR(50)  | The marital status of the customer (Single, Married, n/a).                      |
| gender           | NVARCHAR(50)  | The gender of the customer (Male, Female, n/a).                               |
| birthday         | DATE          | The date of birth of the customer, stored in YYYY-MM-DD format.                            |
| create_date      | DATETIME2     | The timestamp of when the record was created in the data warehouse, including date and time.|

---

### 2. **gold.dim_products**
- **Purpose:** Provides information about the products and their attributes.
- **Columns:**
  | Column Name         | Data Type     | Description                                     |
  |---------------------|---------------|-------------------------------------------------|
  | product_key         | INT           | Surrogate key for the product dimension.        |
  | product_id          | INT           | Unique identifier for the product.              |
  | product_number      | NVARCHAR(50)  | Product number as defined in the source.        |
  | product_name        | NVARCHAR(50)  | Name of the product.                            |
  | category            | NVARCHAR(50)  | Product category.                               |
  | subcategory         | NVARCHAR(50)  | Product subcategory.                            |
  | maintenance_required| NVARCHAR(50)  | Indicates whether the product requires maintenance. |
  | cost                | INT           | Cost of the product.                            |
  | product_line        | NVARCHAR(50)  | Product line classification.                   |
  | is_active           | NVARCHAR(50)  | Indicates whether the product is currently active. |
  | start_date          | DATE          | Start date of product availability.             |
  | end_date            | DATE          | End date of product availability.               |
  | dwh_create_date     | DATETIME2     | Record creation timestamp in the data warehouse. |

---

### 3. **gold.fact_sales**
- **Purpose:** Stores transactional sales data for analytical purposes.
- **Columns:**
  | Column Name      | Data Type     | Description                                    |
  |------------------|---------------|------------------------------------------------|
  | order_number     | NVARCHAR(50)  | Unique identifier for the sales order.         |
  | product_key      | INT           | Foreign key linking to `gold.dim_products`.    |
  | customer_key     | INT           | Foreign key linking to `gold.dim_customers`.   |
  | order_date       | DATE          | Date when the order was placed.                |
  | shipping_date    | DATE          | Date when the order was shipped.               |
  | due_date         | DATE          | Due date for the order.                        |
  | sales_amount     | INT           | Total sales amount for the order.              |
  | quantity         | INT           | Quantity of products sold.                     |
  | price            | INT           | Price per unit of product sold.                |
  | dwh_create_date  | DATETIME2     | Record creation timestamp in the data warehouse. |

---

### 4. **gold.report_customers** (View)
- **Purpose:** Provides insights into customer behavior, spending, and segmentation.
- **Key Metrics:**
  - Total orders per customer.
  - Products purchased.
  - Total and average spending.
  - Customer lifespan and age group segmentation.
  - Customer retention status (New vs. Repeat).
  - Customer spending segments (High, Medium, Low).

---

### 5. **gold.report_products** (View)
- **Purpose:** Evaluates product performance and profitability.
- **Key Metrics:**
  - Total sales and orders.
  - Units sold and profitability.
  - Average selling price.
  - Monthly sales trends.
  - Customer purchase frequency per product.

---

### 6. **gold.fact_month_sales** (View)
- **Purpose:** Aggregates monthly sales performance.
- **Key Metrics:**
  - Total sales amount.
  - Number of orders.
  - Average order value.
  - Active customers.
  - Total units sold.

---

### 7. **gold.fact_year_sales** (View)
- **Purpose:** Analyzes yearly product performance and revenue trends.
- **Key Metrics:**
  - Total revenue and orders.
  - Units sold.
  - Year-over-year revenue change.
  - Revenue trend (Increase, Decrease, No Change).

---

## Conclusion
The Gold Layer serves as the analytical backbone of the data warehouse, providing clean, enriched, and aggregated datasets for reporting, analytics, and decision-making. It ensures scalability and flexibility for evolving business requirements.

# Business Rules Documentation

This document captures the business rules implemented in the SQL scripts for generating reports in the Gold Layer.

## Customer Segments
```sql
  SELECT 
    cs.customer_key,
    cs.total_spending,
    CASE 
      WHEN lifespan_in_month > 1000 AND total_orders > 10 THEN 'High Spender'
      WHEN lifespan_in_month BETWEEN 500 AND 1000 AND total_orders BETWEEN 5 AND 10 THEN 'Medium Spender'
      ELSE 'Low Spender' 
    END AS customer_segment
  FROM customer_spending cs
```
**Rule:**
This business rule categorizes customers into three spending segments based on their lifespan (in months) and total orders:
- High Spender: Customers with a lifespan exceeding 1000 months and more than 10 orders.
- Medium Spender: Customers with a lifespan between 500 and 1000 months and 5 to 10 orders.
- Low Spender: Customers not meeting the criteria for the above segments.

## Customer Retention Status
```sql
  SELECT 
    customer_key,
    CASE 
      WHEN COUNT(DISTINCT YEAR(s.order_date)) > 1 THEN 'Repeat Customer'
      ELSE 'New Customer'
    END AS retention_status
  FROM gold.fact_sales s
  GROUP BY customer_key
```
**Rule:**
This business rule determines the retention status of a customer based on their purchasing behavior:
- Repeat Customer: A customer who has made purchases in more than one distinct year.
- New Customer: A customer who has made purchases only in a single year.


